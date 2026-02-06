shader_type canvas_item;

// 1.0 is the original alpha from your theme
// 0.0 is invisible, 2.0 doubles the transparency (clamped at 1.0)
uniform float alpha_multiplier : hint_range(0.0, 5.0) = 1.0;

void fragment() {
    // Get the color and alpha directly from the Panel/StyleBox
    vec4 theme_color = COLOR;
    
    // Multiply ONLY the Alpha channel
    theme_color.a *= alpha_multiplier;
    
    // Clamp it to 1.0 so it doesn't behave weirdly with blending
    theme_color.a = clamp(theme_color.a, 0.0, 1.0);
    
    COLOR = theme_color;
}