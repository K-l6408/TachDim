shader_type canvas_item;

uniform float pixelsize = 0.01;
uniform float zoom = 1.0;
uniform vec4 ignore : source_color;
uniform bool disabled;

void fragment() {
	float uvx = (UV.x - 0.5) / zoom + 0.5;
	float psize = pixelsize / zoom;
	
	if (distance(COLOR, ignore) > 0.5 && !disabled) {
		vec3 RED = vec3(.9,.1,.1), YELLOW = vec3(.9,.9,.1), GREEN = vec3(.1,.9,.1);
		
		COLOR.rgb = COLOR.rgb * 0.7 + vec3(
			min(min(max(4.0*abs(uvx-.25),.5),max(4.0*abs(uvx-.75),.5)),4.0*abs(uvx-.5)),
			1.0-min(min(max(4.0*abs(uvx-.25),.5),max(4.0*abs(uvx-.75),.5)),4.0*abs(uvx-.5)),
			0)*0.3;
		
		if(abs(uvx - 0.1) < psize * 3.0)
			COLOR.rgb = RED;
		if(abs(uvx - 0.1 - mod(TIME,0.4)/2.0) < psize * 3.0) {
			float k = mod(TIME,0.4) / 0.4;
			COLOR.rgb = k * COLOR.rgb + (1.0-k) * RED;
		}
		if(abs(uvx - 0.9) < psize * 3.0)
			COLOR.rgb = RED;
		if(abs(uvx - 0.9 + mod(TIME,0.4)/2.0) < psize * 3.0) {
			float k = mod(TIME,0.4) / 0.4;
			COLOR.rgb = k * COLOR.rgb + (1.0-k) * RED;
		}
		
		if(abs(uvx - 0.2) < psize * 3.0)
			COLOR.rgb = YELLOW;
		if(abs(uvx - 0.2 - mod(TIME,0.4)/2.0) < psize * 3.0) {
			float k = mod(TIME,0.4) / 0.4;
			COLOR.rgb = k * COLOR.rgb + (1.0-k) * YELLOW;
		}
		if(abs(uvx - 0.8) < psize * 3.0)
			COLOR.rgb = YELLOW;
		if(abs(uvx - 0.8 + mod(TIME,0.4)/2.0) < psize * 3.0) {
			float k = mod(TIME,0.4) / 0.4;
			COLOR.rgb = k * COLOR.rgb + (1.0-k) * YELLOW;
		}
		
		if(abs(uvx - 0.3) < psize * 3.0)
			COLOR.rgb = GREEN;
		if(abs(uvx - 0.3 - mod(TIME,0.4)/2.0) < psize * 3.0) {
			float k = mod(TIME,0.4) / 0.4;
			COLOR.rgb = k * COLOR.rgb + (1.0-k) * GREEN;
		}
		if(abs(uvx - 0.7) < psize * 3.0)
			COLOR.rgb = GREEN;
		if(abs(uvx - 0.7 + mod(TIME,0.4)/2.0) < psize * 3.0) {
			float k = mod(TIME,0.4) / 0.4;
			COLOR.rgb = k * COLOR.rgb + (1.0-k) * GREEN;
		}
	}
}
