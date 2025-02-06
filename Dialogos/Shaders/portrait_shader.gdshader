shader_type canvas_item;

uniform float darkness : hint_range(0.0, 1.0) = 0.6; // Nivel de oscurecimiento

void fragment() {
    vec4 portrait = texture(TEXTURE, UV); // Obtiene el color del portrait
    float alpha = portrait.a; // Obtiene la transparencia del portrait

    // Si la imagen es visible (no transparente), oscurecemos
    vec3 darkened_color = mix(portrait.rgb, vec3(0.0), darkness);
    COLOR = vec4(darkened_color, alpha);
}
