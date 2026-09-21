extends Area2D

signal focus_changed(marker, focused)
signal activated(step_index)

var step_index := 0
var title_text := ""
var _inside := false

func setup(index: int, title: String, x_position: float) -> void:
	step_index = index
	title_text = title
	position = Vector2(x_position, 486.0)
	collision_layer = 0
	collision_mask = 1
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(116, 166)
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

func activate_from_touch() -> void:
	if _inside:
		activated.emit(step_index)

func _unhandled_input(event: InputEvent) -> void:
	if _inside and event.is_action_pressed("interact"):
		activate_from_touch()
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var complete := step_index < GameState.reconstruction_step
	var current := step_index == GameState.reconstruction_step
	var color := Color("#526873")
	if complete:
		color = Color("#75c8ae")
	elif current:
		color = Color("#73d5df")
	var alpha := 0.82 if current or complete else 0.32

	# Base de projetor.
	draw_circle(Vector2(0, 58), 34.0, Color(0.0, 0.0, 0.0, 0.28))
	draw_rect(Rect2(-28, 48, 56, 9), Color("#273740"), true)
	draw_rect(Rect2(-13, 57, 26, 11), Color("#111c22"), true)

	# "Cena congelada": moldura, figura humana abstrata e documento.
	draw_rect(Rect2(-46, -74, 92, 108), Color(color.r, color.g, color.b, alpha * 0.06), true)
	draw_rect(Rect2(-46, -74, 92, 108), Color(color.r, color.g, color.b, alpha), false, 2.0)
	draw_line(Vector2(-46, -43), Vector2(46, -43), Color(color.r, color.g, color.b, alpha * 0.60), 1.0)
	draw_circle(Vector2(-19, -20), 8.0, Color(color.r, color.g, color.b, alpha * 0.50))
	draw_line(Vector2(-19, -12), Vector2(-19, 16), Color(color.r, color.g, color.b, alpha * 0.50), 5.0)
	draw_rect(Rect2(3, -27, 26, 38), Color(color.r, color.g, color.b, alpha * 0.12), true)
	draw_rect(Rect2(3, -27, 26, 38), Color(color.r, color.g, color.b, alpha * 0.60), false, 1.5)
	draw_line(Vector2(9, -17), Vector2(23, -17), Color(color.r, color.g, color.b, alpha * 0.55), 1.4)
	draw_line(Vector2(9, -8), Vector2(20, -8), Color(color.r, color.g, color.b, alpha * 0.42), 1.4)

	if complete:
		draw_circle(Vector2(35, -63), 6.0, Color("#75c8ae"))
	elif current:
		var pulse := 55.0 + sin(Time.get_ticks_msec() / 180.0) * 3.0
		draw_arc(Vector2(0, -20), pulse, 0.0, TAU, 40, Color(0.55, 0.96, 0.96, 0.55), 2.0)

	if _inside:
		draw_line(Vector2(-34, 76), Vector2(34, 76), Color(0.70, 0.96, 0.94, 0.62), 2.0)
