extends Area2D

signal focus_changed(hotspot, focused)
signal activated(evidence_id)

var evidence_id := ""
var display_title := ""
var _inside := false

func setup(data: Dictionary) -> void:
	evidence_id = str(data.get("id", ""))
	display_title = str(data.get("title", "Evidência"))
	position = Vector2(float(data.get("world_x", 0.0)), 500.0)
	collision_layer = 0
	collision_mask = 1
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(82, 130)
	collision.shape = shape
	add_child(collision)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	queue_redraw()

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
		activated.emit(evidence_id)

func _unhandled_input(event: InputEvent) -> void:
	if _inside and event.is_action_pressed("interact"):
		activate_from_touch()
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var found := GameState.has_evidence(evidence_id)
	var edge := Color("#4d6877") if found else Color("#77d7e3")
	var fill := Color(0.16, 0.26, 0.31, 0.62) if found else Color(0.18, 0.55, 0.62, 0.28)
	draw_rect(Rect2(-24, -43, 48, 86), fill, true)
	draw_rect(Rect2(-24, -43, 48, 86), edge, false, 2.0)
	draw_line(Vector2(-14, -24), Vector2(14, -24), edge, 2.0)
	draw_line(Vector2(-14, -8), Vector2(11, -8), edge, 2.0)
	draw_line(Vector2(-14, 8), Vector2(8, 8), edge, 2.0)
	if _inside:
		var pulse := 30.0 + sin(Time.get_ticks_msec() / 180.0) * 3.0
		draw_arc(Vector2.ZERO, pulse, 0.0, TAU, 36, Color(0.55, 0.95, 1.0, 0.65), 2.0)
