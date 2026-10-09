shader_type canvas_item;

// Parchment base colors (taken from the CSS palette)
uniform vec4 parchment_top_color : source_color = vec4(0.961, 0.902, 0.784, 1.0);  // #f5e6c8
uniform vec4 parchment_middle_color : source_color = vec4(0.910, 0.835, 0.639, 1.0);   // #e8d5a3
uniform vec4 parchment_bottom_color : source_color = vec4(0.788, 0.663, 0.431, 1.0);   // #c9a96e
uniform vec4 ink_color : source_color = vec4(0.173, 0.094, 0.063, 1.0);             // #2c1810
uniform vec4 stain_color : source_color = vec4(0.545, 0.353, 0.169, 1.0);            // rgba(139, 90, 43)

// Texture and opacity parameters
uniform sampler2D map_texture : filter_linear, repeat_enable;
uniform float map_opacity : hint_range(0.0, 1.0) = 0.15;
// Infinite tiling scale (2.6667x1.0 keeps the exact 1024x1536 ratio on 1920x1080)
uniform vec2 map_scale = vec2(2.6667, 1.0);
uniform vec2 map_offset = vec2(0.0, 0.0);
uniform float ink_contrast : hint_range(0.5, 3.0) = 1.2;

// Vignette and stains
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.45;
uniform float vignette_radius : hint_range(0.1, 1.5) = 0.75;
uniform float stain_intensity : hint_range(0.0, 1.0) = 0.25;

// Procedural grain / noise
uniform float grain_intensity : hint_range(0.0, 0.2) = 0.035;

// Pseudo-random generator for the paper grain
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

// Helper for radial stains
float radial_stain(vec2 uv, vec2 center, vec2 radius, float softness) {
	vec2 d = (uv - center) / radius;
	float dist = dot(d, d);
	return smoothstep(1.0, 1.0 - softness, dist);
}

void fragment() {
	vec2 uv = UV;

	// 1. Base parchment gradient (180deg vertical)
	vec3 base_color;
	if (uv.y < 0.5) {
		base_color = mix(parchment_top_color.rgb, parchment_middle_color.rgb, uv.y * 2.0);
	} else {
		base_color = mix(parchment_middle_color.rgb, parchment_bottom_color.rgb, (uv.y - 0.5) * 2.0);
	}

	// 2. Subtle radial stains of aged paper
	float stains = 0.0;
	stains += radial_stain(uv, vec2(0.20, 0.50), vec2(0.35, 0.25), 0.6) * 0.15;
	stains += radial_stain(uv, vec2(0.80, 0.30), vec2(0.30, 0.20), 0.5) * 0.10;
	stains += radial_stain(uv, vec2(0.50, 0.80), vec2(0.35, 0.25), 0.6) * 0.12;
	base_color = mix(base_color, base_color * stain_color.rgb, stains * stain_intensity);

	// 3. Vignette (darkened edges with 16:9 aspect correction)
	vec2 centered_uv = (uv - vec2(0.5)) * vec2(1.777, 1.0);
	float center_distance = length(centered_uv);
	float vignette = smoothstep(0.35, vignette_radius, center_distance) * vignette_intensity;
	base_color = mix(base_color, base_color * ink_color.rgb * 0.6, vignette);

	// 4. Marauder's Map texture (tiled infinitely / repeat_enable)
	vec2 map_uv = (uv + map_offset) * map_scale;
	vec4 map_tex = texture(map_texture, map_uv);

	// Isolate the dark ink strokes of the castle lines
	float luminance = dot(map_tex.rgb, vec3(0.299, 0.587, 0.114));
	float ink_factor = clamp(pow(clamp(1.0 - luminance, 0.0, 1.0), ink_contrast), 0.0, 1.0);
	base_color = mix(base_color, ink_color.rgb, ink_factor * map_opacity);

	// 5. Paper fiber grain / noise
	float noise = (hash(uv * 1000.0) - 0.5) * grain_intensity;
	base_color += vec3(noise);

	COLOR = vec4(clamp(base_color, 0.0, 1.0), 1.0);
}
