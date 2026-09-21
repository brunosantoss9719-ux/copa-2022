extends Area2D

signal focus_changed(hotspot, focused)
signal activated(evidence_id)

var evidence_id := ""
var display_title := ""
var factual_status := ""
var source_id := ""
var phase_index := 1
var _inside := false

func setup(data: Dictionary) -> void:
	evidence_id = str(data.get("id", ""))
	display_title = str(data.get("title", "Evidência"))
	factual_status = str(data.get("factual_status", ""))
	source_id = str(data.get("source_id", ""))
	phase_index = int(data.get("phase", 1))
	position = Vector2(float(data.get("world_x", 0.0)), 494.0)
	collision_layer = 0
	collision_mask = 1
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(94, 132)
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
	if _inside or not GameState.has_evidence(evidence_id):
		queue_redraw()

func _draw() -> void:
	var found := GameState.has_evidence(evidence_id)
	var edge := _status_color()
	if found:
		edge = Color(edge.r * 0.62, edge.g * 0.62, edge.b * 0.62, 0.82)

	# Sombra e pequena luz de leitura amarram o item ao cenário.
	draw_circle(Vector2(0, 49), 30.0, Color(0.0, 0.0, 0.0, 0.32))
	if not found:
		draw_circle(Vector2(0, -4), 48.0, Color(edge.r, edge.g, edge.b, 0.035))

	if factual_status == "ALEGAÇÃO_OFICIAL":
		_draw_folder(edge, found)
	elif factual_status == "TESE_DE_DEFESA":
		_draw_defense_memo(edge, found)
	elif factual_status == "FICÇÃO_DRAMÁTICA":
		_draw_sticky_note(edge, found)
	else:
		_draw_judicial_sheet(edge, found)

	# Identificador visual mínimo de fase, sem revelar solução.
	for i in range(phase_index):
		draw_circle(Vector2(-14.0 + i * 9.0, 38.0), 2.2, Color(edge.r, edge.g, edge.b, 0.72))

	if _inside:
		var pulse := 38.0 + sin(Time.get_ticks_msec() / 170.0) * 3.0
		draw_arc(Vector2(0, -3), pulse, 0.0, TAU, 40, Color(0.70, 0.96, 0.94, 0.78), 2.0)
		draw_line(Vector2(-25, 55), Vector2(25, 55), Color(0.68, 0.95, 0.92, 0.55), 2.0)

func _draw_folder(edge: Color, found: bool) -> void:
	var fill := Color(0.18, 0.24, 0.25, 0.96) if found else Color(0.24, 0.31, 0.30, 0.98)
	draw_rect(Rect2(-30, -34, 60, 66), fill, true)
	draw_rect(Rect2(-24, -42, 28, 12), fill, true)
	draw_rect(Rect2(-30, -34, 60, 66), edge, false, 2.0)
	draw_line(Vector2(-19, -13), Vector2(18, -13), Color(edge.r, edge.g, edge.b, 0.68), 2.0)
	draw_line(Vector2(-19, 0), Vector2(12, 0), Color(edge.r, edge.g, edge.b, 0.46), 2.0)
	draw_line(Vector2(-19, 13), Vector2(18, 13), Color(edge.r, edge.g, edge.b, 0.34), 2.0)

func _draw_judicial_sheet(edge: Color, found: bool) -> void:
	var fill := Color("#1a2328") if found else Color("#202d31")
	draw_rect(Rect2(-27, -43, 54, 78), fill, true)
	draw_rect(Rect2(-27, -43, 54, 78), edge, false, 2.0)
	draw_line(Vector2(-16, -25), Vector2(15, -25), edge, 2.0)
	draw_line(Vector2(-16, -12), Vector2(12, -12), Color(edge.r, edge.g, edge.b, 0.56), 2.0)
	draw_line(Vector2(-16, 1), Vector2(10, 1), Color(edge.r, edge.g, edge.b, 0.40), 2.0)
	draw_circle(Vector2(11, 18), 8.0, Color(edge.r, edge.g, edge.b, 0.15))
	draw_arc(Vector2(11, 18), 8.0, 0.0, TAU, 18, edge, 1.6)

func _draw_defense_memo(edge: Color, found: bool) -> void:
	var fill := Color("#22242a") if found else Color("#292b32")
	draw_rect(Rect2(-28, -40, 56, 74), fill, true)
	draw_rect(Rect2(-28, -40, 56, 74), edge, false, 2.0)
	draw_arc(Vector2(-15, -34), 6.0, PI, TAU, 14, Color("#a8afb1"), 2.0)
	draw_line(Vector2(-17, -20), Vector2(17, -20), Color(edge.r, edge.g, edge.b, 0.62), 2.0)
	draw_line(Vector2(-17, -5), Vector2(11, -5), Color(edge.r, edge.g, edge.b, 0.44), 2.0)
	draw_line(Vector2(-17, 10), Vector2(15, 10), Color(edge.r, edge.g, edge.b, 0.34), 2.0)

func _draw_sticky_note(edge: Color, found: bool) -> void:
	var fill := Color("#38382d") if found else Color("#4a4934")
	draw_rect(Rect2(-27, -32, 54, 60), fill, true)
	draw_rect(Rect2(-27, -32, 54, 60), edge, false, 2.0)
	draw_line(Vector2(-16, -13), Vector2(15, -13), Color(edge.r, edge.g, edge.b, 0.58), 2.0)
	draw_line(Vector2(-16, 1), Vector2(10, 1), Color(edge.r, edge.g, edge.b, 0.42), 2.0)
	draw_line(Vector2(16, 28), Vector2(27, 17), Color(edge.r, edge.g, edge.b, 0.44), 1.4)

func _status_color() -> Color:
	match factual_status:
		"ALEGAÇÃO_OFICIAL":
			return Color("#d6a862")
		"TESE_DE_DEFESA":
			return Color("#ba9bd4")
		"FICÇÃO_DRAMÁTICA":
			return Color("#d4c778")
		_:
			return Color("#76c8bc")
