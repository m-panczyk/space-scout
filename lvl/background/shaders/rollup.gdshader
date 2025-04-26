shader_type canvas_item;

uniform vec2 direction;
uniform float speed;

void fragment() {
	vec2 move = direction * TIME * speed;
	COLOR = texture(TEXTURE, UV+move);
}
