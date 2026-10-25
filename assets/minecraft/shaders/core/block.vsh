#version 330
#extension GL_ARB_separate_shader_objects : require
#include <continuum:renderer.glsl>

#include <minecraft:fog.glsl>
#include <minecraft:dynamictransforms.glsl>
#include <minecraft:projection.glsl>
#include <minecraft:sample_lightmap.glsl>

layout(location = 0) in vec3 Position;
layout(location = 1) in vec4 Color;
layout(location = 2) in vec2 UV0;
layout(location = 3) in ivec2 UV2;

#ifndef OIT_ALPHA_ONLY
uniform sampler2D Sampler2;
#endif

layout(location = 0) out float sphericalVertexDistance;
layout(location = 1) out float cylindricalVertexDistance;
layout(location = 2) out vec4 vertexColor;
layout(location = 3) out vec2 texCoord0;
uniform sampler2D Sampler0;
layout(location = 4) flat out vec2 cgFallbackUV;
layout(location = 5) flat out int cgFallback;
vec2 cgFallbackCenter(vec2 uv,ivec4 tag,ivec2 size) {
    int corner=tag.b-232;
    return round(uv*vec2(size)+(vec2(0.5)-vec2(corner&1,corner>>1))*32.0)/vec2(size);
}


void cgOriginalMain() {
    vec3 pos = Position + ModelOffset;
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

    sphericalVertexDistance = fog_spherical_distance(pos);
    cylindricalVertexDistance = fog_cylindrical_distance(pos);
    #ifndef OIT_ALPHA_ONLY
    vertexColor = Color * sample_lightmap(Sampler2, UV2);
    #else
    vertexColor = Color;
    #endif
    texCoord0 = UV0;
    ivec4 tag=ivec4(round(textureLod(Sampler0,UV0,0.0)*255.0));
    cgFallback=int(tag.a==255 && tag.g==245 && tag.b>=232 && tag.b<=235 && tag.r>=42 && tag.r<=212);
    cgFallbackUV=cgFallback!=0?cgFallbackCenter(UV0,tag,textureSize(Sampler0,0)):vec2(0.0);
}

void main() {
    cgOriginalMain();
    if (ProjMat[3][3] == 0.0 && cgEnabled(ivec2(ScreenSize))) {
        float scale=cgScale(ivec2(ScreenSize));
        gl_Position.y=gl_Position.y*scale+gl_Position.w*(1.0-scale);
    }
}
