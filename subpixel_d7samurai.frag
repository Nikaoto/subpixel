// Subpixel filtering based on d7samurai's version.
// Preconditions the uv coordinates for bilinear filtering.

#pragma language glsl3

uniform vec2 textureSize;
uniform float scale;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
{
    uv /= scale;

    vec2 xy = uv * textureSize;
    vec2 xy_center = floor(xy) + 0.5;
    xy_center += 1.0 - clamp((1.0 - fract(xy)) * scale, 0.0, 1.0);
    return color * texture2D(tex, xy_center / textureSize);
}
