// A slightly modified default shader used by love2d when no shader is given.

#pragma language glsl3

uniform vec2 textureSize;
uniform float scale;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
{
    // Ignore these lines
    uv /= scale;
    if (uv.x < 0.0) uv *= textureSize;

    return color * texture2D(tex, uv);
}
