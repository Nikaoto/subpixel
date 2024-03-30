// Manual nearest neighbor filtering.

#pragma language glsl3

uniform vec2 textureSize;
uniform float scale;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
{
    uv /= scale;
    uv = (floor(uv * textureSize) + 0.5) / textureSize;
    return color * texture2D(tex, uv);
}
