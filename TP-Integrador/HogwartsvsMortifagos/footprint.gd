class_name Footprint
extends Node2D

## A single Marauder's Map footprint (left or right foot).
## Uses _draw() for crisp vector rendering without external textures.

@export var ink_color: Color = Color(0.235, 0.141, 0.082, 0.85) ## #3c2415
@export var is_right_foot: bool = true
@export var sole_radius: Vector2 = Vector2(5.5, 9.0)
@export var heel_radius: Vector2 = Vector2(4.0, 5.0)
@export var heel_distance: float = 13.0

var _base_opacity: float = 0.85


func _ready() -> void:
	modulate.a = _base_opacity


func setup(right_foot: bool, opacity: float = 0.85) -> void:
	is_right_foot = right_foot
	_base_opacity = opacity
	modulate.a = opacity
	queue_redraw()


func _draw() -> void:
	var final_color: Color = ink_color
	var foot_sign: float = 1.0 if is_right_foot else -1.0

	# 1. Draw the sole (forward ellipse with a slight curve)
	var sole_center: Vector2 = Vector2(foot_sign * 1.0, -2.0)
	draw_set_transform(sole_center, deg_to_rad(foot_sign * 6.0), Vector2.ONE)
	draw_colored_polygon(_build_ellipse_points(Vector2.ZERO, sole_radius, 16), final_color)

	# 2. Draw the heel (smaller ellipse at the back)
	var heel_center: Vector2 = Vector2(-foot_sign * 0.5, heel_distance)
	draw_set_transform(heel_center, deg_to_rad(-foot_sign * 3.0), Vector2.ONE)
	draw_colored_polygon(_build_ellipse_points(Vector2.ZERO, heel_radius, 12), final_color)


func _build_ellipse_points(center: Vector2, radii: Vector2, segments: int) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	var step: float = TAU / float(segments)
	for i: int in range(segments):
		var angle: float = float(i) * step
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	return points


## Smooth Tween fade-out followed by automatic recycling/freeing.
func fade_out(duration: float, on_finished: Callable = Callable()) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration)
	if on_finished.is_valid():
		tween.tween_callback(on_finished)
	else:
		tween.tween_callback(queue_free)
