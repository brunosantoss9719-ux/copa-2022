extends CharacterBody2D

const SPEED := 245.0
const PHASE1_RIGHT := 2050.0
const PHASE2_RIGHT := 2900.0
const PHASE3_RIGHT := 3790.0
const WORLD_RIGHT := 4790.0

var controls_enabled := true
var _step_clock := 0.0
var _walk_phase := 0.0
var _facing := 1.0
@onready var camera: Camera2D = $Camera2D

func set_controls_enabled(enabled: bool) -> void:
	controls_enabled = enabled
	if not enabled:
		velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	var direction := 0.0
	if controls_enabled:
		direction = Input.get_axis("move_left", "move_right")
	if absf(direction) > 0.05:
		_facing = signf(direction)
		_walk_phase += delta * 10.0
		_step_clock -= delta
		if _step_clock <= 0.0:
			AudioManager.play_step()
			_step_clock = 0.42
	else:
		_step_clock = 0.0
	velocity.x = direction * SPEED
	var right_limit := PHASE1_RIGHT
	if GameState.individualization_solved:
		right_limit = WORLD_RIGHT
	elif GameState.origin_solved:
		right_limit = PHASE3_RIGHT
	elif GameState.status_solved:
		right_limit = PHASE2_RIGHT
	position.x = clampf(position.x + velocity.x * delta, 90.0, right_limit)
	position.y = 552.0
	if camera != null:
		var target_lookahead := _facing * (58.0 if absf(velocity.x) > 1.0 else 28.0)
		camera.position.x = lerpf(camera.position.x, target_lookahead, minf(1.0, delta * 4.2))
		camera.position.y = lerpf(camera.position.y, -192.0, minf(1.0, delta * 4.2))
	queue_redraw()

func _draw() -> void:
	var walking := absf(velocity.x) > 1.0
	var bob := sin(_walk_phase) * 1.8 if walking else 0.0
	var stride := sin(_walk_phase) * 6.0 if walking else 0.0
	var coat := Color("#1a2933")
	var coat_dark := Color("#0c151b")
	var skin := Color("#a9ada9")
	var rim := Color(0.52, 0.80, 0.78, 0.28)

	# Sombra de contato.
	draw_circle(Vector2(0, 48), 24.0, Color(0.0, 0.0, 0.0, 0.34))

	# Pernas separadas para dar leitura de caminhada.
	draw_line(Vector2(-7, 27 + bob), Vector2(-9 - stride * 0.45, 55), coat_dark, 7.0)
	draw_line(Vector2(7, 27 + bob), Vector2(9 + stride * 0.45, 55), coat_dark, 7.0)
	draw_line(Vector2(-10 - stride * 0.45, 55), Vector2(-2 - stride * 0.45, 55), Color("#050a0d"), 4.0)
	draw_line(Vector2(10 + stride * 0.45, 55), Vector2(18 + stride * 0.45, 55), Color("#050a0d"), 4.0)

	# Casaco em silhueta poligonal: menos "boneco de retângulos", mais figura gráfica.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-13, -9 + bob),
		Vector2(13, -9 + bob),
		Vector2(18, 13 + bob),
		Vector2(15, 37 + bob),
		Vector2(-15, 37 + bob),
		Vector2(-18, 13 + bob)
	]), coat)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-18, 14 + bob),
		Vector2(18, 14 + bob),
		Vector2(14, 39 + bob),
		Vector2(-14, 39 + bob)
	]), coat_dark)
	draw_line(Vector2(0, -4 + bob), Vector2(0, 31 + bob), Color("#31434c"), 1.4)
	draw_line(Vector2(-13, -3 + bob), Vector2(-21 * _facing, 23 + bob), coat_dark, 6.0)
	draw_line(Vector2(13, -3 + bob), Vector2(20 * _facing, 22 + bob), coat_dark, 6.0)
	draw_line(Vector2(-11, 3 + bob), Vector2(11, 3 + bob), Color(0.45, 0.66, 0.68, 0.16), 1.0)

	# Pasta transversal — silhueta de investigadora, não de personagem de ação.
	draw_line(Vector2(-11 * _facing, -4 + bob), Vector2(12 * _facing, 29 + bob), Color("#584a36"), 3.0)
	draw_rect(Rect2(8 * _facing - 7, 18 + bob, 18, 16), Color("#30291f"), true)

	# Cabeça, cabelo e luz de recorte.
	draw_circle(Vector2(0, -23 + bob), 13.0, skin)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-12, -27 + bob),
		Vector2(-7, -37 + bob),
		Vector2(7, -37 + bob),
		Vector2(13, -27 + bob),
		Vector2(8, -17 + bob),
		Vector2(-9, -17 + bob)
	]), Color("#242a2d"))
	draw_line(Vector2(-11 * _facing, -20 + bob), Vector2(11 * _facing, -18 + bob), Color("#d0d7d4"), 1.5)
	draw_circle(Vector2(8 * _facing, -22 + bob), 1.3, Color("#273036"))
	draw_line(Vector2(16, -6 + bob), Vector2(16, 28 + bob), rim, 2.0)
