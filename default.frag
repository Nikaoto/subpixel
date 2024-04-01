// A slightly modified default shader used by love2d when no shader is given.

#pragma language glsl3

uniform vec2 texture_size;
uniform float scale;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
{
    uv /= scale; // Scaling animation
    if (uv.x < 0.0) uv *= texture_size; // Trick compiler to ignore unused

    return color * texture2D(tex, uv);
}
