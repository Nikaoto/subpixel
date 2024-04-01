// Manual nearest neighbor filtering.

#pragma language glsl3

uniform vec2 texture_size;
uniform float scale;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
{
    uv /= scale;
    uv = (floor(uv * texture_size) + 0.5) / texture_size;
    return color * texture2D(tex, uv);
}
