extends Node2D

@export var depth_factor := 1.0
@export var layer_kind := "far"

var _phase := 0.0

func _process(delta: float) -> void:
	_phase += delta
	var camera := get_viewport().get_camera_2d()
	if camera != null and depth_factor < 0.999:
		position.x = (camera.global_position.x - 640.0) * (1.0 - depth_factor)
	if layer_kind == "far":
		queue_redraw()

func _draw() -> void:
	if layer_kind == "far":
		_draw_far()
	elif layer_kind == "mid":
		_draw_mid()
	else:
		_draw_near()

func _draw_far() -> void:
	draw_rect(Rect2(-900, 0, 6900, 720), Color("#07131d"), true)
	draw_rect(Rect2(-900, 110, 6900, 390), Color("#0a1a25"), true)
	for x in range(-700, 5800, 260):
		draw_rect(Rect2(x, 145, 170, 220), Color("#102c3b"), true)
		draw_rect(Rect2(x + 8, 153, 154, 204), Color("#081923"), true)
		draw_rect(Rect2(x + 18, 175, 54, 36), Color(0.62, 0.69, 0.62, 0.12), true)
	for i in range(54):
		var x := -700.0 + float((i * 173) % 6600)
		var y := fmod(float(i * 91) + _phase * 210.0, 560.0) + 80.0
		draw_line(Vector2(x, y), Vector2(x - 10, y + 28), Color(0.48, 0.72, 0.82, 0.18), 1.0)

func _draw_mid() -> void:
	for x in range(-300, 5400, 360):
		draw_rect(Rect2(x, 118, 62, 460), Color("#182733"), true)
		draw_rect(Rect2(x + 7, 118, 8, 460), Color(0.45, 0.66, 0.72, 0.08), true)
	for x in range(-100, 5300, 430):
		draw_rect(Rect2(x, 330, 250, 205), Color("#15242c"), true)
		for row in range(4):
			draw_line(Vector2(x + 15, 360 + row * 38), Vector2(x + 235, 360 + row * 38), Color("#2d4550"), 2.0)

func _draw_near() -> void:
	draw_rect(Rect2(-300, 560, 5500, 180), Color("#0b141a"), true)
	draw_line(Vector2(-300, 560), Vector2(5200, 560), Color("#334650"), 3.0)
	for x in range(-200, 5200, 160):
		draw_line(Vector2(x, 560), Vector2(x + 90, 720), Color(0.22, 0.31, 0.35, 0.22), 1.0)
	for x in [520, 1080, 1640, 2140, 2440, 2740, 3100, 3380, 3620, 3970, 4210, 4450, 4690]:
		draw_rect(Rect2(x - 58, 455, 116, 18), Color("#293840"), true)
		draw_rect(Rect2(x - 48, 473, 14, 78), Color("#17242b"), true)
		draw_rect(Rect2(x + 34, 473, 14, 78), Color("#17242b"), true)
