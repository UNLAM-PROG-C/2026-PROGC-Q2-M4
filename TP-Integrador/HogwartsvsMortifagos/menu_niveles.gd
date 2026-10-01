class_name MenuNiveles
extends Control

## Menú de Selección de Niveles basado en el Mapa del Merodeador.
## Controla la progresión de 10 niveles, el camino con Path2D y los sistemas de huellas.

signal nivel_seleccionado(numero_nivel: int)

@export_group("Progresión")
## Nivel máximo desbloqueado (se sincroniza con GameManager si existe).
@export var nivel_maximo_desbloqueado: int = 10
## Progreso persistido en memoria durante la sesión del juego.
static var progreso_desbloqueado: int = 10
## Escena del nivel para cargar al hacer clic en un nivel desbloqueado.
@export var escena_nivel_principal: PackedScene
@export var escena_nivel_2: PackedScene
@export var escena_nivel_3: PackedScene

@export_group("Sistema A - Huellas de Camino")
## Distancia en píxeles entre cada paso a lo largo del Path2D.
@export var paso_distancia: float = 30.0
## Separación lateral entre el pie izquierdo y el pie derecho.
@export var separacion_lateral: float = 7.0
## Intervalo de tiempo en segundos entre la aparición de cada huella.
@export var intervalo_paso_camino: float = 0.12

@export_group("Sistema B - Huellas Ambientales")
## Si está activo el sistema de transeúntes fantasma en el fondo.
@export var huellas_ambientales_activas: bool = true
## Intervalo mínimo y máximo de aparición de un nuevo caminante ambiental.
@export var tiempo_aparicion_min: float = 0.5
@export var tiempo_aparicion_max: float = 1.4
## Cantidad máxima de caminantes simultáneos recorriendo el mapa.
@export var max_caminantes_simultaneos: int = 4
## Cantidad de pasos que da cada caminante ambiental.
@export var pasos_minimos: int = 4
@export var pasos_maximos: int = 8

# Nodos de la escena
@onready var path_camino: Path2D = $CaminoNiveles
@onready var contenedor_botones: Node2D = $ContenedorBotones
@onready var capa_huellas_camino: Node2D = $CapaHuellasCamino
@onready var capa_huellas_ambientales: Node2D = $CapaHuellasAmbientales
@onready var timer_ambiental: Timer = $TimerHuellasAmbientales

# Colección de botones de los 10 niveles
var botones_niveles: Array[Button] = []

# Pool de huellas para reutilización en memoria (Zero Garbage Collection)
var _pool_huellas: Array[Huella] = []
var _caminantes_activos: int = 0


func _ready() -> void:
	# Garantizar que las huellas estén en la capa de fondo y los carteles por encima
	capa_huellas_ambientales.z_index = 1
	capa_huellas_ambientales.z_as_relative = false
	capa_huellas_camino.z_index = 2
	capa_huellas_camino.z_as_relative = false
	contenedor_botones.z_index = 10
	contenedor_botones.z_as_relative = false

	_sincronizar_progresion_global()
	_inicializar_botones()
	_actualizar_estado_niveles()
	_iniciar_huellas_camino()

	if huellas_ambientales_activas:
		_configurar_timer_ambiental()


## Sincroniza con el GameManager si está registrado como Autoload global o con la variable de sesión.
func _sincronizar_progresion_global() -> void:
	var game_manager: Node = get_node_or_null("/root/GameManager")
	if game_manager != null and "nivel_maximo_desbloqueado" in game_manager:
		nivel_maximo_desbloqueado = int(game_manager.get("nivel_maximo_desbloqueado"))
	else:
		nivel_maximo_desbloqueado = maxi(nivel_maximo_desbloqueado, progreso_desbloqueado)
	nivel_maximo_desbloqueado = clamp(nivel_maximo_desbloqueado, 1, 10)


