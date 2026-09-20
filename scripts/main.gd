extends Node2D

const STATUS_DISPLAY := {
	"ALEGAÇÃO_OFICIAL": "Alegação oficial",
	"DECISÃO_JUDICIAL": "Decisão judicial",
	"TESE_DE_DEFESA": "Tese de defesa",
	"CONTEXTO_JORNALÍSTICO": "Contexto jornalístico",
	"FICÇÃO_DRAMÁTICA": "Ficção dramática"
}

@onready var investigator = $Investigator
@onready var hotspots_root = $Hotspots
@onready var reconstruction_root = $Reconstruction
@onready var ui_root = $UI

var prompt_label: Label
var toast_label: Label
var start_panel: PanelContainer
var evidence_panel: PanelContainer
var evidence_title: Label
var evidence_status: Label
var evidence_summary: Label
var evidence_source: Label
var evidence_note: Label
var board_panel: PanelContainer
var board_scroll: ScrollContainer
var origin_anchor: Control
var board_feedback: Label
var board_progress: Label
var timeline_options: Array[OptionButton] = []
var timeline_validate_button: Button
var status_options: Dictionary = {}
var status_validate_button: Button
var origin_options: Array[OptionButton] = []
var origin_validate_button: Button
var conclusion_panel: PanelContainer
var conclusion_text: Label
var phase_banner: PanelContainer
var phase_banner_label: Label
var current_focus = null

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_input_actions()

func _ready() -> void:
	_build_ui()
	_spawn_evidence()
	if GameState.timeline_solved:
		_spawn_reconstruction()
	_refresh_world_state()
	AudioManager.play_ambience()
	_show_start_menu()

func _ensure_input_actions() -> void:
	_add_action("move_left", [KEY_A, KEY_LEFT], [], JOY_AXIS_LEFT_X, -1.0)
	_add_action("move_right", [KEY_D, KEY_RIGHT], [], JOY_AXIS_LEFT_X, 1.0)
	_add_action("interact", [KEY_E, KEY_ENTER], [JOY_BUTTON_A])
	_add_action("case_board", [KEY_TAB], [JOY_BUTTON_Y])
	_add_action("hint", [KEY_H], [JOY_BUTTON_RIGHT_SHOULDER])

func _add_action(action_name: String, keys: Array, buttons: Array, joy_axis := -1, axis_value := 0.0) -> void:
	if InputMap.has_action(action_name):
		return
	InputMap.add_action(action_name, 0.25)
	for keycode in keys:
		var key_event := InputEventKey.new()
		key_event.physical_keycode = int(keycode)
		InputMap.action_add_event(action_name, key_event)
	for button_index in buttons:
		var button_event := InputEventJoypadButton.new()
		button_event.button_index = int(button_index)
		InputMap.action_add_event(action_name, button_event)
	if joy_axis >= 0:
		var axis_event := InputEventJoypadMotion.new()
		axis_event.axis = int(joy_axis)
		axis_event.axis_value = float(axis_value)
		InputMap.action_add_event(action_name, axis_event)

func _spawn_evidence() -> void:
	for child in hotspots_root.get_children():
		child.queue_free()
	var available_phase := 2 if GameState.status_solved else 1
	var items := EvidenceDB.all_evidence()
	items.sort_custom(func(a, b): return float(a.get("world_x", 0.0)) < float(b.get("world_x", 0.0)))
	for item in items:
		if int(item.get("phase", 1)) > available_phase:
			continue
		var hotspot = preload("res://scripts/evidence_hotspot.gd").new()
		hotspot.setup(item)
		hotspot.focus_changed.connect(_on_hotspot_focus)
		hotspot.activated.connect(_on_evidence_activated)
		hotspots_root.add_child(hotspot)

