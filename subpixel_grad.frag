#pragma language glsl3

uniform vec2 texture_size;

// Subpixel sampling using gradients (dFdx and dFdy) to calculate the size of
// the screen pixel.
// Borrowed from by CptPotato: https://github.com/CptPotato/GodotThings
vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
{
    vec2 texel_size = vec2(1.0) / texture_size;

    vec2 ddx = dFdx(uv);
    vec2 ddy = dFdy(uv);
    vec2 fw = abs(ddx) + abs(ddy); // size of the screen pixel in uv

    vec2 xy = uv * texture_size;
    vec2 xy_floor = round(xy) - vec2(0.5);
    vec2 f = xy - xy_floor;
    vec2 f_uv = f * texel_size - vec2(0.5) * texel_size;

    f = clamp(f_uv / fw + vec2(0.5), 0.0, 1.0);

    uv = xy_floor * texel_size;

    // Since we already have the derivatives, might as well use textureGrad
    // instead of texture2D to improve performance. No other reason.
    return color * textureGrad(tex, uv + f * texel_size, ddx, ddy);
}
