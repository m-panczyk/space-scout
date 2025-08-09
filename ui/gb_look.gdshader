shader_type canvas_item;

uniform vec4 whiteColor : source_color = vec4(0.961, 0.980, 0.937, 1.0);
uniform vec4 lightGreyColor : source_color = vec4(0.549, 0.749, 0.039, 1.0);
uniform vec4 darkGreyColor : source_color = vec4(0.18, 0.451, 0.125, 1.0);
uniform vec4 blackColor : source_color = vec4(0.0, 0.247, 0.0, 1.0);

uniform bool enable_scanlines = false;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.5;
uniform float scanline_frequency : hint_range(1.0, 10.0) = 2.0;

float min4(float a, float b, float c, float d){
    return min(a, min(b, min(c, d)));
}

void fragment(){
    vec4 currentColor = texture(TEXTURE, UV);

    // Store the original alpha
    float originalAlpha = currentColor.a;

    float blackDistance = distance(currentColor, vec4(vec3(0.0), 1.0));
    float whiteDistance = distance(currentColor, vec4(vec3(1.0), 1.0));
    float lightGrayDistance = distance(currentColor, vec4(vec3(0.666), 1.0));
    float darkGrayDistance = distance(currentColor, vec4(vec3(0.333), 1.0));

    vec3 finalColor;

    if (whiteDistance == min4(whiteDistance, lightGrayDistance, darkGrayDistance, blackDistance)) {
        finalColor = whiteColor.rgb;
    } else if (blackDistance == min4(whiteDistance, lightGrayDistance, darkGrayDistance, blackDistance)) {
        finalColor = blackColor.rgb;
    } else if (darkGrayDistance == min4(whiteDistance, lightGrayDistance, darkGrayDistance, blackDistance)) {
        finalColor = darkGreyColor.rgb;
    } else if (lightGrayDistance == min4(whiteDistance, lightGrayDistance, darkGrayDistance, blackDistance)) {
        finalColor = lightGreyColor.rgb;
    } else {
        finalColor = whiteColor.rgb;
    }

    // Apply scanlines if enabled
    if (enable_scanlines) {
        float scanline = sin(UV.y * PI * 2.0 * scanline_frequency * TEXTURE_PIXEL_SIZE.y * 1000.0);
        scanline = (scanline + 1.0) * 0.5; // Normalize to 0-1 range
        scanline = mix(1.0 - scanline_strength, 1.0, scanline);
        finalColor *= scanline;
    }

    COLOR = vec4(finalColor, originalAlpha);
}