#version 330
#extension GL_ARB_separate_shader_objects : require
#include <continuum:renderer.glsl>

#include <minecraft:dynamictransforms.glsl>

layout(location = 0) out vec4 fragColor;

void cgOriginalMain() {
    fragColor = ColorModulator;
}

void main() {
    if (ProjMat[3][3] == 0.0 && cgEnabled(ivec2(ScreenSize)) && gl_FragCoord.y < float(cgRows(ivec2(ScreenSize)))) discard;
    cgOriginalMain();
}
