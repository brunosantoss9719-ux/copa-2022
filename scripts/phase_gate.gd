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

func _sync_state(force: bool) -> void:
	var next_state := GameState.status_solved
	if not force and next_state == _unlocked:
		return
	_unlocked = next_state
	state_label.text = "ACESSO LIBERADO  →" if _unlocked else "ACESSO PENDENTE"
	state_label.modulate = Color("#8dd8c9") if _unlocked else Color("#d0a36a")
	title_label.modulate = Color("#d6eeee") if _unlocked else Color("#94a3a8")
	queue_redraw()

func _draw() -> void:
	var frame_color := Color(0.30, 0.57, 0.61, 0.72) if _unlocked else Color(0.52, 0.38, 0.24, 0.80)
	draw_rect(Rect2(-34, 250, 10, 310), frame_color, true)
	draw_rect(Rect2(24, 250, 10, 310), frame_color, true)
	draw_rect(Rect2(-34, 250, 68, 8), frame_color, true)
	if not _unlocked:
		draw_rect(Rect2(-23, 266, 46, 294), Color(0.24, 0.16, 0.11, 0.48), true)
		for y in range(282, 548, 34):
			draw_line(Vector2(-22, y), Vector2(22, y - 22), Color(0.73, 0.51, 0.27, 0.52), 3.0)
