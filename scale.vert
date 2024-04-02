#pragma language glsl3

uniform vec2 scale;

vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    // vec4 center = vertex_position - vec4(0.5, 0.5, 0.0, 0.0);
    // vec4 scaled_position = vec4(center.xy * scale, center.z, 1.0);

    vec3 center = vertex_position.xyz;
    vec4 scaled = vec4(center.xy * scale, center.z, 1.0);
    return transform_projection * scaled;
}
