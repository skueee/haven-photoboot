// credit : https://www.youtube.com/watch?v=oVyGHeYWYU0

shader_type canvas_item;

uniform sampler2D camera_y;
uniform sampler2D camera_CbCr;
uniform float saturation : hint_range(0.0, 3.0) = 1.0;

void fragment() {
	vec3 color;
	color.r = texture(camera_y, UV).r;
	color.gb = texture(camera_CbCr, UV).rg - vec2(0.5, 0.5);
	
	// YCbCr -> SRGB conversion
	// Using BT.709 which is the standard for HDTV
	color.rgb = mat3(
						vec3(1.00000, 1.00000, 1.00000),
						vec3(0.00000, -0.18732, 1.85560),
						vec3(1.57481, -0.46813, 0.00000)) *
				color.rgb;
				
	float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	color.rgb = mix(vec3(gray), color.rgb, saturation);
	
	COLOR = vec4(color, 1.0);
}