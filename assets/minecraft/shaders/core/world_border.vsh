#version 330
#extension GL_ARB_separate_shader_objects : require
#include <connected_glass:viewport.glsl>

#include <minecraft:dynamictransforms.glsl>
#include <minecraft:projection.glsl>

layout(location = 0) in vec3 Position;
layout(location = 1) in vec2 UV0;

layout(location = 0) out vec2 texCoord0;

void cgOriginalMain() {
    vec3 pos = Position + ModelOffset;
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

    texCoord0 = (TextureMat * vec4(UV0, 0.0, 1.0)).xy;
}

void main() {
    cgOriginalMain();
    if (ProjMat[3][3] == 0.0 && cgEnabled(ivec2(ScreenSize))) {
        float scale=cgScale(ivec2(ScreenSize));
        gl_Position.y=gl_Position.y*scale+gl_Position.w*(1.0-scale);
    }
}
