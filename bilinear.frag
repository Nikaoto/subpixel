// Manual bilinear filtering.

#pragma language glsl3

uniform vec2 textureSize;
uniform float scale;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
{
    uv /= scale;

    vec2 texelSize = 1.0 / textureSize;

    vec2 xy = uv * textureSize - 0.5;
    vec2 xy_floor = floor(xy);
    vec2 f = fract(xy);

    vec4 p00 = texture2D(tex, (xy_floor + vec2(0.0, 0.0) + 0.5) * texelSize);
    vec4 p10 = texture2D(tex, (xy_floor + vec2(1.0, 0.0) + 0.5) * texelSize);
    vec4 p01 = texture2D(tex, (xy_floor + vec2(0.0, 1.0) + 0.5) * texelSize);
    vec4 p11 = texture2D(tex, (xy_floor + vec2(1.0, 1.0) + 0.5) * texelSize);

    vec4 pX0 = mix(p00, p10, f.x);
    vec4 pX1 = mix(p01, p11, f.x);
    vec4 pXX = mix(pX0, pX1, f.y);
    return pXX * color;
}