func _spawn_reconstruction() -> void:
	for child in reconstruction_root.get_children():
		child.queue_free()
	if not GameState.timeline_solved:
		return
	var xs := [780.0, 1370.0, 2020.0]
	for i in range(3):
		var marker = preload("res://scripts/reconstruction_marker.gd").new()
		marker.setup(i, CaseManager.RECONSTRUCTION_TITLES[i], xs[i])
		marker.focus_changed.connect(_on_marker_focus)
		marker.activated.connect(_on_reconstruction_activated)
		reconstruction_root.add_child(marker)

func _refresh_world_state() -> void:
	for child in hotspots_root.get_children():
		child.queue_redraw()
	for child in reconstruction_root.get_children():
		child.queue_redraw()
	if board_panel != null:
		_refresh_board()

func _build_ui() -> void:
	prompt_label = Label.new()
	prompt_label.position = Vector2(250, 646)
	prompt_label.size = Vector2(780, 42)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size", 20)
	prompt_label.text = "A/D ou analógico — mover • E/A — examinar • Tab/Y — quadro"
	ui_root.add_child(prompt_label)

	toast_label = Label.new()
	toast_label.position = Vector2(170, 590)
	toast_label.size = Vector2(940, 46)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.add_theme_font_size_override("font_size", 18)
	toast_label.visible = false
	ui_root.add_child(toast_label)

	_build_phase_banner()
	_build_start_panel()
	_build_evidence_panel()
	_build_board_panel()
	_build_conclusion_panel()

func _make_panel(position_value: Vector2, size_value: Vector2, color: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = position_value
	panel.size = size_value
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.28, 0.53, 0.59, 0.65)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _make_label(text_value: String, size_value := 16, wrap := true) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", size_value)
	if wrap:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _make_button(text_value: String, handler: Callable) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(0, 42)
	button.pressed.connect(handler)
	return button

func _make_margin() -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	return margin

func _build_phase_banner() -> void:
	phase_banner = _make_panel(Vector2(350, 72), Vector2(580, 94), Color(0.025, 0.075, 0.09, 0.96))
	phase_banner.visible = false
	ui_root.add_child(phase_banner)
	var margin := _make_margin()
	phase_banner.add_child(margin)
	phase_banner_label = _make_label("ARQUIVO II — RASTRO DOCUMENTAL\nAcesso liberado. Siga à direita.", 20)
	phase_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	phase_banner.add_child(phase_banner_label)

func _build_start_panel() -> void:
	start_panel = _make_panel(Vector2(335, 165), Vector2(610, 390), Color(0.025, 0.055, 0.075, 0.97))
	ui_root.add_child(start_panel)
	var margin := _make_margin()
	start_panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)
	var title := _make_label("LINHA DE SOMBRA — COPA 2022", 30, false)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var subtitle := _make_label("Sala de Evidências • fatia vertical 0.2", 18, false)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(subtitle)
	box.add_child(_make_label("Thriller investigativo 2.5D. Explore a sala, registre as peças e só conclua o que o conjunto de fontes sustenta.", 16))
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	box.add_child(spacer)
	box.add_child(_make_button("Novo jogo", _new_game))
	var continue_button := _make_button("Continuar", _continue_game)
	continue_button.name = "ContinueButton"
	box.add_child(continue_button)
	box.add_child(_make_button("Sair", func(): get_tree().quit()))

func _build_evidence_panel() -> void:
	evidence_panel = _make_panel(Vector2(230, 130), Vector2(820, 470), Color(0.025, 0.055, 0.075, 0.98))
	evidence_panel.visible = false
	ui_root.add_child(evidence_panel)
	var margin := _make_margin()
	evidence_panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)
	evidence_title = _make_label("", 26)
	box.add_child(evidence_title)
	evidence_status = _make_label("", 16)
	box.add_child(evidence_status)
	evidence_summary = _make_label("", 18)
	evidence_summary.custom_minimum_size = Vector2(0, 130)
	box.add_child(evidence_summary)
	evidence_source = _make_label("", 15)
	box.add_child(evidence_source)
	evidence_note = _make_label("", 14)
	box.add_child(evidence_note)
	box.add_child(_make_button("Fechar", _close_evidence))

