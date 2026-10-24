#version 330
#extension GL_ARB_separate_shader_objects : require
#include <connected_glass:viewport.glsl>

#include <minecraft:fog.glsl>
#include <minecraft:dynamictransforms.glsl>

layout(location = 0) in float sphericalVertexDistance;
layout(location = 1) in float cylindricalVertexDistance;

layout(location = 0) out vec4 fragColor;

void cgOriginalMain() {
    fragColor = apply_fog(ColorModulator, sphericalVertexDistance, cylindricalVertexDistance, 0.0, FogSkyEnd, FogSkyEnd, FogSkyEnd, FogColor);
}

void main() {
    if (ProjMat[3][3] == 0.0 && cgEnabled(ivec2(ScreenSize)) && gl_FragCoord.y < float(cgRows(ivec2(ScreenSize)))) discard;
    cgOriginalMain();
}
