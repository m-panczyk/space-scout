shader_type canvas_item;

// Main colors
uniform vec4 background_color : source_color = vec4(0.05, 0.1, 0.2, 0.9);
uniform vec4 frame_color : source_color = vec4(0.0, 0.8, 1.0, 1.0);

// Frame properties
uniform float frame_width : hint_range(0.005, 0.03) = 0.008;
uniform float corner_radius : hint_range(0.0, 0.2) = 0.05;

// Animation
uniform float pulse_speed : hint_range(0.1, 3.0) = 0.8;

// Rounded rectangle distance function
float rounded_rect(vec2 p, vec2 size, float radius) {
    vec2 d = abs(p) - size + radius;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - radius;
}

void fragment() {
    vec2 uv = UV;
    vec2 center_uv = uv - 0.5;

    // Create tight rounded rectangle frame (reduced margins)
    float rect_size = 0.48; // Increased from 0.45 for tighter margins
    float outer_rect = rounded_rect(center_uv, vec2(rect_size), corner_radius);
    float inner_rect = rounded_rect(center_uv, vec2(rect_size - frame_width), corner_radius * 0.7);

    // Frame and inner masks
    float frame_mask = step(outer_rect, 0.0) * (1.0 - step(inner_rect, 0.0));
    float inner_mask = step(inner_rect, 0.0);

    // Simple pulse effect
    float pulse = sin(TIME * pulse_speed * 2.0) * 0.1 + 0.9;

    // Final color
    vec3 final_color = background_color.rgb * inner_mask;
    final_color = mix(final_color, frame_color.rgb * pulse, frame_mask);

    // Alpha
    float final_alpha = max(frame_mask, inner_mask * background_color.a);

    COLOR = vec4(final_color, final_alpha);
}