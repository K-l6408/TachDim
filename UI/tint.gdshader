shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec4 replace : source_color;

void fragment() {
	vec3 C = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	if (distance(C, replace.rgb) < 0.7)
		COLOR.rgb = C * 0.7 + COLOR.rgb * 0.3;
	else
		COLOR = vec4(0);
}