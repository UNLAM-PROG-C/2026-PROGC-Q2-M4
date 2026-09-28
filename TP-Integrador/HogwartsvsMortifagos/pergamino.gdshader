shader_type canvas_item;

// Colores base del pergamino (extraídos de la paleta CSS)
uniform vec4 color_pergamino_arriba : source_color = vec4(0.961, 0.902, 0.784, 1.0);  // #f5e6c8
uniform vec4 color_pergamino_medio : source_color = vec4(0.910, 0.835, 0.639, 1.0);   // #e8d5a3
uniform vec4 color_pergamino_abajo : source_color = vec4(0.788, 0.663, 0.431, 1.0);   // #c9a96e
uniform vec4 color_tinta : source_color = vec4(0.173, 0.094, 0.063, 1.0);             // #2c1810
uniform vec4 color_mancha : source_color = vec4(0.545, 0.353, 0.169, 1.0);            // rgba(139, 90, 43)

// Parámetros de textura y opacidad
uniform sampler2D mapa_texture : filter_linear, repeat_enable;
uniform float opacidad_mapa : hint_range(0.0, 1.0) = 0.15;
// Escala de repetición infinita (2.6667x1.0 mantiene la proporción exacta de 1024x1536 en 1920x1080)
uniform vec2 escala_mapa = vec2(2.6667, 1.0);
uniform vec2 desplazamiento_mapa = vec2(0.0, 0.0);
uniform float contraste_tinta : hint_range(0.5, 3.0) = 1.2;

// Viñeta y manchas
uniform float intensidad_vinieta : hint_range(0.0, 2.0) = 0.45;
uniform float radio_vinieta : hint_range(0.1, 1.5) = 0.75;
uniform float intensidad_manchas : hint_range(0.0, 1.0) = 0.25;

// Grano / Ruido procedural
uniform float intensidad_grano : hint_range(0.0, 0.2) = 0.035;

// Generador pseudo-aleatorio para el grano de papel
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

// Función auxiliar para manchas radiales
float mancha_radial(vec2 uv, vec2 centro, vec2 radio, float difuminado) {
	vec2 d = (uv - centro) / radio;
	float dist = dot(d, d);
	return smoothstep(1.0, 1.0 - difuminado, dist);
}

void fragment() {
	vec2 uv = UV;

	// 1. Gradiente base de pergamino (180deg vertical)
	vec3 base_color;
	if (uv.y < 0.5) {
		base_color = mix(color_pergamino_arriba.rgb, color_pergamino_medio.rgb, uv.y * 2.0);
	} else {
		base_color = mix(color_pergamino_medio.rgb, color_pergamino_abajo.rgb, (uv.y - 0.5) * 2.0);
	}

	// 2. Manchas radiales sutiles de papel envejecido
	float manchas = 0.0;
	manchas += mancha_radial(uv, vec2(0.20, 0.50), vec2(0.35, 0.25), 0.6) * 0.15;
	manchas += mancha_radial(uv, vec2(0.80, 0.30), vec2(0.30, 0.20), 0.5) * 0.10;
	manchas += mancha_radial(uv, vec2(0.50, 0.80), vec2(0.35, 0.25), 0.6) * 0.12;
	base_color = mix(base_color, base_color * color_mancha.rgb, manchas * intensidad_manchas);

	// 3. Viñeta (oscurecimiento en los bordes con corrección de relación 16:9)
	vec2 uv_centrada = (uv - vec2(0.5)) * vec2(1.777, 1.0);
	float dist_centro = length(uv_centrada);
	float vinieta = smoothstep(0.35, radio_vinieta, dist_centro) * intensidad_vinieta;
	base_color = mix(base_color, base_color * color_tinta.rgb * 0.6, vinieta);

	// 4. Textura del Mapa del Merodeador (concatenada infinitamente / repeat_enable)
	vec2 uv_mapa = (uv + desplazamiento_mapa) * escala_mapa;
	vec4 map_tex = texture(mapa_texture, uv_mapa);
	
	// Aislamos el trazo oscuro de tinta de las líneas del castillo
	float luminosidad = dot(map_tex.rgb, vec3(0.299, 0.587, 0.114));
	float tinta_factor = clamp(pow(clamp(1.0 - luminosidad, 0.0, 1.0), contraste_tinta), 0.0, 1.0);
	base_color = mix(base_color, color_tinta.rgb, tinta_factor * opacidad_mapa);

	// 5. Grano / Ruido de fibra de papel
	float ruido = (hash(uv * 1000.0) - 0.5) * intensidad_grano;
	base_color += vec3(ruido);

	COLOR = vec4(clamp(base_color, 0.0, 1.0), 1.0);
}
