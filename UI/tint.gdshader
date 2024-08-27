shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 C = textureLod(screen_texture, SCREEN_UV, 0.0);
	if (true)
		COLOR *= C;
	else
		COLOR = vec4(0);
}