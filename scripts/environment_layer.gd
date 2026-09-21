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
	# Base de concreto azul-acinzentado com janelas profundas. A cena deixa de
	# parecer um corredor vazio e passa a ter recortes de arquitetura pública.
	draw_rect(Rect2(-1000, 0, 7200, 720), Color("#050b11"), true)
	draw_rect(Rect2(-1000, 64, 7200, 456), Color("#0b1822"), true)
	draw_rect(Rect2(-1000, 82, 7200, 10), Color("#20333f"), true)

	for x in range(-760, 5860, 420):
		draw_rect(Rect2(x, 118, 304, 270), Color("#111f29"), true)
		draw_rect(Rect2(x + 12, 130, 280, 244), Color("#06141e"), true)
		draw_rect(Rect2(x + 24, 144, 124, 214), Color("#0a2230"), true)
		draw_rect(Rect2(x + 158, 144, 122, 214), Color("#0a2230"), true)
		draw_line(Vector2(x + 152, 144), Vector2(x + 152, 358), Color("#29414c"), 3.0)
		# Reflexos frios irregulares.
		draw_rect(Rect2(x + 38, 166, 32, 6), Color(0.55, 0.78, 0.82, 0.14), true)
		draw_rect(Rect2(x + 188, 214, 56, 7), Color(0.55, 0.78, 0.82, 0.10), true)

	# Silhueta urbana muito distante para dar profundidade sem competir com pistas.
	for i in range(26):
		var bx := -800.0 + float((i * 271) % 6900)
		var bh := 38.0 + float((i * 31) % 96)
		draw_rect(Rect2(bx, 388.0 - bh, 74, bh), Color("#081018"), true)
		if i % 3 == 0:
			draw_rect(Rect2(bx + 13, 368.0 - bh, 7, 5), Color(0.70, 0.58, 0.34, 0.22), true)

	# Chuva vista contra os vidros.
	for i in range(70):
		var rx := -850.0 + float((i * 193) % 7050)
		var ry := fmod(float(i * 83) + _phase * 170.0, 350.0) + 110.0
		draw_line(Vector2(rx, ry), Vector2(rx - 8, ry + 23), Color(0.48, 0.72, 0.82, 0.16), 1.0)