func _build_board_panel() -> void:
	board_panel = _make_panel(Vector2(70, 32), Vector2(1140, 650), Color(0.018, 0.04, 0.055, 0.99))
	board_panel.visible = false
	ui_root.add_child(board_panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	board_panel.add_child(margin)
	board_scroll = ScrollContainer.new()
	margin.add_child(board_scroll)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.custom_minimum_size = Vector2(1050, 0)
	board_scroll.add_child(box)
	box.add_child(_make_label("QUADRO DO CASO", 28, false))
	board_progress = _make_label("", 15)
	box.add_child(board_progress)
	box.add_child(_make_label("Puzzle 1 — ordene a mudança de status documental", 20, false))
	box.add_child(_make_label("Escolha três peças em ordem. A validação é do conjunto inteiro; o quadro não revela microacertos.", 14))
	var timeline_row := HBoxContainer.new()
	timeline_row.add_theme_constant_override("separation", 10)
	box.add_child(timeline_row)
	for _i in range(3):
		var option := OptionButton.new()
		option.custom_minimum_size = Vector2(335, 42)
		timeline_options.append(option)
		timeline_row.add_child(option)
	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 10)
	box.add_child(action_row)
	timeline_validate_button = _make_button("Validar cronologia", _validate_timeline)
	timeline_validate_button.custom_minimum_size = Vector2(250, 42)
	action_row.add_child(timeline_validate_button)
	var hint_timeline := _make_button("Dica da cronologia", func(): _request_hint("timeline"))
	hint_timeline.custom_minimum_size = Vector2(220, 42)
	action_row.add_child(hint_timeline)
	box.add_child(_make_label("Reconstrução — depois da cronologia correta, percorra as três estações translúcidas na sala.", 15))
	box.add_child(HSeparator.new())

	box.add_child(_make_label("Puzzle 2 — classifique a natureza da afirmação", 20, false))
	var status_ids := ["ev_pf_2024", "ev_stf_judgment_2025", "ev_fiction_draft"]
	for evidence_id in status_ids:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		var label := _make_label("", 14)
		label.name = "Label_%s" % evidence_id
		label.custom_minimum_size = Vector2(500, 36)
		row.add_child(label)
		var option := OptionButton.new()
		option.custom_minimum_size = Vector2(350, 38)
		status_options[evidence_id] = option
		row.add_child(option)
		box.add_child(row)
	var status_action_row := HBoxContainer.new()
	status_action_row.add_theme_constant_override("separation", 10)
	box.add_child(status_action_row)
	status_validate_button = _make_button("Validar classificação", _validate_status)
	status_validate_button.custom_minimum_size = Vector2(250, 42)
	status_action_row.add_child(status_validate_button)
	var hint_status := _make_button("Dica da classificação", func(): _request_hint("status"))
	hint_status.custom_minimum_size = Vector2(220, 42)
	status_action_row.add_child(hint_status)
	box.add_child(HSeparator.new())

	origin_anchor = Control.new()
	origin_anchor.custom_minimum_size = Vector2(0, 2)
	box.add_child(origin_anchor)
	box.add_child(_make_label("Puzzle 3 — rastro documental de ‘Copa 2022’", 20, false))
	box.add_child(_make_label("Preencha os três papéis documentais. Uma peça da acusação é relevante, mas não substitui o julgamento.", 14))
	for prompt_text in CaseManager.ORIGIN_PROMPTS:
		box.add_child(_make_label(str(prompt_text), 14))
		var option := OptionButton.new()
		option.custom_minimum_size = Vector2(820, 40)
		origin_options.append(option)
		box.add_child(option)
	var origin_action_row := HBoxContainer.new()
	origin_action_row.add_theme_constant_override("separation", 10)
	box.add_child(origin_action_row)
	origin_validate_button = _make_button("Validar rastro documental", _validate_origin)
	origin_validate_button.custom_minimum_size = Vector2(250, 42)
	origin_action_row.add_child(origin_validate_button)
	var hint_origin := _make_button("Dica do rastro", func(): _request_hint("origin"))
	hint_origin.custom_minimum_size = Vector2(220, 42)
	origin_action_row.add_child(hint_origin)

	board_feedback = _make_label("", 15)
	board_feedback.custom_minimum_size = Vector2(0, 48)
	box.add_child(board_feedback)
	box.add_child(_make_button("Fechar quadro", _close_board))

