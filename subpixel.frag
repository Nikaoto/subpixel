#pragma language glsl3

uniform vec2 texture_size;
uniform vec2 scale;

// A mix of nearest neighbor and bilinear sampling that reduces jittering for
// pixelart. For educational purposes, it is verbose and unoptimized.
//
// Follows the method described by cmuratori in "Handmade Hero Chat 018":
// https://youtu.be/Yu8k7a1hQuU?si=-6iUHnSHjCQjFfZ7&t=4880
//
// The first half of this shader preconditions the uv coordinates for the second
// half of the shader (which is a simple bilinear filter). We do this by
// snapping the uv to texel centers for pixels which are completely inside the
// texel. For the pixels bordering the texel edges, their uvs are placed at the
// point where the bilinear filter will blend according to coverage.
//
// Since we manually do a bilinear filter, the texture filter in love2d can be
// set to the "nearest" setting and it will still work.
//
// For a production-ready, optimized and terse version, look at
// 'subpixel_grad.frag' or 'subpixel_d7samurai.frag'.
vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
{
    // fwidth stands for "fragment width". According to OpenGL specs, it gives
    // us the "sum of the absolute derivatives in x and y using local
    // differencing for the input argument". Simply put, this gives us the
    // change in uv if the fragment were to move by 1 pixel. In even simpler
    // terms, this is the pixel size in uv.
    //
    // It can also be calculated by:
    //     abs(dFdx(uv)) + abs(dFdy(uv))
    //
    // Where dFdx(uv) and dFdy(uv) give us the rates of change of pixel x and y
    // coords in uv. In other words, the width and the height of the screen
    // pixel in uv.
    vec2 fw = fwidth(uv);

    // When the texture is rendered at smaller sizes (when the pixel size is
    // larger than the texel size), we can skip the preconditioning and just do
    // a bilinear filter. Without this, we get artifacts at small sizes.
    if (fw.x < 1.0/texture_size.x && fw.y < 1.0/texture_size.y) {

        // We can use the pixel size (fw) to calculate the edges of the pixel in
        // uv so we can do bounds checking later.
        vec2 mins = (uv - 0.5 * fw) * texture_size;
        vec2 maxes = (uv + 0.5 * fw) * texture_size;

        // When the pixel is completely inside the texel horizontally, snap the
        // u value to the center.
        if (mins.x >= floor(uv.x * texture_size.x) &&
            maxes.x < ceil(uv.x * texture_size.x)) {
            uv.x = (floor(mins.x) + 0.5) / texture_size.x;
        } else {
            // Pixel is at the edge. Blend between the two texels based on
            // coverage.
            float right_side_coverage = fract(maxes.x);
            float sum = maxes.x - mins.x;
            float left_offset = (right_side_coverage / sum);
            float u_tex_center = floor(mins.x) + 0.5;
            uv.x = (u_tex_center + left_offset) / texture_size.x;
        }

        // When the pixel is completely inside the texel vertically, snap the v
        // value to the center.
        if (mins.y >= floor(uv.y * texture_size.y) &&
            maxes.y < ceil(uv.y * texture_size.y)) {
            uv.y = (floor(mins.y) + 0.5) / texture_size.y;
        } else {
            // Pixel is at the edge. Blend between the two texels based on
            // coverage.
            float bottom_side_coverage = fract(maxes.y);
            float sum = maxes.y - mins.y;
            float top_offset = bottom_side_coverage / sum;
            float u_tex_center = floor(mins.y) + 0.5;
            uv.y = (u_tex_center + top_offset) / texture_size.y;
        }
    }

    // Bilinear filter
    vec2 xy = texture_size * uv - 0.5;
    vec2 f = fract(xy);
    vec2 xy_floor = floor(xy);

    // Sample four neighboring texels
    vec4 p00 = texture(tex, (xy_floor + vec2(0.0, 0.0) + 0.5) / texture_size);
    vec4 p10 = texture(tex, (xy_floor + vec2(1.0, 0.0) + 0.5) / texture_size);
    vec4 p01 = texture(tex, (xy_floor + vec2(0.0, 1.0) + 0.5) / texture_size);
    vec4 p11 = texture(tex, (xy_floor + vec2(1.0, 1.0) + 0.5) / texture_size);

    // Blend them accordingly
    vec4 pX0 = p00 * (1.0 - f.x) + p10 * f.x;
    vec4 pX1 = p01 * (1.0 - f.x) + p11 * f.x;
    vec4 pXX = pX0 * (1.0 - f.y) + pX1 * f.y;

    return pXX * color;
}