## Detecta y almacena los 10 botones de nivel del contenedor.
func _inicializar_botones() -> void:
	botones_niveles.clear()
	for i: int in range(1, 11):
		var ruta_boton: String = "Nivel" + str(i)
		var boton: Button = contenedor_botones.get_node_or_null(ruta_boton) as Button
		if boton != null:
			botones_niveles.append(boton)
			boton.pressed.connect(_on_boton_nivel_pressed.bind(i))
			_aplicar_estilo_pergamino_boton(boton)


## Aplica la apariencia visual inspirada en las "Habitaciones del Mapa" (CSS).
func _aplicar_estilo_pergamino_boton(boton: Button) -> void:
	boton.custom_minimum_size = Vector2(160.0, 65.0)

	# Estilo normal (desbloqueado)
	var style_normal: StyleBoxFlat = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.894, 0.804, 0.624, 1.0) # #e4cd9f sólido
	style_normal.border_color = Color(0.235, 0.141, 0.082)    # #3c2415
	style_normal.set_border_width_all(3)
	style_normal.shadow_color = Color(0.235, 0.141, 0.082, 0.25)
	style_normal.shadow_size = 4
	style_normal.shadow_offset = Vector2(2, 2)
	boton.add_theme_stylebox_override("normal", style_normal)

	# Estilo hover
	var style_hover: StyleBoxFlat = style_normal.duplicate() as StyleBoxFlat
	style_hover.bg_color = Color(0.922, 0.863, 0.698, 1.0) # #ebdcb2 sólido
	style_hover.shadow_size = 6
	boton.add_theme_stylebox_override("hover", style_hover)

	# Estilo presionado
	var style_pressed: StyleBoxFlat = style_normal.duplicate() as StyleBoxFlat
	style_pressed.bg_color = Color(0.816, 0.722, 0.541, 1.0)
	style_pressed.shadow_offset = Vector2(0, 0)
	boton.add_theme_stylebox_override("pressed", style_pressed)

	# Estilo bloqueado
	var style_disabled: StyleBoxFlat = StyleBoxFlat.new()
	style_disabled.bg_color = Color(0.72, 0.61, 0.46, 1.0) # Pergamino envejecido 100% sólido
	style_disabled.border_color = Color(0.35, 0.25, 0.18, 0.8)
	style_disabled.set_border_width_all(2)
	boton.add_theme_stylebox_override("disabled", style_disabled)

	# Colores del texto
	boton.add_theme_color_override("font_color", Color(0.235, 0.141, 0.082))
	boton.add_theme_color_override("font_hover_color", Color(0.12, 0.06, 0.03))
	boton.add_theme_color_override("font_disabled_color", Color(0.35, 0.25, 0.18, 0.85))


## Actualiza el estado visual (habilitado/deshabilitado) de cada uno de los 10 botones.
func _actualizar_estado_niveles() -> void:
	for indice: int in range(botones_niveles.size()):
		var num_nivel: int = indice + 1
		var boton: Button = botones_niveles[indice]
		var esta_desbloqueado: bool = num_nivel <= nivel_maximo_desbloqueado

		boton.disabled = not esta_desbloqueado
		if esta_desbloqueado:
			boton.text = "Nivel " + str(num_nivel)
			boton.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			boton.text = "Nivel " + str(num_nivel) + "\n[Cerrado]"
			# Mantenemos alpha en 1.0 para que el cartel tape 100% las huellas que pasen por debajo
			boton.modulate = Color(0.82, 0.78, 0.72, 1.0)


## Maneja el clic en un botón de nivel.
func _on_boton_nivel_pressed(numero_nivel: int) -> void:
	if numero_nivel > nivel_maximo_desbloqueado:
		return

	nivel_seleccionado.emit(numero_nivel)
	print("[MenuNiveles] Seleccionado Nivel ", numero_nivel)

	if numero_nivel == 1 and escena_nivel_principal != null:
		get_tree().change_scene_to_packed(escena_nivel_principal)
	elif numero_nivel == 2:
		if escena_nivel_2 != null:
			get_tree().change_scene_to_packed(escena_nivel_2)
		else:
			print("[MenuNiveles] escena_nivel_2 es null, cargando por ruta")
			get_tree().change_scene_to_file("res://nivel_2.tscn")
	elif numero_nivel == 3:
		if escena_nivel_3 != null:
			get_tree().change_scene_to_packed(escena_nivel_3)
		else:
			print("[MenuNiveles] escena_nivel_3 es null, cargando por ruta")
			get_tree().change_scene_to_file("res://nivel_3.tscn")


