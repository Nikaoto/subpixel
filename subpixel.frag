#pragma language glsl3

uniform vec2 texture_size;
uniform float scale;

// A mix of nearest neighbor and bilinear that reduces jittering for pixelart.
vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
{
    uv /= scale;
    vec2 texel_size = vec2(1.0) / texture_size;

    uv -= texel_size * vec2(0.5);
    vec2 uvPixels = uv * texture_size;
    vec2 deltaPixel = fract(uvPixels) - vec2(0.5);
    vec2 ddxy = fwidth(uvPixels);
    vec2 mip = log2(ddxy) - 0.5;
    return color * textureLod(tex, uv + (clamp(deltaPixel / ddxy, 0.0, 1.0) - deltaPixel) * texel_size, min(mip.x, mip.y));

    // vec2 ddx = dFdx(uv);
    // vec2 ddy = dFdy(uv);
    // vec2 lxy = sqrt(ddx * ddx + ddy * ddy); // size of the screen pixel in uv

    // vec2 xy = uv * texture_size;
    // vec2 xy_floor = round(xy) - vec2(0.5);
    // vec2 f = xy - xy_floor;
    // vec2 f_uv = f * texel_size - vec2(0.5) * texel_size;

    // f = clamp(f_uv / lxy + vec2(0.5), 0.0, 1.0);

    // uv = xy_floor * texel_size;

    // // Since we already have the derivatives, might as well use textureGrad
    // // instead of texture2D to improve performance. No other reason.
    // return textureGrad(tex, uv + f * texel_size, ddx, ddy);


    /*// Calculate xmin, xmax, ymin and ymax using the gradients
    float umin = uv.x - 0.5 * dFdx(uv).x;
    float umax = uv.x + 0.5 * dFdx(uv).x;
    float xmin = umin * texture_size.x;
    float xmax = umax * texture_size.x;
    float vmin = uv.y - 0.5 * dFdy(uv).y;
    float vmax = uv.y + 0.5 * dFdy(uv).y;
    float ymin = vmin * texture_size.y;
    float ymax = vmax * texture_size.y;

    // Preconditioning the uv coordinates
    if (floor(xmin) == floor(xmax))
        uv.x = (floor(uv.x * texture_size.x) + 0.5) / texture_size.x;
    if (floor(ymin) == floor(ymax))
        uv.y = (floor(uv.y * texture_size.y) + 0.5) / texture_size.y;

    vec2 f = fract(texture_size * uv);

    // Offsets for the four closest texels
    vec2 off;
    if (f.x > 0.5)
        off.x = 1.0;
    else if(f.x < 0.5)
        off.x = -1.0;
    else
        off.x = 0.0;

    if (f.y > 0.5)
        off.y = 1.0;
    else if (f.y < 0.5)
        off.y = -1.0;
    else
        off.y = 0.0;

    off *= texel_size;

    // Sample four neighboring texels
    vec4 p00 = texture2D(tex, uv);
    vec4 p10 = texture2D(tex, uv + vec2(off.x, 0.0));
    vec4 p01 = texture2D(tex, uv + vec2(0.0,   off.y));
    vec4 p11 = texture2D(tex, uv + vec2(off.x, off.y));

    // Blend them accordingly
    vec4 pX0 = p00 * (1 - abs(f.x - 0.5)) + p10 * abs(f.x - 0.5);
    vec4 pX1 = p01 * (1 - abs(f.x - 0.5)) + p11 * abs(f.x - 0.5);
    vec4 pXX = pX0 * (1 - abs(f.y - 0.5)) + pX1 * abs(f.y - 0.5);

    return pXX * color;*/
}
