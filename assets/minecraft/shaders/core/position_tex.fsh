#version 330
#extension GL_ARB_separate_shader_objects : require
#include <connected_glass:viewport.glsl>

#include <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

layout(location = 0) in vec2 texCoord0;

layout(location = 0) out vec4 fragColor;

void cgOriginalMain() {
    vec4 color = texture(Sampler0, texCoord0);
    if (color.a == 0.0) {
        discard;
    }
    fragColor = color * ColorModulator;
}

void main() {
    if (ProjMat[3][3] == 0.0 && cgEnabled(ivec2(ScreenSize)) && gl_FragCoord.y < float(cgRows(ivec2(ScreenSize)))) discard;
    cgOriginalMain();
}
