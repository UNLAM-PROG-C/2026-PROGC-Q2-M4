shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float blur_radius : hint_range(0.0, 10.0) = 4.0;
uniform vec4 tint_color : source_color = vec4(0.04, 0.04, 0.07, 0.85);

void fragment() {
	vec2 pixel_size = SCREEN_PIXEL_SIZE * blur_radius;
	vec4 col = texture(screen_texture, SCREEN_UV);
	col += texture(screen_texture, SCREEN_UV + vec2(pixel_size.x, 0.0));
	col += texture(screen_texture, SCREEN_UV - vec2(pixel_size.x, 0.0));
	col += texture(screen_texture, SCREEN_UV + vec2(0.0, pixel_size.y));
	col += texture(screen_texture, SCREEN_UV - vec2(0.0, pixel_size.y));
	col /= 5.0;
	COLOR = mix(col, vec4(tint_color.rgb, 1.0), tint_color.a);
}