func _draw_mid() -> void:
	# Vigas e luminárias quebram a repetição horizontal.
	for x in range(-300, 5400, 520):
		draw_rect(Rect2(x, 78, 48, 482), Color("#17242d"), true)
		draw_rect(Rect2(x + 6, 78, 5, 482), Color(0.45, 0.70, 0.74, 0.07), true)

	for x in [250, 790, 1330, 2260, 3220, 4140, 4580]:
		draw_line(Vector2(x, 82), Vector2(x, 126), Color("#3a4f58"), 3.0)
		draw_rect(Rect2(x - 76, 124, 152, 10), Color("#263b44"), true)
		draw_rect(Rect2(x - 54, 134, 108, 5), Color(0.60, 0.88, 0.84, 0.24), true)

	# Setor A: triagem. Mesa longa, monitor e arquivo baixo.
	draw_rect(Rect2(170, 394, 1670, 22), Color("#24323a"), true)
	draw_rect(Rect2(190, 416, 1630, 92), Color("#111d24"), true)
	for x in range(230, 1780, 260):
		draw_rect(Rect2(x, 430, 190, 52), Color("#172831"), true)
		draw_line(Vector2(x + 16, 445), Vector2(x + 174, 445), Color("#35505b"), 2.0)
	draw_rect(Rect2(118, 248, 310, 116), Color("#101c24"), true)
	draw_rect(Rect2(132, 262, 282, 88), Color("#07141b"), true)
	draw_rect(Rect2(154, 282, 172, 5), Color(0.39, 0.78, 0.73, 0.20), true)

	# Setor B: arquivo processual. Estantes verticais e uma mesa de consulta.
	for x in [2160, 2360, 2560, 2760]:
		draw_rect(Rect2(x, 244, 148, 254), Color("#15242c"), true)
		draw_rect(Rect2(x + 10, 258, 128, 226), Color("#0e1920"), true)
		for y in range(284, 468, 38):
			draw_line(Vector2(x + 18, y), Vector2(x + 130, y), Color("#314750"), 2.0)
			draw_rect(Rect2(x + 28 + (int(y / 38) % 3) * 17, y - 21, 52, 15), Color(0.42, 0.48, 0.44, 0.20), true)

	# Setor C: mesa de comparação, luminária baixa e quadro de diferenças.
	draw_rect(Rect2(3020, 286, 680, 172), Color("#101c22"), true)
	draw_rect(Rect2(3040, 306, 640, 132), Color("#182831"), true)
	for x in [3098, 3306, 3514]:
		draw_rect(Rect2(x, 328, 138, 82), Color("#0b171d"), true)
		draw_line(Vector2(x + 16, 349), Vector2(x + 116, 349), Color("#3a5660"), 2.0)
	draw_rect(Rect2(3050, 472, 610, 20), Color("#26353c"), true)

	# Setor D: dois painéis lado a lado para tornar "tese x resultado" legível no espaço.
	draw_rect(Rect2(3910, 250, 350, 224), Color("#171e25"), true)
	draw_rect(Rect2(4275, 250, 350, 224), Color("#171e25"), true)
	draw_rect(Rect2(3924, 264, 322, 196), Color("#0b171e"), true)
	draw_rect(Rect2(4289, 264, 322, 196), Color("#0b171e"), true)
	for y in [304, 346, 388, 430]:
		draw_line(Vector2(3946, y), Vector2(4222, y), Color(0.36, 0.55, 0.60, 0.22), 2.0)
		draw_line(Vector2(4311, y), Vector2(4587, y), Color(0.52, 0.44, 0.34, 0.22), 2.0)
	draw_line(Vector2(4267, 252), Vector2(4267, 474), Color("#4a5960"), 3.0)

func _draw_near() -> void:
	# Piso com faixas de perspectiva e reflexos de luz.
	draw_rect(Rect2(-400, 552, 5700, 188), Color("#080f14"), true)
	draw_line(Vector2(-400, 552), Vector2(5300, 552), Color("#40515a"), 3.0)
	for x in range(-200, 5300, 170):
		draw_line(Vector2(x, 552), Vector2(x + 96, 720), Color(0.20, 0.31, 0.36, 0.19), 1.0)
	for x in [250, 790, 1330, 2260, 3220, 4140, 4580]:
		draw_rect(Rect2(x - 96, 554, 192, 7), Color(0.43, 0.78, 0.73, 0.08), true)

	# Bases físicas sob as pistas: o objeto investigável deixa de "flutuar".
	for x in [350, 650, 920, 1190, 1480, 1810]:
		_draw_evidence_plinth(x, 442, 76)
	for x in [2150, 2440, 2720]:
		_draw_evidence_plinth(x, 446, 72)
	for x in [3090, 3370, 3620]:
		_draw_evidence_plinth(x, 450, 72)
	for x in [3970, 4210, 4450, 4690]:
		_draw_evidence_plinth(x, 448, 68)

	# Ocultadores de primeiro plano discretos criam profundidade 2.5D.
	for x in [-80, 1980, 2860, 3820, 4900]:
		draw_rect(Rect2(x, 390, 24, 330), Color(0.02, 0.04, 0.05, 0.78), true)
		draw_rect(Rect2(x + 4, 390, 4, 330), Color(0.25, 0.40, 0.44, 0.12), true)

func _draw_evidence_plinth(x: float, y: float, width: float) -> void:
	draw_circle(Vector2(x, 548), width * 0.58, Color(0.0, 0.0, 0.0, 0.25))
	draw_rect(Rect2(x - width * 0.5, y, width, 12), Color("#34444b"), true)
	draw_rect(Rect2(x - width * 0.38, y + 12, width * 0.76, 94), Color("#142129"), true)
	draw_rect(Rect2(x - width * 0.32, y + 18, width * 0.64, 4), Color(0.45, 0.72, 0.70, 0.09), true)
