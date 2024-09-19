shader_type canvas_item;

void fragment() {
    // Sample the texture color
    vec4 tex = texture(TEXTURE, UV);

    // Set the initial fragment color to the texture color
    COLOR = tex;

    // Calculate the distance from the closest edge (either horizontal or vertical)
    float dist_left = UV.x;          // Distance from the left edge
    float dist_right = 1.0 - UV.x;   // Distance from the right edge
    float dist_top = UV.y;           // Distance from the top edge
    float dist_bottom = 1.0 - UV.y;  // Distance from the bottom edge

    // Find the minimum distance to any edge
    float edge_dist = min(min(dist_left, dist_right), min(dist_top, dist_bottom));

    // Adjust these values to control how far the glow extends into the sprite
    float glow_start = 0.001;  // Adjust this value to change where the glow starts
    float glow_end = 0.1;   // Adjust this value to change where the glow ends

    // Smoothstep to control the falloff near the edges
    float edge_glow = smoothstep(glow_start, glow_end, edge_dist);  // Stronger near edges

    // If the texture's alpha is above a threshold, apply the edge glow effect
    if (tex.a > 0.1) {
        COLOR.rgb += (1.0 - edge_glow) * vec3(0.2, 0.5, 1.0); // Softer glow from edges inward
    }
}
