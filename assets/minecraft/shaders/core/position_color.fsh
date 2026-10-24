#version 330
#extension GL_ARB_separate_shader_objects : require
#include <connected_glass:viewport.glsl>

#include <minecraft:dynamictransforms.glsl>
#include <minecraft:oit.glsl>

layout(location = 0) in vec4 vertexColor;

#ifndef OIT_ALPHA_ONLY
layout(location = 0) out vec4 fragColor;
#endif

vec4 calculateFinalColor(vec4 color) {
    #ifdef OIT_ACCUMULATE
    color = sampleColorForAccumulation(color);
    #endif
    return color;
}

void cgOriginalMain() {
    vec4 color = vertexColor;
    if (color.a == 0.0) {
        discard;
    }

    color *= ColorModulator;

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
