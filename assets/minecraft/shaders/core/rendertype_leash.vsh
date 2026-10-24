#version 330
#extension GL_ARB_separate_shader_objects : require
#include <connected_glass:viewport.glsl>

#include <minecraft:fog.glsl>
#include <minecraft:dynamictransforms.glsl>
#include <minecraft:projection.glsl>
#include <minecraft:sample_lightmap.glsl>

layout(location = 0) in vec3 Position;
layout(location = 1) in vec4 Color;
layout(location = 2) in ivec2 UV2;

uniform sampler2D Sampler2;

layout(location = 0) out float sphericalVertexDistance;
layout(location = 1) out float cylindricalVertexDistance;
layout(location = 2) flat out vec4 vertexColor;

void cgOriginalMain() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);
    vertexColor = Color * ColorModulator * sample_lightmap(Sampler2, UV2);
}

void main() {
    cgOriginalMain();
    if (ProjMat[3][3] == 0.0 && cgEnabled(ivec2(ScreenSize))) {
        float scale=cgScale(ivec2(ScreenSize));
        gl_Position.y=gl_Position.y*scale+gl_Position.w*(1.0-scale);
    }
}
