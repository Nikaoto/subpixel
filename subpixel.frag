uniform ivec2 textureSize;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
{
    float x = floor(textureSize.x * uv.x);
    float y = floor(textureSize.y * uv.y);

    //vec2 top = vec2texture2D(tex, x-1);

    vec4 col = texture2D(
        tex,
        vec2(x / textureSize.x, y / textureSize.y)
    );
    return col * color;
}
