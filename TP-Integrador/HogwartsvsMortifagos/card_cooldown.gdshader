shader_type canvas_item;

// Card cooldown recharge sweep and affordability shader.
// Sweeps from bottom to top, blurring and dimming the uncharged section
// and revealing the real crisp color as cooldown progresses.
// When available, shows the real image with no darkening filter.

uniform float progress : hint_range(0.0, 1.0) = 1.0;
uniform bool is_affordable = true;
uniform bool is_selected = false;
uniform float blur_size : hint_range(0.0, 0.05) = 0.016;
uniform float dimmed_brightness : hint_range(0.0, 1.0) = 0.48;
uniform float dimmed_saturation : hint_range(0.0, 1.0) = 0.50;
uniform float unaffordable_brightness : hint_range(0.0, 1.0) = 0.45;
uniform vec4 sweep_line_color : source_color = vec4(1.0, 0.94, 0.55, 1.0);
uniform float sweep_line_thickness : hint_range(0.0, 0.05) = 0.018;
uniform vec4 selected_color : source_color = vec4(0.65, 1.0, 0.65, 1.0);

void fragment() {
	float sweep_y = 1.0 - progress;
	vec4 base_color = texture(TEXTURE, UV);

	if (progress < 1.0 && UV.y < sweep_y) {
		vec2 b = vec2(blur_size, blur_size * 1.4);
		vec4 sum = texture(TEXTURE, UV) * 0.20;
		sum += texture(TEXTURE, UV + vec2(b.x, 0.0)) * 0.12;
		sum += texture(TEXTURE, UV - vec2(b.x, 0.0)) * 0.12;
		sum += texture(TEXTURE, UV + vec2(0.0, b.y)) * 0.12;
		sum += texture(TEXTURE, UV - vec2(0.0, b.y)) * 0.12;
		sum += texture(TEXTURE, UV + b) * 0.08;
		sum += texture(TEXTURE, UV - b) * 0.08;
		sum += texture(TEXTURE, UV + vec2(b.x, -b.y)) * 0.08;
		sum += texture(TEXTURE, UV + vec2(-b.x, b.y)) * 0.08;

		float gray = dot(sum.rgb, vec3(0.299, 0.587, 0.114));
		vec3 desat = mix(vec3(gray), sum.rgb, dimmed_saturation);
		vec3 dimmed_rgb = desat * dimmed_brightness;

		float dist_to_sweep = sweep_y - UV.y;
		if (progress > 0.0 && dist_to_sweep < sweep_line_thickness && dist_to_sweep >= 0.0) {
			float glow = 1.0 - (dist_to_sweep / sweep_line_thickness);
			dimmed_rgb = mix(dimmed_rgb, sweep_line_color.rgb, glow * sweep_line_color.a);
		}

		COLOR = vec4(dimmed_rgb, sum.a);
	} else {
		if (!is_affordable) {
			float gray = dot(base_color.rgb, vec3(0.299, 0.587, 0.114));
			vec3 desat = mix(vec3(gray), base_color.rgb, 0.5);
			COLOR = vec4(desat * unaffordable_brightness, base_color.a);
		} else if (is_selected) {
			COLOR = vec4(base_color.rgb * selected_color.rgb, base_color.a);
		} else {
			COLOR = base_color;
		}
	}
}
