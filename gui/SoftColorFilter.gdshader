shader_type canvas_item;

// Retains the pixel-art palette while taking the harsh edge off its strongest blues.
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float saturation : hint_range(0.0, 1.0) = 0.78;
uniform float brightness : hint_range(0.5, 1.0) = 0.92;

void fragment() {
	vec4 source = texture(screen_texture, SCREEN_UV);
	float luma = dot(source.rgb, vec3(0.299, 0.587, 0.114));
	vec3 softened = mix(vec3(luma), source.rgb, saturation) * brightness;
	COLOR = vec4(softened, source.a);
}
