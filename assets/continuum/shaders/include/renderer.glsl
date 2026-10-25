#ifndef CONTINUUM_RENDERER
#define CONTINUUM_RENDERER
#ifndef CG_POST
#include <minecraft:globals.glsl>
#include <minecraft:projection.glsl>
#endif
const int CG_GRID_SIZE = 64;
const int CG_GRID_HALF = CG_GRID_SIZE / 2;
int cgRows(ivec2 size) { return 1 + (CG_GRID_SIZE*CG_GRID_SIZE*CG_GRID_SIZE + max(size.x,1) - 1) / max(size.x,1); }
bool cgEnabled(ivec2 size) { return size.x >= 64 && size.y - cgRows(size) >= 64; }
float cgScale(ivec2 size) { return float(size.y-cgRows(size))/float(size.y); }
#endif
