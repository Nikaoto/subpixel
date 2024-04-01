uniform vec2 vertScale;

vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    vec4 scaled_position = vec4(vertex_position.xy * vertScale, vertex_position.z, 1.0);
    return transform_projection * scaled_position;
}
