#version 330
#extension GL_ARB_separate_shader_objects : require
#include <connected_glass:viewport.glsl>

#include <minecraft:fog.glsl>
#include <minecraft:globals.glsl>
#include <minecraft:projection.glsl>
#include <minecraft:sample_lightmap.glsl>
#include <minecraft:terrainglobals.glsl>
#ifndef MULTIDRAW_TERRAIN
    #include <minecraft:chunksection.glsl>
#endif

layout(location = 0) in vec3 Position;
layout(location = 1) in vec4 Color;
layout(location = 2) in vec2 UV0;
layout(location = 3) in ivec2 UV2;
#ifdef MULTIDRAW_TERRAIN
layout(location = 4) in ivec3 ChunkPosition;
layout(location = 5) in float ChunkVisibility;
#endif

#ifndef OIT_ALPHA_ONLY
uniform sampler2D Sampler2;
#endif

layout(location = 0) out float sphericalVertexDistance;
layout(location = 1) out float cylindricalVertexDistance;
layout(location = 2) out vec4 vertexColor;
layout(location = 3) out vec2 texCoord0;
layout(location = 4) out float chunkVisibility;

uniform sampler2D Sampler0;
layout(location = 5) flat out int cgKind;
layout(location = 6) flat out int cgId;
layout(location = 7) out vec3 cgPosition;
layout(location = 8) flat out ivec3 cgCell;

void cgOriginalMain() {
    vec3 pos = Position + (ChunkPosition - CameraBlockPos) + CameraOffset;
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

    sphericalVertexDistance = fog_spherical_distance(pos);
    cylindricalVertexDistance = fog_cylindrical_distance(pos);
    #ifndef OIT_ALPHA_ONLY
    vertexColor = Color * sample_lightmap(Sampler2, UV2);
    #else
    vertexColor = Color;
    #endif
    texCoord0 = UV0;

    const float chunkFullyVisibleRange = 16.0;
    float dist = length(pos);
    chunkVisibility = mix(1.0, ChunkVisibility, clamp((dist - chunkFullyVisibleRange) / chunkFullyVisibleRange, 0.0, 1.0));

    ivec4 tag = ivec4(round(textureLod(Sampler0, UV0, 0.0) * 255.0));
    cgKind = 0; cgId = 0;
    cgPosition = Position;
    cgCell = ivec3(floor(Position)) + ChunkPosition - CameraBlockPos + ivec3(CG_GRID_HALF);
    if (tag.a == 255 && tag.b >= 220 && tag.b <= 225 && tag.g == 246 && tag.r >= 42 && tag.r <= 212) {
        cgKind=1; cgId=int(round((float(tag.r)-32.0)/10.0));
    } else if (tag.a == 255 && abs(tag.b - 213) <= 1) {
        if ((tag.g == 246 || tag.g == 245) && tag.r >= 42 && tag.r <= 212) {
            cgKind = tag.g == 246 ? 1 : 3; cgId = int(round((float(tag.r) - 32.0) / 10.0));
        } else if (tag.r == 251 && tag.g == 247) cgKind = 2;
    }
    if (cgKind == 1 || cgKind == 2) {
        ivec3 cell = ivec3(floor(Position)) + ChunkPosition - CameraBlockPos + ivec3(CG_GRID_HALF);
        vec2 corner = step(vec2(0.5), fract(Position.xy));
        if (cgKind == 1) {
            int face=tag.b-220;
            vec2 local=face<2?fract(Position.zy):(face<4?fract(Position.xz):fract(Position.xy));
            corner=step(vec2(0.5),local);
            if(face==1 || face==4) corner.x=1.0-corner.x;
            if(face==3) corner.y=1.0-corner.y;
            int index = cell.x + CG_GRID_SIZE * (cell.y + CG_GRID_SIZE * cell.z);
            vec2 pixel = vec2(index % int(ScreenSize.x), 1 + index / int(ScreenSize.x)) + corner;
            float brightness=clamp(dot(vertexColor.rgb,vec3(0.2126,0.7152,0.0722)),0.0,1.0);
            gl_Position = vec4(pixel / ScreenSize * 2.0 - 1.0, 0.9990+0.0009*brightness, 1.0);
            if (!cgEnabled(ivec2(ScreenSize)) || any(lessThan(cell, ivec3(0))) || any(greaterThanEqual(cell, ivec3(CG_GRID_SIZE))))
                gl_Position = vec4(2.0, 2.0, 2.0, 1.0);
        } else {
            vec2 pixel = vec2(corner.x * 44.0, corner.y);
            gl_Position = vec4(pixel / ScreenSize * 2.0 - 1.0, 0.99999, 1.0);
        }
    }
}

void main() {
    cgOriginalMain();
    if (ProjMat[3][3] == 0.0 && cgEnabled(ivec2(ScreenSize)) && cgKind != 1 && cgKind != 2) {
        float scale=cgScale(ivec2(ScreenSize));
        gl_Position.y=gl_Position.y*scale+gl_Position.w*(1.0-scale);
    }
}
