extends Node

var failures: Array[String] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _run() -> void:
	SaveManager.clear_save()
	GameState.reset_state()

	var packed: PackedScene = load("res://scenes/Main.tscn") as PackedScene
	_check(packed != null, "Main.tscn não carregou no mobile probe")
	if packed == null:
		_finish()
		return

	var main: Node = packed.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	main.call("_new_game")
	main.call("_build_mobile_controls", true)
	await get_tree().process_frame

	var controls: Control = main.get("mobile_controls") as Control
	var left: Button = main.get("mobile_left_button") as Button
	var right: Button = main.get("mobile_right_button") as Button
	var interact: Button = main.get("mobile_interact_button") as Button
	var board: Button = main.get("mobile_board_button") as Button
	var tray: VBoxContainer = main.get("board_tray") as VBoxContainer

	_check(controls != null, "Controles mobile não foram criados")
	_check(left != null and right != null, "Botões de movimento mobile ausentes")
	_check(interact != null, "Botão Examinar mobile ausente")
	_check(board != null, "Botão Hipótese mobile ausente")

	if left != null:
		left.button_down.emit()
		_check(Input.is_action_pressed("move_left"), "Botão esquerdo não pressiona move_left")
		left.button_up.emit()
		_check(not Input.is_action_pressed("move_left"), "Botão esquerdo não libera move_left")

	if right != null:
		right.button_down.emit()
		_check(Input.is_action_pressed("move_right"), "Botão direito não pressiona move_right")
		right.button_up.emit()
		_check(not Input.is_action_pressed("move_right"), "Botão direito não libera move_right")

	var hotspots: Node = main.get_node("Hotspots")
	if hotspots.get_child_count() > 0 and interact != null:
		var hotspot = hotspots.get_child(0)
		hotspot.set("_inside", true)
		main.call("_on_hotspot_focus", hotspot, true)
		_check(not interact.disabled, "Examinar não habilita com evidência em foco")
		interact.pressed.emit()
		await get_tree().process_frame
		_check(GameState.discovered_evidence.size() == 1, "Examinar touch não registrou a evidência")
		var evidence_panel: PanelContainer = main.get("evidence_panel") as PanelContainer
		_check(evidence_panel != null and evidence_panel.visible, "Examinar touch não abriu o painel")
		main.call("_close_evidence")
		hotspot.set("_inside", false)
		main.call("_on_hotspot_focus", hotspot, false)

	if board != null:
		board.pressed.emit()
		await get_tree().process_frame
		var board_panel: PanelContainer = main.get("board_panel") as PanelContainer
		_check(board_panel != null and board_panel.visible, "Botão Hipótese touch não abriu o quadro")
		_check(str(main.get("board_stage")) == "timeline", "Quadro mobile não abriu na pergunta ativa")
		_check(tray != null and tray.get_child_count() >= 2, "Bandeja mobile não exibiu evidência descoberta")
		main.call("_close_board")

	_check(controls == null or controls.visible, "Controles mobile não retornaram após fechar modal")

	Input.action_release("move_left")
	Input.action_release("move_right")
	SaveManager.clear_save()
	main.queue_free()
	await get_tree().process_frame
	_finish()

func _finish() -> void:
	if failures.is_empty():
		print("MOBILE_TOUCH_OK: movimento, interação e quadro touch validados.")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error("MOBILE_TOUCH_FAIL: %s" % failure)
	get_tree().quit(1)
