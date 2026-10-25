#version 330
#extension GL_ARB_separate_shader_objects : require
#define CG_POST
#include <continuum:renderer.glsl>
uniform sampler2D InSampler;
uniform sampler2D DepthSampler;
uniform sampler2D ArtSampler;
uniform sampler2D BorderSampler;
uniform sampler2D BookVanillaSampler;
uniform sampler2D BookLeftSampler;
uniform sampler2D BookRightSampler;
uniform sampler2D BookBothSampler;
uniform sampler2D ChiselSampler;
layout(location=0) in vec2 texCoord;
layout(location=1) flat in int cgValid;
layout(location=2) flat in mat4 inverseMV;
layout(location=6) flat in mat4 inverseProj;
layout(location=10) flat in vec3 origin;
layout(location=11) flat in vec4 fogColor;
layout(location=12) flat in vec4 fogDistances;
layout(location=0) out vec4 fragColor;
ivec2 address(ivec3 cell) {
    int i=cell.x+CG_GRID_SIZE*(cell.y+CG_GRID_SIZE*cell.z), width=textureSize(InSampler,0).x;
    return ivec2(i%width,1+i/width);
}
int cgBlockType(ivec3 cell) {
    if(any(lessThan(cell,ivec3(0))) || any(greaterThanEqual(cell,ivec3(CG_GRID_SIZE)))) return 0;
    ivec2 p=address(cell);
    
    if(texelFetch(DepthSampler,p,0).r<0.99) return 0;
    ivec3 b=ivec3(round(texelFetch(InSampler,p,0).rgb*255.0));
    if(b.g==174 && b.r>=20 && b.r<=23 && b.b<=63) return b.r;
    return b.g==173 && b.b==91 && b.r>=1 && b.r<=19 ? b.r:0;
}
bool border(ivec3 cell,int id,vec3 hit,int axis) {
    for(int d=0;d<3;d++) {
        if(d==axis) continue;
        float u=clamp(hit[d]-float(cell[d]),0.0,1.0);
        ivec3 offset=ivec3(0);offset[d]=-1;
        if(u<0.040625 && cgBlockType(cell+offset)!=id) return true;
        offset[d]=1;
        if(u>0.959375 && cgBlockType(cell+offset)!=id) return true;
    }
    return false;
}
float ramp(float value,float low,float high) {return clamp((value-low)/max(high-low,0.0001),0.0,1.0);}

int cgGlassType(ivec3 cell) {
    int id=cgBlockType(cell);
    return id<=18?id:0;
}
vec4 cgBookshelf(vec4 background,vec3 direction,float distance) {
    vec3 hit=origin+direction*distance;
    vec3 error=abs(hit-round(hit));
    int axis=error.x<error.y?(error.x<error.z?0:2):(error.y<error.z?1:2);
    if(axis==1 || error[axis]>0.012) return background;
    hit[axis]=round(hit[axis]);
    ivec3 cell=ivec3(floor(hit+direction*0.002));
    int shelf=cgBlockType(cell);
    bool chiseled=shelf>=20 && shelf<=23;
    if(shelf!=19 && !chiseled) return background;
    if(chiseled) {
        int face=shelf-20;
        if(axis!=(face%2==0?2:0)) return background;
        float entry=face==0?direction.z:(face==1?-direction.x:(face==2?-direction.z:direction.x));
        if(entry<=0.0) return background;
    }
    int horizontal=2-axis;
    int facing=axis==0?(direction.x>0.0?1:-1):(direction.z>0.0?-1:1);
    ivec3 right=ivec3(0);right[horizontal]=facing;
    bool leftConnected=cgBlockType(cell-right)==shelf;
    bool rightConnected=cgBlockType(cell+right)==shelf;
    vec3 local=clamp(hit-vec3(cell),0.0,1.0);
    vec2 uv=vec2(facing>0?local[horizontal]:1.0-local[horizontal],1.0-local.y);
    ivec2 pixel=ivec2(clamp(floor(uv*16.0),vec2(0.0),vec2(15.0)));
    vec3 selected;
    if(chiseled) {
        int mask=int(round(texelFetch(InSampler,address(cell),0).b*255.0));
        int slot=(pixel.y>=8?3:0)+(pixel.x<6?0:(pixel.x<11?1:2));
        int occupied=(mask>>slot)&1;
        int variant=leftConnected?(rightConnected?3:2):(rightConnected?1:0);

        selected=texelFetch(ChiselSampler,ivec2(pixel.x,pixel.y+(variant*2+occupied)*16),0).rgb;
    } else {

        selected=leftConnected?(rightConnected?texelFetch(BookBothSampler,pixel,0).rgb:texelFetch(BookRightSampler,pixel,0).rgb):(rightConnected?texelFetch(BookLeftSampler,pixel,0).rgb:texelFetch(BookVanillaSampler,pixel,0).rgb);
    }
    vec3 displacement=hit-origin;
    float cylindrical=max(abs(displacement.y),length(displacement.xz));
    float fog=max(ramp(distance,fogDistances.x,fogDistances.y),ramp(cylindrical,fogDistances.z,fogDistances.w))*fogColor.a;
    vec3 fogTerm=fogColor.rgb*fog;
    float light=texelFetch(InSampler,address(cell),0).a;
    float shade=axis==0?0.78:0.9;
    vec3 lighting=vec3(light*shade*(1.0-fog));
    return vec4(selected*lighting+fogTerm,background.a);
}