# ==============================================================================
# SISTEMA A: HUELLAS SECUENCIALES SOBRE EL CAMINO (Path2D)
# ==============================================================================

## Inicia la animación de huellas recorriendo solo los segmentos desbloqueados.
func _iniciar_huellas_camino() -> void:
	if path_camino == null or path_camino.curve == null:
		return

	# Limpiar huellas anteriores del camino
	for hijo: Node in capa_huellas_camino.get_children():
		hijo.queue_free()

	# Calcular el porcentaje máximo del camino a recorrer según el nivel desbloqueado
	# Si nivel_maximo == 1, no hay camino previo recorrido todavía
	# Si nivel_maximo == 10, recorre el 100% del camino
	var fraccion_recorrida: float = clamp(float(nivel_maximo_desbloqueado - 1) / 9.0, 0.0, 1.0)
	if fraccion_recorrida <= 0.0:
		return

	var longitud_total: float = path_camino.curve.get_baked_length()
	var longitud_objetivo: float = longitud_total * fraccion_recorrida

	# Generar la secuencia animada paso a paso
	_animar_pasos_en_camino(longitud_objetivo)


func _animar_pasos_en_camino(longitud_objetivo: float) -> void:
	var distancia_actual: float = 10.0
	var pie_derecho: bool = true
	var delay_acumulado: float = 0.0

	while distancia_actual <= longitud_objetivo:
		var transform_curva: Transform2D = path_camino.curve.sample_baked_with_rotation(distancia_actual)
		var pos_base: Vector2 = path_camino.to_global(transform_curva.origin)
		var direccion: Vector2 = transform_curva.x.normalized()
		var perpendicular: Vector2 = Vector2(-direccion.y, direccion.x)

		# Desplazamiento lateral del pie
		var signo_pie: float = 1.0 if pie_derecho else -1.0
		var pos_huella: Vector2 = pos_base + perpendicular * (separacion_lateral * signo_pie)
		var angulo_huella: float = direccion.angle() + (PI / 2.0)

		# Programar aparición de la huella
		var timer_paso: SceneTreeTimer = get_tree().create_timer(delay_acumulado)
		timer_paso.timeout.connect(_crear_huella_en_posicion.bind(pos_huella, angulo_huella, pie_derecho, capa_huellas_camino))

		delay_acumulado += intervalo_paso_camino
		distancia_actual += paso_distancia
		pie_derecho = not pie_derecho


func _crear_huella_en_posicion(pos: Vector2, rotacion: float, pie_derecho: bool, contenedor: Node2D) -> void:
	var huella: Huella = _obtener_huella_del_pool()
	huella.configurar(pie_derecho, 0.85)
	huella.global_position = pos
	huella.rotation = rotacion
	huella.scale = Vector2(0.9, 0.9)
	huella.z_index = 2
	huella.z_as_relative = false
	contenedor.add_child(huella)


# ==============================================================================
# SISTEMA B: HUELLAS AMBIENTALES ALEATORIAS (Transeúntes del Castillo)
# ==============================================================================

func _configurar_timer_ambiental() -> void:
	timer_ambiental.one_shot = true
	timer_ambiental.timeout.connect(_on_timer_ambiental_timeout)
	_reiniciar_timer_ambiental()

	# Generar caminantes iniciales inmediatamente para que el mapa arranque lleno de vida
	for i: int in range(4):
		var delay_inicio: float = float(i) * 0.35
		get_tree().create_timer(delay_inicio).timeout.connect(func() -> void:
			if _caminantes_activos < max_caminantes_simultaneos:
				_generar_caminante_ambiental()
		)


