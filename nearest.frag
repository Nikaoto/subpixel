#pragma language glsl3

uniform vec2 texture_size;

// Manual nearest neighbor filtering.
vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
{
    uv = (floor(uv * texture_size) + 0.5) / texture_size;
    return color * texture2D(tex, uv);
}
