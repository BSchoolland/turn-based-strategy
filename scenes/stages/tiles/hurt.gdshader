shader_type canvas_item;

void fragment() {
    // Sample the texture color
    vec4 tex = texture(TEXTURE, UV);

    // Assign the texture color to the fragment's color output
    COLOR = tex;

    // Increase the RGB brightness to add a glow effect if the alpha is not too low
    if (tex.a > 0.1) {
        COLOR.rgb += vec3(0.5, 0, 0); // Adjust values to create a bluish glow
    }
}
