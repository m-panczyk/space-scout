shader_type sky;

uniform float battery : hint_range(0.0, 1.0) = 1.0;
uniform float anchor : hint_range(-1.0, 1.0) = -0.5;
uniform float speed_scale : hint_range(0.1, 5.0) = 1.0;
uniform float grid_scale : hint_range(0.1, 10.0) = 1.0;
uniform float line_thickness : hint_range(0.01, 0.3) = 0.08;
uniform float secondary_line_thickness : hint_range(0.005, 0.15) = 0.03;
uniform float secondary_line_spacing : hint_range(2.0, 20.0) = 3.0;
uniform float fade_start_distance : hint_range(5.0, 50.0) = 15.0;
uniform float fade_end_distance : hint_range(1.0, 20.0) = 3.0;

uniform vec3 background_color : source_color = vec3(0.0, 0.1, 0.2);
uniform vec3 grid_color : source_color = vec3(1.0, 0.5, 1.0);

void sky() {
    COLOR = background_color;
    
    if (EYEDIR.y < -0.01) {
        // Natural perspective projection
        vec2 ground_pos = EYEDIR.xz / -EYEDIR.y;
        
        // Calculate distance for anti-aliasing
        float distance = length(ground_pos);
        
        // Apply your original parameters
        vec2 uv = ground_pos * grid_scale;
        uv.x += anchor;
        uv.y += TIME * speed_scale * (battery + 0.05);
        
        // Distance-based line thickness to prevent jittering - controllable fade
        float distance_fade = smoothstep(fade_start_distance, fade_end_distance, distance);
        float adaptive_thickness = line_thickness * (1.0 + distance * 0.05);
        float adaptive_fine_thickness = secondary_line_thickness * (1.0 + distance * 0.03);
        
        // Create main grid lines with adaptive thickness
        vec2 grid_lines = abs(fract(uv) - 0.5);
        float main_grid = smoothstep(adaptive_thickness, adaptive_thickness * 0.5, grid_lines.x) + 
                         smoothstep(adaptive_thickness, adaptive_thickness * 0.5, grid_lines.y);
        
        // Add secondary grid lines with better visibility
        vec2 fine_uv = uv * secondary_line_spacing;
        vec2 fine_lines = abs(fract(fine_uv) - 0.5);
        float fine_grid = (smoothstep(adaptive_fine_thickness, adaptive_fine_thickness * 0.5, fine_lines.x) + 
                          smoothstep(adaptive_fine_thickness, adaptive_fine_thickness * 0.5, fine_lines.y)) * 
                          0.6 * battery * distance_fade;
        
        float total_grid = clamp(main_grid + fine_grid, 0.0, 1.0);
        // Also fade the entire grid at extreme distances
        total_grid *= distance_fade;
        
        COLOR = mix(background_color, grid_color, total_grid);
    }
}