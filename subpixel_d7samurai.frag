#pragma language glsl3

uniform vec2 texture_size;

// Subpixel filtering based on d7samurai's version.
// Preconditions the uv coordinates for bilinear filtering.
vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
{
    vec2 scale = vec2(1.0, 1.0);

    vec2 xy = uv * texture_size;
    vec2 xy_center = floor(xy) + 0.5;
    xy_center += 1.0 - clamp((1.0 - fract(xy)) * scale, 0.0, 1.0);
    return color * texture(tex, xy_center / texture_size);
}
