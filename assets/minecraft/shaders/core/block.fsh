#version 330
#extension GL_ARB_separate_shader_objects : require
#include <connected_glass:viewport.glsl>

#include <minecraft:fog.glsl>
#include <minecraft:dynamictransforms.glsl>
#include <minecraft:oit.glsl>

uniform sampler2D Sampler0;

layout(location = 0) in float sphericalVertexDistance;
layout(location = 1) in float cylindricalVertexDistance;
layout(location = 2) in vec4 vertexColor;
layout(location = 3) in vec2 texCoord0;

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

#include <connected_glass:palette.glsl>
void cgOriginalMain() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    ivec4 cgTag=ivec4(round(texture(Sampler0,texCoord0)*255.0));
    if(cgTag.a==255 && cgTag.g==246 && cgTag.b>=220 && cgTag.b<=225) discard;
    if(cgTag.a==255 && cgTag.b==213) {
        if(cgTag.g==246 || (cgTag.g==247 && cgTag.r==251)) discard;
        if(cgTag.g==245 && cgTag.r>=42 && cgTag.r<=212) {
            int cgBlockId=int(round((float(cgTag.r)-32.0)/10.0));
            color=vec4(palette[cgBlockId-1],cgBlockId==1?0.10:(cgBlockId==18?0.50:0.24))*vertexColor*ColorModulator;
        }
    }
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

void main() {
    if (ProjMat[3][3] == 0.0 && cgEnabled(ivec2(ScreenSize)) && gl_FragCoord.y < float(cgRows(ivec2(ScreenSize)))) discard;
    cgOriginalMain();
}