func _build_conclusion_panel() -> void:
	conclusion_panel = _make_panel(Vector2(220, 100), Vector2(840, 535), Color(0.02, 0.055, 0.07, 0.99))
	conclusion_panel.visible = false
	ui_root.add_child(conclusion_panel)
	var margin := _make_margin()
	conclusion_panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)
	box.add_child(_make_label("RELATÓRIO PROVISÓRIO — RASTRO DOCUMENTAL", 26, false))
	conclusion_text = _make_label("", 16)
	conclusion_text.custom_minimum_size = Vector2(0, 340)
	box.add_child(conclusion_text)
	box.add_child(_make_button("Voltar à sala", _close_conclusion))

func _show_start_menu() -> void:
	var continue_button = start_panel.find_child("ContinueButton", true, false)
	if continue_button != null:
		continue_button.disabled = not SaveManager.has_save()
	start_panel.visible = true
	_pause_for_ui(true)

func _new_game() -> void:
	GameState.reset_state()
	SaveManager.clear_save()
	_spawn_evidence()
	_spawn_reconstruction()
	start_panel.visible = false
	_pause_for_ui(false)
	_refresh_world_state()
	_show_toast("Caso aberto. Explore a sala; os pontos de evidência respondem à proximidade.")

func _continue_game() -> void:
	if not SaveManager.load_game():
		_new_game()
		return
	_spawn_evidence()
	_spawn_reconstruction()
	start_panel.visible = false
	_pause_for_ui(false)
	_refresh_world_state()
	if GameState.status_solved and not GameState.origin_solved:
		_show_toast("Estado restaurado. A ala documental à direita está liberada.")
	else:
		_show_toast("Estado do caso restaurado.")

func _on_hotspot_focus(hotspot, focused: bool) -> void:
	if focused:
		current_focus = hotspot
		prompt_label.text = "[E / A] Examinar — %s" % hotspot.display_title
	elif current_focus == hotspot:
		current_focus = null
		prompt_label.text = "A/D ou analógico — mover • E/A — examinar • Tab/Y — quadro"

func _on_evidence_activated(evidence_id: String) -> void:
	var item := EvidenceDB.get_evidence(evidence_id)
	if item.is_empty():
		return
	if GameState.discover_evidence(evidence_id):
		AudioManager.play_discovery()
		SaveManager.save_game()
	evidence_title.text = str(item.get("title", "Evidência"))
	evidence_status.text = "STATUS: %s" % _status_display(str(item.get("factual_status", "")))
	evidence_summary.text = str(item.get("summary", ""))
	var source := EvidenceDB.get_source(str(item.get("source_id", "")))
	evidence_source.text = "Origem auditável: %s • %s" % [str(item.get("source_id", "")), str(source.get("label", "fonte não localizada"))]
	evidence_note.text = "Nota de encenação: %s" % str(item.get("fictionalization_note", "Nenhuma."))
	evidence_panel.visible = true
	_pause_for_ui(true)
	_refresh_board()

func _close_evidence() -> void:
	AudioManager.play_ui()
	evidence_panel.visible = false
	_pause_for_ui(false)

func _toggle_board() -> void:
	if start_panel.visible or evidence_panel.visible or conclusion_panel.visible:
		return
	if board_panel.visible:
		_close_board()
	else:
		_open_board()

func _open_board() -> void:
	_refresh_board()
	board_feedback.text = ""
	board_panel.visible = true
	AudioManager.play_ui()
	_pause_for_ui(true)
	if GameState.status_solved and not GameState.origin_solved:
		call_deferred("_focus_origin_section")

func _focus_origin_section() -> void:
	if board_panel.visible and board_scroll != null and origin_anchor != null:
		board_scroll.ensure_control_visible(origin_anchor)

