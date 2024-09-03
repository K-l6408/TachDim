shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec4 replace : source_color;

void fragment() {
	vec4 C = textureLod(screen_texture, SCREEN_UV, 0.0);
	if (distance(C, replace) < 0.5)
		COLOR = C * 0.7 + COLOR * 0.3;
	else
		COLOR = vec4(0);
}