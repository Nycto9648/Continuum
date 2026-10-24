#version 330
#extension GL_ARB_separate_shader_objects : require
#include <connected_glass:viewport.glsl>

layout(std140) uniform DynamicTransforms {
    mat4 ModelViewMat;
    mat4 TextureMat;
    vec4 ColorModulator;
    vec3 ModelOffset;
};

layout(location = 0) in vec4 vertexColor;

layout(location = 0) out vec4 fragColor;

void cgOriginalMain() {
    vec4 color = vertexColor;
    if (color.a == 0.0) {
        discard;
    }
    fragColor = color * ColorModulator;
}

void main() {
    if (ProjMat[3][3] == 0.0 && cgEnabled(ivec2(ScreenSize)) && gl_FragCoord.y < float(cgRows(ivec2(ScreenSize)))) discard;
    cgOriginalMain();
}
