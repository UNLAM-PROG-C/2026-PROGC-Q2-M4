class_name AllyCardButton
extends Button

## HUD button of an AllyCard: shows its cost and whether it can be afforded,
## is selected or is cooling down.

## Emitted when the player clicks the card.
signal card_pressed(button: AllyCardButton)
## Emitted when the card's cooldown ends.
signal cooldown_finished()

const LABEL_FORMAT_TEXT: String = "%s (%d)"
const SELECTED_COLOR: Color = Color(0.5, 1.0, 0.5)
const INVALID_CARD_MESSAGE: String = "AllyCardButton %s has an invalid card"

@export var card: AllyCard

var _cooldown_left: float = 0.0


func _ready() -> void:
	if card == null or not card.is_valid():
		push_error(INVALID_CARD_MESSAGE % name)
		return
	text = LABEL_FORMAT_TEXT % [card.display_name, card.cost]
	pressed.connect(_on_pressed)
	set_process(false)


func _process(delta: float) -> void:
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)
	if _cooldown_left <= 0.0:
		set_process(false)
		cooldown_finished.emit()


func refresh(snitches: int) -> void:
	disabled = snitches < card.cost or _cooldown_left > 0.0


func set_selected(is_selected: bool) -> void:
	modulate = SELECTED_COLOR if is_selected else Color.WHITE


func start_cooldown() -> void:
	_cooldown_left = card.cooldown
	set_process(_cooldown_left > 0.0)


func _on_pressed() -> void:
	card_pressed.emit(self)
