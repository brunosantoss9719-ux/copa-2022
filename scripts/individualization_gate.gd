extends Node2D

@onready var title_label: Label = $Title
@onready var state_label: Label = $State

var _unlocked := false

func _ready() -> void:
	_sync_state(true)

func _process(_delta: float) -> void:
	_sync_state(false)

func is_unlocked() -> bool:
	return _unlocked

func sync_now() -> void:
	_sync_state(true)

func _sync_state(force: bool) -> void:
	var next_state := GameState.origin_solved
	if not force and next_state == _unlocked:
		return
	_unlocked = next_state
	state_label.text = "LIBERADO  →" if _unlocked else "ISOLADO"
	state_label.modulate = Color("#8dd8c9") if _unlocked else Color("#b99668")
	title_label.modulate = Color("#d6eeee") if _unlocked else Color("#8f9ca0")
	queue_redraw()

func _draw() -> void:
	var frame_color := Color(0.32, 0.60, 0.60, 0.72) if _unlocked else Color(0.42, 0.36, 0.28, 0.70)
	var glass := Color(0.16, 0.31, 0.34, 0.13) if _unlocked else Color(0.16, 0.12, 0.10, 0.34)

	# Portal de controle de acesso mais discreto: faz parte da arquitetura,
	# não parece uma "fase de videogame" plantada no corredor.
	draw_rect(Rect2(-45, 228, 12, 332), Color("#17252c"), true)
	draw_rect(Rect2(33, 228, 12, 332), Color("#17252c"), true)
	draw_rect(Rect2(-45, 228, 90, 10), Color("#22343b"), true)
	draw_rect(Rect2(-32, 244, 64, 316), glass, true)
	draw_line(Vector2(-32, 244), Vector2(-32, 560), frame_color, 2.0)
	draw_line(Vector2(32, 244), Vector2(32, 560), frame_color, 2.0)

	# Leitor de acesso.
	draw_rect(Rect2(47, 366, 18, 34), Color("#101a20"), true)
	draw_circle(Vector2(56, 375), 3.5, Color("#78c9b4") if _unlocked else Color("#c09061"))
	draw_line(Vector2(51, 388), Vector2(61, 388), frame_color, 1.5)

	if not _unlocked:
		for y in range(276, 544, 30):
			draw_line(Vector2(-27, y), Vector2(27, y - 18), Color(0.61, 0.44, 0.28, 0.34), 2.0)
