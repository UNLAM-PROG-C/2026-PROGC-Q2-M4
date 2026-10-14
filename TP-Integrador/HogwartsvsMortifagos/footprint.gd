class_name Footprint
extends Node2D

## A single Marauder's Map footprint (left or right foot).
## Uses _draw() for crisp vector rendering without external textures.

const DEFAULT_OPACITY: float = 0.85
const ALPHA_PROPERTY: NodePath = ^"modulate:a"
## Sole ellipse: offset from the origin (x mirrored per foot), tilt and smoothness.
const SOLE_OFFSET: Vector2 = Vector2(1.0, -2.0)
const SOLE_TILT_DEGREES: float = 6.0
const SOLE_SEGMENTS: int = 16
## Heel ellipse: sideways offset (mirrored per foot), tilt and smoothness.
const HEEL_OFFSET_X: float = 0.5
const HEEL_TILT_DEGREES: float = 3.0
const HEEL_SEGMENTS: int = 12

@export var ink_color: Color = Color(0.235, 0.141, 0.082, 0.85) ## #3c2415
@export var is_right_foot: bool = true
@export var sole_radius: Vector2 = Vector2(5.5, 9.0)
@export var heel_radius: Vector2 = Vector2(4.0, 5.0)
@export var heel_distance: float = 13.0

var _base_opacity: float = DEFAULT_OPACITY


func _ready() -> void:
	modulate.a = _base_opacity


func setup(right_foot: bool, opacity: float = DEFAULT_OPACITY) -> void:
	is_right_foot = right_foot
	_base_opacity = opacity
	modulate.a = opacity
	queue_redraw()


func _draw() -> void:
	var foot_sign: float = 1.0 if is_right_foot else -1.0
	# 1. Sole (forward ellipse with a slight curve)
	var sole_center: Vector2 = Vector2(foot_sign * SOLE_OFFSET.x, SOLE_OFFSET.y)
	draw_set_transform(sole_center, deg_to_rad(foot_sign * SOLE_TILT_DEGREES), Vector2.ONE)
	draw_colored_polygon(_build_ellipse_points(Vector2.ZERO, sole_radius, SOLE_SEGMENTS), ink_color)
	# 2. Heel (smaller ellipse at the back)
	var heel_center: Vector2 = Vector2(-foot_sign * HEEL_OFFSET_X, heel_distance)
	draw_set_transform(heel_center, deg_to_rad(-foot_sign * HEEL_TILT_DEGREES), Vector2.ONE)
	draw_colored_polygon(_build_ellipse_points(Vector2.ZERO, heel_radius, HEEL_SEGMENTS), ink_color)


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
	tween.tween_property(self, ALPHA_PROPERTY, 0.0, duration)
	if on_finished.is_valid():
		tween.tween_callback(on_finished)
	else:
		tween.tween_callback(queue_free)
