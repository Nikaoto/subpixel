#pragma language glsl3

uniform vec2 texture_size;

// Subpixel filtering based on d7samurai's version:
// https://www.shadertoy.com/view/MlB3D3
//
// Preconditions the uv coordinates for bilinear filtering.
vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
{
    vec2 xy = uv * texture_size;
    vec2 xy_final = floor(xy) + min(fract(xy) / fwidth(xy), 1.0) - 0.5;
    return color * texture(tex, xy_final / texture_size);
}