void main() {
    ivec2 size=textureSize(InSampler,0);
    if(!cgEnabled(size)) {fragColor=texture(InSampler,texCoord);return;}
    float band=float(cgRows(size))/float(size.y);
    vec2 sceneUV=vec2(texCoord.x,clamp(band+texCoord.y*(1.0-band),band+0.5/float(size.y),1.0-0.5/float(size.y)));
    vec4 background=texture(InSampler,sceneUV);
    fragColor=background;
    if(cgValid==0) return;
    vec4 viewPoint=inverseProj*vec4(texCoord*2.0-1.0,0.5,1.0);
    vec3 direction=normalize(mat3(inverseMV)*(viewPoint.xyz/viewPoint.w));
    float limitDistance=10000.0;
    float depth=texture(DepthSampler,sceneUV).r;
    if(depth>0.0000001) {
        #ifndef RENDERPEARL_DEPTH_IS_ZERO_TO_ONE
        depth=depth*2.0-1.0;
        #endif
        vec4 opaqueView=inverseProj*vec4(texCoord*2.0-1.0,depth,1.0);
        limitDistance=length(opaqueView.xyz/opaqueView.w);
    }
    if(texture(DepthSampler,sceneUV).r>0.0000001) background=cgBookshelf(background,direction,limitDistance);
    ivec3 cell=ivec3(floor(origin));
    ivec3 stepDir=ivec3(sign(direction));
    vec3 delta=1.0/max(abs(direction),vec3(0.000001));
    vec3 next=mix(fract(origin),1.0-fract(origin),greaterThan(direction,vec3(0.0)))*delta;
    int previous=cgGlassType(cell);
    bool startedInside=previous!=0;
    vec3 rgb=vec3(0.0);float transmission=1.0;
    for(int iteration=0;iteration<3*CG_GRID_SIZE;iteration++) {
        int axis=next.x<next.y ? (next.x<next.z?0:2):(next.y<next.z?1:2);
        float distance=next[axis];next[axis]+=delta[axis];
        if(distance>=limitDistance-0.0005) break;
        ivec3 oldCell=cell;cell[axis]+=stepDir[axis];
        if(any(lessThan(cell,ivec3(0))) || any(greaterThanEqual(cell,ivec3(CG_GRID_SIZE)))) break;
        int id=cgGlassType(cell);
        bool exitSurface=startedInside && id==0 && previous!=0;
        if((id!=0 && id!=previous) || exitSurface) {
            ivec3 surfaceCell=exitSurface?oldCell:cell;
            int surfaceId=exitSurface?previous:id;
            vec3 hit=origin+direction*distance;
            vec3 local=clamp(hit-vec3(surfaceCell),0.0,1.0);
            vec2 uv=axis==0?local.zy:(axis==1?local.xz:local.xy);
            
            if(axis!=1) uv.y=1.0-uv.y;
            if((axis==0 && stepDir.x<0) || (axis==2 && stepDir.z>0)) uv.x=1.0-uv.x;
            ivec2 artPixel=ivec2(clamp(floor(uv*16.0),vec2(0.0),vec2(15.0)));
            bool edge=border(surfaceCell,surfaceId,hit,axis);
            ivec2 pixel=ivec2(artPixel.x,(surfaceId-1)*16+artPixel.y);
            vec4 surface= edge ? texelFetch(BorderSampler,pixel,0) : texelFetch(ArtSampler,pixel,0);
            float alpha=surface.a;
            float shade=axis==1 ? (stepDir[axis]<0?1.0:0.55):(axis==0?0.78:0.9);
            float light=texelFetch(InSampler,address(surfaceCell),0).a;
            vec3 color=surface.rgb*shade*light;
            vec3 displacement=hit-origin;
            float cylindrical=max(abs(displacement.y),length(displacement.xz));
            float fog=max(ramp(distance,fogDistances.x,fogDistances.y),ramp(cylindrical,fogDistances.z,fogDistances.w));
            color=mix(color,fogColor.rgb,fog*fogColor.a);
            rgb+=transmission*color*alpha;transmission*=1.0-alpha;
            if(transmission<0.001) break;
        }
        previous=id;
    }
    fragColor=vec4(rgb+background.rgb*transmission,background.a);
}
