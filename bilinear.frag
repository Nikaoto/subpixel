#pragma language glsl3

uniform vec2 texture_size;

// Manual bilinear filtering.
vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
{
    vec2 texel_size = 1.0 / texture_size;

    vec2 xy = uv * texture_size - 0.5;
    vec2 xy_floor = floor(xy);
    vec2 f = fract(xy);

    vec4 p00 = texture(tex, (xy_floor + vec2(0.0, 0.0) + 0.5) * texel_size);
    vec4 p10 = texture(tex, (xy_floor + vec2(1.0, 0.0) + 0.5) * texel_size);
    vec4 p01 = texture(tex, (xy_floor + vec2(0.0, 1.0) + 0.5) * texel_size);
    vec4 p11 = texture(tex, (xy_floor + vec2(1.0, 1.0) + 0.5) * texel_size);

    vec4 pX0 = mix(p00, p10, f.x);
    vec4 pX1 = mix(p01, p11, f.x);
    vec4 pXX = mix(pX0, pX1, f.y);
    return pXX * color;
}
