#version 330
#extension GL_ARB_separate_shader_objects : require
#define CG_POST
#include <connected_glass:viewport.glsl>
uniform sampler2D InSampler;
uniform sampler2D DepthSampler;
layout(location=0) out vec2 texCoord;
layout(location=1) flat out int cgValid;
layout(location=2) flat out mat4 inverseMV;
layout(location=6) flat out mat4 inverseProj;
layout(location=10) flat out vec3 origin;
layout(location=11) flat out vec4 fogColor;
layout(location=12) flat out vec4 fogDistances;
float decode(int p) {
    uvec4 b=uvec4(round(texelFetch(InSampler,ivec2(p,0),0)*255.0));
    return uintBitsToFloat(b.r | (b.g<<8u) | (b.b<<16u) | (b.a<<24u));
}
void main() {
    vec2 uv=vec2((gl_VertexIndex<<1)&2,gl_VertexIndex&2);
    gl_Position=vec4(uv*2.0-1.0,0.0,1.0);texCoord=uv;
    cgValid=0;inverseMV=mat4(1.0);inverseProj=mat4(1.0);
    origin=vec3(float(CG_GRID_HALF));fogColor=vec4(0.0);fogDistances=vec4(1000.0);
    if(textureSize(InSampler,0).x<44) return;
    ivec3 signature=ivec3(round(texelFetch(InSampler,ivec2(35,0),0).rgb*255.0));
    if(!all(equal(signature,ivec3(73,181,229))) || texelFetch(DepthSampler,ivec2(35,0),0).r<0.99) return;
    mat4 mv,proj;
    for(int c=0;c<4;c++)for(int r=0;r<4;r++) {mv[c][r]=decode(c*4+r);proj[c][r]=decode(16+c*4+r);}
    inverseMV=inverse(mv);inverseProj=inverse(proj);
    origin=inverseMV[3].xyz-vec3(decode(32),decode(33),decode(34))+vec3(float(CG_GRID_HALF));
    fogColor=vec4(decode(36),decode(37),decode(38),decode(39));
    fogDistances=vec4(decode(40),decode(41),decode(42),decode(43));
    cgValid=1;
}
