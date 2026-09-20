extends CharacterBody2D

const SPEED := 245.0

var controls_enabled := true
var _step_clock := 0.0
var _walk_phase := 0.0
var _facing := 1.0

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
	position.x = clampf(position.x + velocity.x * delta, 90.0, 2110.0)
	position.y = 552.0
	queue_redraw()

func _draw() -> void:
	var bob := sin(_walk_phase) * 2.0 if absf(velocity.x) > 1.0 else 0.0
	draw_circle(Vector2(0, 43), 22.0, Color(0.0, 0.0, 0.0, 0.28))
	draw_rect(Rect2(-13, -8 + bob, 26, 48), Color("#172633"), true)
	draw_rect(Rect2(-16, 16 + bob, 32, 26), Color("#0d171f"), true)
	draw_circle(Vector2(0, -21 + bob), 13.0, Color("#9ba6ab"))
	draw_line(Vector2(-8 * _facing, -19 + bob), Vector2(13 * _facing, -16 + bob), Color("#d8e0df"), 2.0)
	draw_line(Vector2(-8, 41), Vector2(-12, 57), Color("#0a1117"), 6.0)
	draw_line(Vector2(8, 41), Vector2(12, 57), Color("#0a1117"), 6.0)
