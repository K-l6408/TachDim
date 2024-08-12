shader_type canvas_item;

const vec4 WHITE = vec4(1.0);
uniform vec2 refloffset = vec2(20, 10);
uniform vec2 refroffset = vec2(1, 1);
uniform vec4 refrcolor = vec4(1.0);
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_enable, filter_nearest;

void fragment() {
	vec4 adjColor = texture(TEXTURE, UV + TEXTURE_PIXEL_SIZE * refroffset);
	if (adjColor.a < 0.1 && COLOR.a > 0.1) COLOR = refrcolor;
	else COLOR = texture(SCREEN_TEXTURE, mod(UV + COLOR.a * refloffset * SCREEN_PIXEL_SIZE, vec2(1)));
}
