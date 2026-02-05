shader_type canvas_item;

// Liquid Glass UI - by sentinelcmd

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur : hint_range(0.0, 8.0) = 3.5;
uniform float warp_intensity : hint_range(0.0, 0.1) = 0.025;
uniform float strength_x : hint_range(0.0, 50.0) = 12.0;
uniform float strength_y : hint_range(0.0, 50.0) = 12.0;
uniform float offset_x : hint_range(-1.0, 1.0) = 0.0;
uniform float offset_y : hint_range(-1.0, 1.0) = 0.0;
uniform float corner_radius : hint_range(0.0, 200.0) = 16.0;
uniform float edge_smoothness : hint_range(0.5, 3.0) = 1.0;
uniform vec4 tint : source_color = vec4(0.95, 0.97, 1.0, 0.12);
uniform vec4 edge_highlight : source_color = vec4(1.0, 1.0, 1.0, 0.3);
uniform float edge_width : hint_range(0.0, 10.0) = 1.5;
uniform float chromatic_strength : hint_range(0.0, 5.0) = 5.0;

float rounded_box(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + r;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

void fragment() {
    vec2 size = abs(vec2(1.0 / dFdx(UV.x), 1.0 / dFdy(UV.y)));
    vec2 half_size = size * 0.5;
    vec2 pixel = UV * size;
    vec2 centered = pixel - half_size;
    float max_radius = min(half_size.x, half_size.y);
    float r = clamp(corner_radius, 0.0, max_radius);
    float sdf = rounded_box(centered, half_size, r);
    float alpha = 1.0 - smoothstep(-edge_smoothness, edge_smoothness, sdf);

    if (alpha < 0.001) {
        discard;
    }

    float max_dist = min(half_size.x, half_size.y) * 0.5;
    float w = clamp(-sdf / max_dist, 0.0, 1.0);
    vec2 uv_dir = length(centered) > 0.001 ? normalize(centered) : vec2(0.0, 1.0);

    float exp_x = exp(-strength_x * pow(w + offset_x, 2.0));
    float exp_y = exp(-strength_y * pow(w + offset_y, 2.0));
    vec2 warp_offset = uv_dir * vec2(exp_x, exp_y) * warp_intensity;
    vec2 warped_uv = SCREEN_UV - warp_offset;

    float edge_proximity = 1.0 - w;
    vec2 chroma_offset = uv_dir * edge_proximity * chromatic_strength * SCREEN_PIXEL_SIZE;

    float bg_r = textureLod(screen_texture, warped_uv - chroma_offset, blur).r;
    float bg_g = textureLod(screen_texture, warped_uv, blur).g;
    float bg_b = textureLod(screen_texture, warped_uv + chroma_offset, blur).b;
    vec3 bg = vec3(bg_r, bg_g, bg_b);

    vec3 color = mix(bg, tint.rgb, tint.a);

    float edge = 1.0 - smoothstep(0.0, edge_width, -sdf);
    edge *= step(sdf, 0.0);
    color = mix(color, edge_highlight.rgb, edge * edge_highlight.a);
    color += vec3(smoothstep(0.4, 0.0, UV.y) * 0.08 * w);

    COLOR = vec4(color, alpha);
}