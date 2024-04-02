#pragma language glsl3

uniform vec2 texture_size;

// Based on CptPotato's smooth pixel filtering shader.
// Preconditions the uv for the default bilinear filter.
vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
{
    vec2 texel_size = vec2(1.0) / texture_size;

    uv -= texel_size * vec2(0.5);
    vec2 uv_pixels = uv * texture_size;
    vec2 delta_pixel = fract(uv_pixels) - vec2(0.5);
    vec2 ddxy = fwidth(uv_pixels);
    vec2 mip = log2(ddxy) - 0.5;
    return color * textureLod(
        tex,
        uv + (clamp(delta_pixel / ddxy, 0.0, 1.0) - delta_pixel) * texel_size,
        min(mip.x, mip.y)
    );
}
