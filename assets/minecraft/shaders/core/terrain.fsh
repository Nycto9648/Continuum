#version 330
#extension GL_ARB_separate_shader_objects : require
#include <continuum:renderer.glsl>

#include <minecraft:fog.glsl>
#include <minecraft:globals.glsl>
#include <minecraft:projection.glsl>
#include <minecraft:texture_sampling.glsl>
#include <minecraft:oit.glsl>
#include <minecraft:terrainglobals.glsl>
#ifndef MULTIDRAW_TERRAIN
    #include <minecraft:chunksection.glsl>
#endif

uniform sampler2D Sampler0;

layout(location = 0) in float sphericalVertexDistance;
layout(location = 1) in float cylindricalVertexDistance;
layout(location = 2) in vec4 vertexColor;
layout(location = 3) in vec2 texCoord0;
layout(location = 4) in float chunkVisibility;

#ifndef OIT_ALPHA_ONLY
layout(location = 0) out vec4 fragColor;
#endif

vec4 calculateFinalColor(vec4 color) {
    #ifdef OIT_ACCUMULATE
    color = sampleColorForAccumulation(color);
    vec4 fogColor = vec4(FogColor.rgb * color.a, FogColor.a);
    #else
    vec4 fogColor = FogColor;
    #endif
    return apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, fogColor);
}

layout(location = 5) flat in int cgKind;
layout(location = 6) flat in int cgId;
layout(location = 7) in vec3 cgPosition;
layout(location = 8) flat in ivec3 cgCell;
layout(location = 9) flat in vec2 cgFallbackUV;
layout(location = 10) flat in int cgBookMask;
vec4 cgFallbackSample(vec2 uv,vec2 center) {
    vec2 texel=1.0/vec2(textureSize(Sampler0,0));
    vec2 mapped=center+(uv-center)*0.5;
    return textureLod(Sampler0,clamp(mapped,center-7.5*texel,center+7.5*texel),0.0);
}

#include <continuum:glass_palette.glsl>
vec4 cgEncode(float value) {
    uint b = floatBitsToUint(value);
    return vec4(uvec4(b, b >> 8u, b >> 16u, b >> 24u) & uvec4(255u)) / 255.0;
}
void main() {
    if (cgKind == 1 || cgKind == 2) {
        #ifdef OIT_ALPHA_ONLY
        discard;
        #else
        if (cgKind == 1) {
            fragColor = vec4(float(cgId) / 255.0, (cgBookMask>=0?174.0:173.0) / 255.0, (cgBookMask>=0?float(cgBookMask):91.0) / 255.0, clamp(dot(vertexColor.rgb,vec3(0.2126,0.7152,0.0722)),0.0,1.0));
        } else {
            int p = int(gl_FragCoord.x);
            if (p < 16) fragColor = cgEncode(ModelViewMat[p / 4][p % 4]);
            else if (p < 32) fragColor = cgEncode(ProjMat[(p-16) / 4][(p-16) % 4]);
            else if (p < 35) fragColor = cgEncode(CameraOffset[p-32]);
            else if(p == 35) fragColor = vec4(73.0,181.0,229.0,255.0)/255.0;
            else if(p < 40) fragColor = cgEncode(FogColor[p-36]);
            else if(p == 40) fragColor = cgEncode(FogEnvironmentalStart);
            else if(p == 41) fragColor = cgEncode(FogEnvironmentalEnd);
            else if(p == 42) fragColor = cgEncode(FogRenderDistanceStart);
            else fragColor = cgEncode(FogRenderDistanceEnd);
        }
        return;
        #endif
    }

    if(ProjMat[3][3] == 0.0 && cgEnabled(ivec2(ScreenSize)) && gl_FragCoord.y < float(cgRows(ivec2(ScreenSize)))) discard;
    if(cgKind == 3 && cgEnabled(ivec2(ScreenSize)) && all(greaterThanEqual(cgCell,ivec3(0))) && all(lessThan(cgCell,ivec3(CG_GRID_SIZE)))) discard;
    vec4 color = (UseRgss == 1 ? sampleRGSS(Sampler0, texCoord0, 1.0f / TextureSize) : sampleNearest(Sampler0, texCoord0, 1.0f / TextureSize)) * vertexColor;
    if(cgKind == 3) color=cgFallbackSample(texCoord0,cgFallbackUV)*vertexColor;
    #ifndef OIT_ALPHA_ONLY
    color = mix(FogColor * vec4(1, 1, 1, color.a), color, chunkVisibility);
    #endif
    #ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
    #endif

    #ifdef OIT_ALPHA_ONLY
    executeAlphaOnlyPhase(gl_FragCoord.z, color.a);
    #else
    fragColor = calculateFinalColor(color);
    #endif
}