func _close_board() -> void:
	board_panel.visible = false
	AudioManager.play_ui()
	_pause_for_ui(false)

func _populate_option(option: OptionButton) -> void:
	option.clear()
	option.add_item("— selecione —")
	option.set_item_metadata(0, "")
	for evidence_id in GameState.discovered_evidence:
		var item := EvidenceDB.get_evidence(evidence_id)
		if item.is_empty():
			continue
		option.add_item(str(item.get("title", evidence_id)))
		option.set_item_metadata(option.item_count - 1, evidence_id)

func _refresh_board() -> void:
	if board_panel == null:
		return
	board_progress.text = "Evidências: %d/%d • Cronologia: %s • Reconstrução: %d/3 • Status: %s • Rastro: %s" % [
		GameState.discovered_evidence.size(),
		EvidenceDB.evidence_count(),
		"resolvida" if GameState.timeline_solved else "aberta",
		GameState.reconstruction_step,
		"resolvido" if GameState.status_solved else "aberto",
		"resolvido" if GameState.origin_solved else "aberto"
	]
	for option in timeline_options:
		_populate_option(option)
		option.disabled = GameState.timeline_solved
	timeline_validate_button.disabled = not CaseManager.timeline_ready() or GameState.timeline_solved

	for evidence_id in status_options.keys():
		var option: OptionButton = status_options[evidence_id]
		option.clear()
		option.add_item("— selecione —")
		option.set_item_metadata(0, "")
		for status_code in ["ALEGAÇÃO_OFICIAL", "DECISÃO_JUDICIAL", "FICÇÃO_DRAMÁTICA", "CONTEXTO_JORNALÍSTICO"]:
			option.add_item(_status_display(status_code))
			option.set_item_metadata(option.item_count - 1, status_code)
		option.disabled = GameState.status_solved
		var label = board_panel.find_child("Label_%s" % evidence_id, true, false)
		if label != null:
			label.text = str(EvidenceDB.get_evidence(evidence_id).get("title", evidence_id))
	status_validate_button.disabled = not CaseManager.status_ready() or GameState.status_solved

	for option in origin_options:
		_populate_option(option)
		option.disabled = GameState.origin_solved
	origin_validate_button.disabled = not CaseManager.origin_ready() or GameState.origin_solved

func _validate_timeline() -> void:
	var answer: Array = []
	for option in timeline_options:
		answer.append(str(option.get_item_metadata(option.selected)))
	if not CaseManager.validate_timeline(answer):
		AudioManager.play_fail()
		board_feedback.text = "Essa ordem mistura etapas processuais, repete uma peça ou produz contradição temporal."
		return
	GameState.timeline_solved = true
	SaveManager.save_game()
	AudioManager.play_success()
	board_panel.visible = false
	_pause_for_ui(false)
	_spawn_reconstruction()
	_show_toast("Cronologia sustentada. RECONSTRUÇÃO INVESTIGATIVA ativada na sala.")
	_refresh_board()

func _on_marker_focus(marker, focused: bool) -> void:
	if focused:
		current_focus = marker
		prompt_label.text = "[E / A] Reconstruir — %s" % marker.title_text
	elif current_focus == marker:
		current_focus = null
		prompt_label.text = "RECONSTRUÇÃO INVESTIGATIVA • percorra as estações na ordem sustentada"

func _on_reconstruction_activated(step_index: int) -> void:
	if not GameState.timeline_solved:
		return
	if step_index < GameState.reconstruction_step:
		_show_toast("Esta etapa já foi registrada.")
		return
	if step_index != GameState.reconstruction_step:
		AudioManager.play_fail()
		_show_toast("A passagem ainda não se sustenta: falta a etapa anterior.")
		return
	GameState.reconstruction_step += 1
	AudioManager.play_discovery()
	if GameState.reconstruction_step >= 3:
		GameState.reconstruction_complete = true
		_show_toast("Reconstrução fechada. O segundo teste está disponível no quadro.")
	else:
		_show_toast("Etapa %d/3 registrada." % GameState.reconstruction_step)
	SaveManager.save_game()
	_refresh_world_state()

