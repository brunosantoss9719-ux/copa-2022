extends Area2D

signal focus_changed(marker, focused)
signal activated(step_index)

var step_index := 0
var title_text := ""
var _inside := false

func setup(index: int, title: String, x_position: float) -> void:
	step_index = index
	title_text = title
	position = Vector2(x_position, 488.0)
	collision_layer = 0
	collision_mask = 1
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(78, 150)
	collision.shape = shape
	add_child(collision)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body) -> void:
	if body.name != "Investigator":
		return
	_inside = true
	focus_changed.emit(self, true)
	queue_redraw()

func _on_body_exited(body) -> void:
	if body.name != "Investigator":
		return
	_inside = false
	focus_changed.emit(self, false)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if _inside and event.is_action_pressed("interact"):
		activated.emit(step_index)
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var complete := step_index < GameState.reconstruction_step
	var current := step_index == GameState.reconstruction_step
	var color := Color("#4f6c77")
	if complete:
		color = Color("#7cc9b1")
	elif current:
		color = Color("#79d9e6")
	var alpha := 0.48 if current or complete else 0.22
	draw_rect(Rect2(-25, -64, 50, 128), Color(color.r, color.g, color.b, alpha * 0.35), true)
	draw_rect(Rect2(-25, -64, 50, 128), Color(color.r, color.g, color.b, alpha), false, 2.0)
	draw_line(Vector2(0, -64), Vector2(0, 64), Color(color.r, color.g, color.b, alpha), 1.0)
	if _inside:
		draw_arc(Vector2.ZERO, 38.0, 0.0, TAU, 32, Color(0.65, 0.96, 1.0, 0.72), 2.0)
