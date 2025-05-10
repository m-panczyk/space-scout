shader_type canvas_item;
uniform vec2 direction;
uniform float speed;
uniform float pulse_speed = 1.0; // Controls how fast the pulsation happens
uniform float min_brightness = 0.5; // Minimum brightness during pulse (0.0 = completely dark)
uniform float max_brightness = 1.0; // Maximum brightness during pulse

void fragment() {
    // Original scrolling logic
    vec2 move = direction * TIME * speed;
    vec4 texture_color = texture(TEXTURE, UV+move);

    // Pulsating dimming effect using a sine wave
    float pulse = min_brightness + (max_brightness - min_brightness) * (0.5 + 0.5 * sin(TIME * pulse_speed));

    // Apply the brightness pulsation to only RGB components, keeping original alpha
    COLOR.rgb = texture_color.rgb * pulse;
    COLOR.a = texture_color.a; // Preserve original alpha
}