func _validate_status() -> void:
	var answer := {}
	for evidence_id in status_options.keys():
		var option: OptionButton = status_options[evidence_id]
		answer[evidence_id] = str(option.get_item_metadata(option.selected))
	if not CaseManager.validate_status(answer):
		AudioManager.play_fail()
		board_feedback.text = "Uma origem foi elevada ou rebaixada indevidamente. Releia quem está afirmando cada coisa."
		return
	GameState.status_solved = true
	GameState.slice_complete = false
	SaveManager.save_game()
	AudioManager.play_success()
	board_panel.visible = false
	_pause_for_ui(false)
	_spawn_evidence()
	_show_phase_banner()
	_show_toast("Classificação sustentada. Uma segunda ala documental foi liberada à direita.")
	_refresh_world_state()

func _validate_origin() -> void:
	var answer: Array = []
	for option in origin_options:
		answer.append(str(option.get_item_metadata(option.selected)))
	if not CaseManager.validate_origin(answer):
		AudioManager.play_fail()
		board_feedback.text = "Esse rastro confunde investigação, abertura da ação penal, posição da acusação ou julgamento. Releia o papel de cada peça."
		return
	GameState.origin_solved = true
	GameState.slice_complete = true
	SaveManager.save_game()
	AudioManager.play_success()
	board_panel.visible = false
	_show_conclusion()

func _show_conclusion() -> void:
	conclusion_text.text = "O rastro que você sustentou é documental — não uma afirmação sobre o primeiro uso absoluto do nome.\n\n• Em novembro de 2024, uma decisão tornada pública pelo STF registrou, com atribuição à PF, que a operação era denominada pelos investigados de ‘Copa 2022’.\n• Em maio de 2025, o recebimento da denúncia abriu a ação penal; não era condenação.\n• Em novembro de 2025, a sustentação da PGR continuava sendo posição da acusação.\n• O resultado do julgamento é a peça que registra a decisão sobre responsabilidade individual.\n\nA regra do caso permanece: documento, acusação e decisão não são sinônimos."
	conclusion_panel.visible = true
	_pause_for_ui(true)

func _close_conclusion() -> void:
	conclusion_panel.visible = false
	_pause_for_ui(false)
	_show_toast("Marco 0.2 concluído e salvo.")

func _request_hint(puzzle_id: String) -> void:
	var level := GameState.use_hint(puzzle_id)
	SaveManager.save_game()
	board_feedback.text = "Dica %d/3 — %s" % [level, CaseManager.get_hint(puzzle_id, level)]
	AudioManager.play_ui()

func _status_display(status_code: String) -> String:
	return str(STATUS_DISPLAY.get(status_code, status_code.replace("_", " ").capitalize()))

func _pause_for_ui(paused_value: bool) -> void:
	get_tree().paused = paused_value
	if investigator != null:
		investigator.set_controls_enabled(not paused_value)

func _show_phase_banner() -> void:
	phase_banner.visible = true
	var timer := get_tree().create_timer(2.8, true)
	timer.timeout.connect(func():
		phase_banner.visible = false
	)

func _show_toast(message: String) -> void:
	toast_label.text = message
	toast_label.visible = true
	var timer := get_tree().create_timer(3.4, true)
	timer.timeout.connect(func():
		if toast_label.text == message:
			toast_label.visible = false
	)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("case_board"):
		_toggle_board()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_cancel"):
		if evidence_panel.visible:
			_close_evidence()
		elif board_panel.visible:
			_close_board()
		elif conclusion_panel.visible:
			_close_conclusion()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("interact") and evidence_panel.visible:
		_close_evidence()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("hint") and board_panel.visible:
		if GameState.status_solved and not GameState.origin_solved:
			_request_hint("origin")
		elif GameState.timeline_solved and GameState.reconstruction_complete:
			_request_hint("status")
		else:
			_request_hint("timeline")
		get_viewport().set_input_as_handled()