func _reiniciar_timer_ambiental() -> void:
	var tiempo: float = randf_range(tiempo_aparicion_min, tiempo_aparicion_max)
	timer_ambiental.start(tiempo)


func _on_timer_ambiental_timeout() -> void:
	if _caminantes_activos < max_caminantes_simultaneos:
		_generar_caminante_ambiental()
	_reiniciar_timer_ambiental()


## Genera un "transeúnte" que da entre pasos_minimos y pasos_maximos y desaparece.
func _generar_caminante_ambiental() -> void:
	_caminantes_activos += 1

	# Elegir un punto de inicio dentro de la pantalla (evitando los bordes extremos)
	var pos_inicio: Vector2 = Vector2(
		randf_range(120.0, 1800.0),
		randf_range(120.0, 960.0)
	)
	var angulo_camino: float = randf_range(0.0, TAU)
	var direccion: Vector2 = Vector2(cos(angulo_camino), sin(angulo_camino))
	var perpendicular: Vector2 = Vector2(-direccion.y, direccion.x)

	var total_pasos: int = randi_range(pasos_minimos, pasos_maximos)
	var distancia_paso: float = randf_range(24.0, 32.0)
	var pie_derecho: bool = randf() > 0.5
	var cadencia: float = randf_range(0.28, 0.36)

	for paso_i: int in range(total_pasos):
		var delay: float = float(paso_i) * cadencia
		var distancia: float = float(paso_i) * distancia_paso
		var signo: float = 1.0 if pie_derecho else -1.0
		var pos_huella: Vector2 = pos_inicio + (direccion * distancia) + (perpendicular * 5.0 * signo)
		var rot: float = angulo_camino + (PI / 2.0)

		var timer_paso: SceneTreeTimer = get_tree().create_timer(delay)
		var es_ultimo_paso: bool = (paso_i == total_pasos - 1)
		timer_paso.timeout.connect(_instanciar_huella_ambiental.bind(pos_huella, rot, pie_derecho, es_ultimo_paso))

		pie_derecho = not pie_derecho

	# Al terminar de dar todos los pasos, se libera el slot para permitir otro caminante
	var tiempo_fin_caminata: float = float(total_pasos) * cadencia + 0.5
	get_tree().create_timer(tiempo_fin_caminata).timeout.connect(func() -> void:
		_caminantes_activos = max(_caminantes_activos - 1, 0)
	)


func _instanciar_huella_ambiental(pos: Vector2, rot: float, pie_derecho: bool, _es_ultimo: bool) -> void:
	var huella: Huella = _obtener_huella_del_pool()
	huella.configurar(pie_derecho, randf_range(0.60, 0.75))
	huella.global_position = pos
	huella.rotation = rot
	huella.scale = Vector2(0.85, 0.85)
	huella.z_index = 1
	huella.z_as_relative = false
	capa_huellas_ambientales.add_child(huella)

	# Se mantiene visible más tiempo (2.8s - 4.0s) para acumular más huellas simultáneas
	var tiempo_visible: float = randf_range(2.8, 4.0)
	var timer_vida: SceneTreeTimer = get_tree().create_timer(tiempo_visible)
	timer_vida.timeout.connect(func() -> void:
		huella.desvanecer(1.5, func() -> void:
			_devolver_huella_al_pool(huella)
		)
	)


# ==============================================================================
# GESTOR DE MEMORIA Y OBJECT POOLING
# ==============================================================================

func _obtener_huella_del_pool() -> Huella:
	if _pool_huellas.size() > 0:
		var huella: Huella = _pool_huellas.pop_back()
		huella.visible = true
		huella.modulate.a = 1.0
		return huella
	else:
		return Huella.new()


func _devolver_huella_al_pool(huella: Huella) -> void:
	if huella.get_parent() != null:
		huella.get_parent().remove_child(huella)
	huella.visible = false
	_pool_huellas.append(huella)
