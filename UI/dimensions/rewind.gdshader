shader_type canvas_item;

uniform float pixelsize = 0.01;

void fragment() {
	if ((COLOR.r + COLOR.g + COLOR.b) / 3.0 < 0.7 && 1.0 / (COLOR.r / COLOR.b / COLOR.g) > 0.1) {
		vec3 RED = vec3(.9,.1,.1), YELLOW = vec3(.9,.8,.1), GREEN = vec3(.1,.8,.1);
		
		COLOR.rgb = COLOR.rgb * 0.9 + vec3(
			min(min(max(4.0*abs(UV.x-.25),.5),max(4.0*abs(UV.x-.75),.5)),4.0*abs(UV.x-.5)),
			1.0-min(min(max(4.0*abs(UV.x-.25),.5),max(4.0*abs(UV.x-.75),.5)),4.0*abs(UV.x-.5)),
			0)*0.2;
		
		if(abs(UV.x - 0.1) < pixelsize * 3.0)
			COLOR.rgb = RED;
		if(abs(UV.x - 0.1 - mod(TIME,0.4)/2.0) < pixelsize * 3.0) {
			float k = mod(TIME,0.4) / 0.4;
			COLOR.rgb = k * COLOR.rgb + (1.0-k) * RED;
		}
		if(abs(UV.x - 0.9) < pixelsize * 3.0)
			COLOR.rgb = RED;
		if(abs(UV.x - 0.9 + mod(TIME,0.4)/2.0) < pixelsize * 3.0) {
			float k = mod(TIME,0.4) / 0.4;
			COLOR.rgb = k * COLOR.rgb + (1.0-k) * RED;
		}
		
		if(abs(UV.x - 0.2) < pixelsize * 3.0)
			COLOR.rgb = YELLOW;
		if(abs(UV.x - 0.2 - mod(TIME,0.4)/2.0) < pixelsize * 3.0) {
			float k = mod(TIME,0.4) / 0.4;
			COLOR.rgb = k * COLOR.rgb + (1.0-k) * YELLOW;
		}
		if(abs(UV.x - 0.8) < pixelsize * 3.0)
			COLOR.rgb = YELLOW;
		if(abs(UV.x - 0.8 + mod(TIME,0.4)/2.0) < pixelsize * 3.0) {
			float k = mod(TIME,0.4) / 0.4;
			COLOR.rgb = k * COLOR.rgb + (1.0-k) * YELLOW;
		}
		
		if(abs(UV.x - 0.3) < pixelsize * 3.0)
			COLOR.rgb = GREEN;
		if(abs(UV.x - 0.3 - mod(TIME,0.4)/2.0) < pixelsize * 3.0) {
			float k = mod(TIME,0.4) / 0.4;
			COLOR.rgb = k * COLOR.rgb + (1.0-k) * GREEN;
		}
		if(abs(UV.x - 0.7) < pixelsize * 3.0)
			COLOR.rgb = GREEN;
		if(abs(UV.x - 0.7 + mod(TIME,0.4)/2.0) < pixelsize * 3.0) {
			float k = mod(TIME,0.4) / 0.4;
			COLOR.rgb = k * COLOR.rgb + (1.0-k) * GREEN;
		}
	}
}
