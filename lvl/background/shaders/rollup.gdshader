shader_type canvas_item;

// Scrolling parameters
uniform vec2 direction = vec2(1.0, 0.0);
uniform float speed : hint_range(0.0, 5.0) = 1.0;

// Pulsation parameters
uniform float pulse_speed : hint_range(0.1, 10.0) = 1.0;
uniform float min_brightness : hint_range(0.0, 1.0) = 0.5;
uniform float max_brightness : hint_range(0.0, 2.0) = 1.0; // Allow values > 1 for overbrightening

// Edge fadeout parameters
uniform float fadeout_distance : hint_range(1.0, 100.0) = 16.0; // Distance in pixels for edge fadeout

// Advanced features
uniform bool use_smooth_pulse = false; // Toggle for smoother pulsation
uniform float phase_offset : hint_range(0.0, 6.28318) = 0.0; // Phase shift for timing control
uniform vec3 tint_color : source_color = vec3(1.0, 1.0, 1.0); // Color tinting during pulse

void fragment() {
    // Scrolling logic with wrapped UVs to prevent stretching
    vec2 move = direction * TIME * speed;
    vec2 scrolled_uv = fract(UV + move); // fract() keeps UVs in [0,1] range
    vec4 texture_color = texture(TEXTURE, scrolled_uv);

    // Enhanced pulsation with optional smoothing
    float pulse_wave;
    if (use_smooth_pulse) {
        // Smoother pulsation using smoothstep
        float raw_pulse = 0.5 + 0.5 * sin(TIME * pulse_speed + phase_offset);
        pulse_wave = smoothstep(0.0, 1.0, raw_pulse);
    } else {
        // Standard sine wave pulsation
        pulse_wave = 0.5 + 0.5 * sin(TIME * pulse_speed + phase_offset);
    }

    // Calculate final brightness
    float brightness = min_brightness + (max_brightness - min_brightness) * pulse_wave;

    // Edge fadeout calculation
    vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE; // Get screen dimensions in pixels
    vec2 pixel_pos = UV * screen_size; // Current pixel position

    // Calculate distance from edges
    float edge_fade = 1.0;
    float left_fade = smoothstep(0.0, fadeout_distance, pixel_pos.x);
    float right_fade = smoothstep(0.0, fadeout_distance, screen_size.x - pixel_pos.x);
    float top_fade = smoothstep(0.0, fadeout_distance, pixel_pos.y);
    float bottom_fade = smoothstep(0.0, fadeout_distance, screen_size.y - pixel_pos.y);

    // Combine all edge fades
    edge_fade = left_fade * right_fade * top_fade * bottom_fade;

    // Apply brightness and optional color tinting
    COLOR.rgb = texture_color.rgb * brightness * tint_color;
    COLOR.a = texture_color.a * edge_fade; // Apply edge fadeout to alpha
}