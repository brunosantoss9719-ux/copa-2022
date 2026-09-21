extends Node2D

const STATUS_DISPLAY := {
	"ALEGAÇÃO_OFICIAL": "Alegação oficial",
	"DECISÃO_JUDICIAL": "Decisão judicial",
	"TESE_DE_DEFESA": "Tese de defesa",
	"CONTEXTO_JORNALÍSTICO": "Contexto jornalístico",
	"FICÇÃO_DRAMÁTICA": "Ficção dramática"
}

const STATUS_CANDIDATES := [
	"ALEGAÇÃO_OFICIAL",
	"DECISÃO_JUDICIAL",
	"FICÇÃO_DRAMÁTICA",
	"CONTEXTO_JORNALÍSTICO"
]

@onready var investigator = $Investigator
@onready var hotspots_root = $Hotspots
@onready var reconstruction_root = $Reconstruction
@onready var phase_gate = $PhaseGate
@onready var individualization_gate = $IndividualizationGate
@onready var contradictory_gate = $ContradictoryGate
@onready var ui_root = $UI

var prompt_label: Label
var toast_label: Label
var objective_panel: PanelContainer
var objective_stage: Label
var objective_text: Label

var start_panel: PanelContainer
var evidence_panel: PanelContainer
var evidence_title: Label
var evidence_status: Label
var evidence_summary: Label
var evidence_source: Label
var evidence_note: Label

var board_panel: PanelContainer
var board_stage_label: Label
var board_progress: Label
var board_question_label: Label
var board_instruction_label: Label
var board_workspace: VBoxContainer
var board_tray: VBoxContainer
var board_feedback: Label
var board_validate_button: Button
var board_hint_button: Button
var board_reset_button: Button
var board_close_button: Button
var board_stage := ""
var board_selected_evidence_id := ""
var board_card_buttons: Dictionary = {}
var board_slot_buttons: Array[Button] = []
var board_status_evidence_buttons: Dictionary = {}

var sequence_answers := {
	"timeline": ["", "", ""],
	"origin": ["", "", ""],
	"individualization": ["", "", ""],
	"contradictory": ["", "", "", ""]
}
var status_answer: Dictionary = {}

var conclusion_panel: PanelContainer
var conclusion_text: Label
var phase_banner: PanelContainer
var phase_banner_label: Label

var mobile_controls: Control
var mobile_left_button: Button
var mobile_right_button: Button
var mobile_interact_button: Button
var mobile_board_button: Button
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
	var available_phase := 1
	if GameState.individualization_solved:
		available_phase = 4
	elif GameState.origin_solved:
		available_phase = 3
	elif GameState.status_solved:
		available_phase = 2
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
	var xs := [640.0, 1190.0, 1710.0]
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
	_refresh_objective_hud()
	if board_panel != null:
		_refresh_board()

func _build_ui() -> void:
	_build_hud()

	prompt_label = Label.new()
	prompt_label.position = Vector2(242, 660)
	prompt_label.size = Vector2(796, 36)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size", 17)
	prompt_label.add_theme_color_override("font_color", Color("#b8c9cc"))
	prompt_label.text = "A/D ou analógico — mover   •   E/A — examinar   •   Tab/Y — hipótese"
	ui_root.add_child(prompt_label)

	toast_label = Label.new()
	toast_label.position = Vector2(220, 594)
	toast_label.size = Vector2(840, 50)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.add_theme_font_size_override("font_size", 17)
	toast_label.add_theme_color_override("font_color", Color("#d9efeb"))
	toast_label.visible = false
	ui_root.add_child(toast_label)

	_build_phase_banner()
	_build_start_panel()
	_build_evidence_panel()
	_build_board_panel()
	_build_conclusion_panel()
	_build_mobile_controls()

func _build_hud() -> void:
	objective_panel = _make_panel(Vector2(24, 22), Vector2(474, 100), Color(0.015, 0.035, 0.045, 0.88), Color(0.25, 0.52, 0.55, 0.38))
	ui_root.add_child(objective_panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	objective_panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	margin.add_child(box)
	objective_stage = _make_label("CASO 01", 13, false, Color("#72c7ba"))
	box.add_child(objective_stage)
	objective_text = _make_label("", 16, true, Color("#d0dcdd"))
	box.add_child(objective_text)

func _make_panel(position_value: Vector2, size_value: Vector2, color: Color, border := Color(0.28, 0.53, 0.59, 0.62)) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = position_value
	panel.size = size_value
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _make_label(text_value: String, size_value := 16, wrap := true, color := Color("#d6e1e2")) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", size_value)
	label.add_theme_color_override("font_color", color)
	if wrap:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _make_button(text_value: String, handler: Callable, min_height := 42) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(0, min_height)
	button.pressed.connect(handler)
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_color_override("font_color", Color("#d8e5e5"))
	button.add_theme_color_override("font_hover_color", Color("#efffff"))
	button.add_theme_stylebox_override("normal", _button_style(Color("#14242c"), Color(0.32, 0.55, 0.58, 0.48)))
	button.add_theme_stylebox_override("hover", _button_style(Color("#1b323a"), Color(0.45, 0.78, 0.75, 0.72)))
	button.add_theme_stylebox_override("pressed", _button_style(Color("#203c42"), Color(0.54, 0.88, 0.82, 0.92)))
	button.add_theme_stylebox_override("disabled", _button_style(Color("#0d171c"), Color(0.25, 0.34, 0.37, 0.36)))
	return button

func _make_margin(left := 28, right := 28, top := 24, bottom := 24) -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", left)
	margin.add_theme_constant_override("margin_right", right)
	margin.add_theme_constant_override("margin_top", top)
	margin.add_theme_constant_override("margin_bottom", bottom)
	return margin

func _build_phase_banner() -> void:
	phase_banner = _make_panel(Vector2(382, 58), Vector2(516, 92), Color(0.02, 0.07, 0.075, 0.96), Color(0.40, 0.78, 0.70, 0.70))
	phase_banner.visible = false
	ui_root.add_child(phase_banner)
	var margin := _make_margin(22, 22, 18, 18)
	phase_banner.add_child(margin)
	phase_banner_label = _make_label("SETOR B LIBERADO\nNovas peças entraram no dossiê.", 19, true, Color("#dff5ef"))
	phase_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	margin.add_child(phase_banner_label)

func _build_start_panel() -> void:
	start_panel = _make_panel(Vector2(286, 132), Vector2(708, 454), Color(0.012, 0.033, 0.044, 0.985), Color(0.32, 0.62, 0.62, 0.70))
	ui_root.add_child(start_panel)
	var margin := _make_margin(38, 38, 30, 30)
	start_panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)

	var eyebrow := _make_label("THRILLER INVESTIGATIVO • RECONSTRUÇÃO DRAMÁTICA", 13, false, Color("#72c7ba"))
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(eyebrow)

	var title := _make_label("LINHA DE SOMBRA", 34, false, Color("#e8f2f1"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var subtitle := _make_label("COPA 2022", 19, false, Color("#b2c6c8"))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(subtitle)

	var rule := HSeparator.new()
	box.add_child(rule)
	box.add_child(_make_label("O dossiê mistura investigação, decisões, teses de defesa e notas internas. Sua tarefa é reconstruir o que cada peça realmente permite afirmar — e em que momento.", 17, true, Color("#c8d7d8")))

	var callout := _make_label("Explore o espaço → examine documentos → monte uma hipótese → confronte-a com a reconstrução.", 15, true, Color("#8fcfc5"))
	callout.custom_minimum_size = Vector2(0, 54)
	box.add_child(callout)

	box.add_child(_make_button("ABRIR NOVO DOSSIÊ", _new_game, 48))
	var continue_button := _make_button("CONTINUAR INVESTIGAÇÃO", _continue_game, 48)
	continue_button.name = "ContinueButton"
	box.add_child(continue_button)
	box.add_child(_make_button("SAIR", func(): get_tree().quit(), 42))

func _build_evidence_panel() -> void:
	evidence_panel = _make_panel(Vector2(174, 92), Vector2(932, 544), Color(0.012, 0.03, 0.039, 0.992), Color(0.34, 0.63, 0.62, 0.66))
	evidence_panel.visible = false
	ui_root.add_child(evidence_panel)
	var margin := _make_margin(34, 34, 26, 26)
	evidence_panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 11)
	margin.add_child(box)

	var eyebrow := _make_label("PEÇA DO DOSSIÊ", 13, false, Color("#71c6b9"))
	box.add_child(eyebrow)
	evidence_title = _make_label("", 27, true, Color("#ecf5f4"))
	box.add_child(evidence_title)

	evidence_status = _make_label("", 14, false, Color("#aabfc1"))
	box.add_child(evidence_status)
	box.add_child(HSeparator.new())

	evidence_summary = _make_label("", 18, true, Color("#d3dfe0"))
	evidence_summary.custom_minimum_size = Vector2(0, 150)
	box.add_child(evidence_summary)

	evidence_source = _make_label("", 14, true, Color("#91aaad"))
	box.add_child(evidence_source)
	evidence_note = _make_label("", 13, true, Color("#87989d"))
	box.add_child(evidence_note)

	var close := _make_button("GUARDAR PEÇA", _close_evidence, 46)
	box.add_child(close)

func _build_board_panel() -> void:
	board_panel = _make_panel(Vector2(42, 28), Vector2(1196, 664), Color(0.009, 0.024, 0.031, 0.995), Color(0.35, 0.66, 0.64, 0.72))
	board_panel.visible = false
	ui_root.add_child(board_panel)

	var margin := _make_margin(26, 26, 20, 18)
	board_panel.add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 18)
	root.add_child(header)
	board_stage_label = _make_label("HIPÓTESE ATIVA", 14, false, Color("#72c7ba"))
	board_stage_label.custom_minimum_size = Vector2(520, 24)
	header.add_child(board_stage_label)
	board_progress = _make_label("", 13, false, Color("#81989c"))
	board_progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	board_progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(board_progress)

	board_question_label = _make_label("", 26, true, Color("#e4efee"))
	board_question_label.custom_minimum_size = Vector2(0, 64)
	root.add_child(board_question_label)
	board_instruction_label = _make_label("", 14, true, Color("#a8bec0"))
	board_instruction_label.custom_minimum_size = Vector2(0, 42)
	root.add_child(board_instruction_label)
	root.add_child(HSeparator.new())

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 20)
	body.custom_minimum_size = Vector2(0, 392)
	root.add_child(body)

	var workspace_panel := PanelContainer.new()
	workspace_panel.custom_minimum_size = Vector2(680, 390)
	workspace_panel.add_theme_stylebox_override("panel", _button_style(Color("#0d1a21"), Color(0.24, 0.43, 0.46, 0.42)))
	body.add_child(workspace_panel)
	var work_margin := _make_margin(18, 18, 16, 16)
	workspace_panel.add_child(work_margin)
	board_workspace = VBoxContainer.new()
	board_workspace.add_theme_constant_override("separation", 10)
	work_margin.add_child(board_workspace)

	var tray_panel := PanelContainer.new()
	tray_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tray_panel.add_theme_stylebox_override("panel", _button_style(Color("#0b171d"), Color(0.22, 0.38, 0.41, 0.42)))
	body.add_child(tray_panel)
	var tray_margin := _make_margin(16, 16, 14, 14)
	tray_panel.add_child(tray_margin)
	var tray_root := VBoxContainer.new()
	tray_root.add_theme_constant_override("separation", 8)
	tray_margin.add_child(tray_root)
	tray_root.add_child(_make_label("BANDEJA DE EVIDÊNCIAS", 13, false, Color("#718f94")))
	var tray_scroll := ScrollContainer.new()
	tray_scroll.custom_minimum_size = Vector2(0, 330)
	tray_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tray_root.add_child(tray_scroll)
	board_tray = VBoxContainer.new()
	board_tray.add_theme_constant_override("separation", 7)
	board_tray.custom_minimum_size = Vector2(410, 0)
	tray_scroll.add_child(board_tray)

	board_feedback = _make_label("", 14, true, Color("#c8d8d8"))
	board_feedback.custom_minimum_size = Vector2(0, 44)
	root.add_child(board_feedback)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	root.add_child(actions)
	board_reset_button = _make_button("LIMPAR", _reset_active_board, 42)
	board_reset_button.custom_minimum_size = Vector2(150, 42)
	actions.add_child(board_reset_button)
	board_hint_button = _make_button("PEDIR PISTA", _request_active_hint, 42)
	board_hint_button.custom_minimum_size = Vector2(170, 42)
	actions.add_child(board_hint_button)
	board_validate_button = _make_button("TESTAR HIPÓTESE", _validate_active_board, 42)
	board_validate_button.custom_minimum_size = Vector2(230, 42)
	actions.add_child(board_validate_button)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(spacer)
	board_close_button = _make_button("VOLTAR À SALA", _close_board, 42)
	board_close_button.custom_minimum_size = Vector2(190, 42)
	actions.add_child(board_close_button)

func _build_conclusion_panel() -> void:
	conclusion_panel = _make_panel(Vector2(186, 78), Vector2(908, 574), Color(0.012, 0.032, 0.04, 0.992), Color(0.40, 0.73, 0.66, 0.72))
	conclusion_panel.visible = false
	ui_root.add_child(conclusion_panel)
	var margin := _make_margin(36, 36, 28, 28)
	conclusion_panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)
	box.add_child(_make_label("RELATÓRIO PROVISÓRIO", 13, false, Color("#72c7ba")))
	box.add_child(_make_label("CONTRADITÓRIO RECONSTRUÍDO", 27, false, Color("#e7f2f1")))
	conclusion_text = _make_label("", 16, true, Color("#cedbdb"))
	conclusion_text.custom_minimum_size = Vector2(0, 384)
	box.add_child(conclusion_text)
	box.add_child(_make_button("VOLTAR À SALA", _close_conclusion, 46))

func _make_mobile_button(text_value: String, position_value: Vector2, size_value: Vector2) -> Button:
	var button := _make_button(text_value, func(): pass, int(size_value.y))
	button.position = position_value
	button.size = size_value
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.add_theme_font_size_override("font_size", 20)
	return button

func _build_mobile_controls(force := false) -> void:
	if mobile_controls != null:
		return
	if not force and not OS.has_feature("mobile"):
		return
	prompt_label.visible = false
	mobile_controls = Control.new()
	mobile_controls.position = Vector2.ZERO
	mobile_controls.size = Vector2(1280, 720)
	mobile_controls.process_mode = Node.PROCESS_MODE_ALWAYS
	ui_root.add_child(mobile_controls)

	mobile_left_button = _make_mobile_button("◀", Vector2(24, 598), Vector2(104, 92))
	mobile_right_button = _make_mobile_button("▶", Vector2(140, 598), Vector2(104, 92))
	mobile_controls.add_child(mobile_left_button)
	mobile_controls.add_child(mobile_right_button)
	mobile_left_button.button_down.connect(func(): Input.action_press("move_left"))
	mobile_left_button.button_up.connect(func(): Input.action_release("move_left"))
	mobile_right_button.button_down.connect(func(): Input.action_press("move_right"))
	mobile_right_button.button_up.connect(func(): Input.action_release("move_right"))

	mobile_interact_button = _make_mobile_button("Examinar", Vector2(1058, 598), Vector2(196, 92))
	mobile_interact_button.disabled = true
	mobile_interact_button.pressed.connect(_mobile_interact)
	mobile_controls.add_child(mobile_interact_button)

	mobile_board_button = _make_mobile_button("Hipótese", Vector2(1068, 24), Vector2(186, 58))
	mobile_board_button.pressed.connect(_toggle_board)
	mobile_controls.add_child(mobile_board_button)

func _mobile_interact() -> void:
	if current_focus == null:
		return
	if current_focus.has_method("activate_from_touch"):
		current_focus.call("activate_from_touch")

func _show_start_menu() -> void:
	var continue_button = start_panel.find_child("ContinueButton", true, false)
	if continue_button != null:
		continue_button.disabled = not SaveManager.has_save()
	start_panel.visible = true
	_pause_for_ui(true)

func _reset_board_answers() -> void:
	sequence_answers = {
		"timeline": ["", "", ""],
		"origin": ["", "", ""],
		"individualization": ["", "", ""],
		"contradictory": ["", "", "", ""]
	}
	status_answer.clear()
	board_selected_evidence_id = ""

func _new_game() -> void:
	GameState.reset_state()
	SaveManager.clear_save()
	_reset_board_answers()
	_spawn_evidence()
	_spawn_reconstruction()
	start_panel.visible = false
	_pause_for_ui(false)
	_refresh_world_state()
	_show_toast("Dossiê aberto. Comece pela triagem: examine as peças iluminadas do Setor A.")

func _continue_game() -> void:
	if not SaveManager.load_game():
		_new_game()
		return
	_reset_board_answers()
	_spawn_evidence()
	_spawn_reconstruction()
	start_panel.visible = false
	_pause_for_ui(false)
	_refresh_world_state()
	_show_toast("Estado restaurado. A pergunta ativa aparece no canto superior esquerdo.")

func _on_hotspot_focus(hotspot, focused: bool) -> void:
	if focused:
		current_focus = hotspot
		prompt_label.text = "[E / A] Examinar — %s" % hotspot.display_title
		if mobile_interact_button != null:
			mobile_interact_button.text = "Examinar"
			mobile_interact_button.disabled = false
	elif current_focus == hotspot:
		current_focus = null
		prompt_label.text = "A/D ou analógico — mover   •   E/A — examinar   •   Tab/Y — hipótese"
		if mobile_interact_button != null:
			mobile_interact_button.disabled = true

func _on_evidence_activated(evidence_id: String) -> void:
	var item := EvidenceDB.get_evidence(evidence_id)
	if item.is_empty():
		return
	if GameState.discover_evidence(evidence_id):
		AudioManager.play_discovery()
		SaveManager.save_game()

	evidence_title.text = str(item.get("title", "Evidência"))
	var status_code := str(item.get("factual_status", ""))
	if not GameState.status_solved and int(item.get("phase", 1)) == 1:
		evidence_status.text = "CLASSIFICAÇÃO PENDENTE — observe quem fala, em qual etapa e com qual autoridade."
		evidence_status.add_theme_color_override("font_color", Color("#d6a862"))
	else:
		evidence_status.text = "ENQUADRAMENTO: %s" % _status_display(status_code)
		evidence_status.add_theme_color_override("font_color", _status_color(status_code))

	evidence_summary.text = str(item.get("summary", ""))
	var source := EvidenceDB.get_source(str(item.get("source_id", "")))
	evidence_source.text = "FONTE: %s  •  %s" % [str(item.get("source_id", "")), str(source.get("label", "fonte não localizada"))]
	evidence_note.text = "ENCENAÇÃO: %s" % str(item.get("fictionalization_note", "Nenhuma."))
	evidence_panel.visible = true
	_pause_for_ui(true)
	_refresh_world_state()

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
	board_feedback.text = ""
	board_selected_evidence_id = ""
	_refresh_board()
	board_panel.visible = true
	AudioManager.play_ui()
	_pause_for_ui(true)

func _close_board() -> void:
	board_panel.visible = false
	board_selected_evidence_id = ""
	AudioManager.play_ui()
	_pause_for_ui(false)

func _active_board_stage() -> String:
	if not GameState.timeline_solved:
		return "timeline"
	if not GameState.reconstruction_complete:
		return "reconstruction"
	if not GameState.status_solved:
		return "status"
	if not GameState.origin_solved:
		return "origin"
	if not GameState.individualization_solved:
		return "individualization"
	if not GameState.contradictory_solved:
		return "contradictory"
	return "complete"

func _stage_number(stage: String) -> int:
	match stage:
		"timeline":
			return 1
		"reconstruction":
			return 2
		"status":
			return 3
		"origin":
			return 4
		"individualization":
			return 5
		"contradictory":
			return 6
		_:
			return 6

func _stage_question(stage: String) -> String:
	match stage:
		"timeline":
			return "Em que ordem o dossiê muda de hipótese investigativa para estado processual?"
		"reconstruction":
			return "A sequência parece correta no papel. Ela continua coerente quando você a percorre no espaço?"
		"status":
			return "Quem está afirmando cada coisa — investigação, tribunal ou a própria encenação?"
		"origin":
			return "Qual é o rastro documental sustentado para o nome “Copa 2022”?"
		"individualization":
			return "Onde as generalizações sobre o grupo quebram quando você olha pessoa e etapa?"
		"contradictory":
			return "O que foi tese de defesa e o que foi resultado judicial para cada pessoa?"
		_:
			return "O dossiê provisório está reconstruído."

func _stage_instruction(stage: String) -> String:
	match stage:
		"timeline":
			return "Selecione uma evidência na bandeja e encaixe-a em um dos três momentos. Você pode substituir ou limpar qualquer slot antes de testar."
		"reconstruction":
			return "Feche o quadro e atravesse as três projeções translúcidas na ordem. Cada estação testa se a passagem anterior realmente se sustenta."
		"status":
			return "Selecione uma das três peças à esquerda e aplique um carimbo da bandeja. O jogo não revela o enquadramento antes desta etapa."
		"origin":
			return "Monte um rastro: ligação do nome à investigação → abertura da ação penal → resultado do julgamento. Há uma peça acusatória que não substitui decisão."
		"individualization":
			return "Use as peças que derrubam três generalizações. Nota interna pode orientar método, mas não prova resultado."
		"contradictory":
			return "Monte dois pares históricos: primeiro o que a defesa sustentou; depois o que o tribunal decidiu. Não transforme uma coisa na outra."
		_:
			return "Volte à sala para revisar as peças ou leia o relatório provisório."

func _stage_evidence_ids(stage: String) -> Array:
	match stage:
		"timeline":
			return ["ev_pf_2024", "ev_copa_label", "ev_stf_vote_2025", "ev_stf_judgment_2025", "ev_anpp_2026", "ev_fiction_draft"]
		"origin":
			return ["ev_pet13236_2024", "ev_denuncia_received_2025", "ev_pgr_argument_2025", "ev_stf_judgment_2025"]
		"individualization":
			return ["ev_denuncia_filtered_2025", "ev_acquittal_2025", "ev_anpp_2026", "ev_group_method_note"]
		"contradictory":
			return ["ev_defense_bernardo_2025", "ev_outcome_bernardo_2025", "ev_defense_marcio_2025", "ev_outcome_marcio_2025", "ev_pgr_argument_2025"]
		_:
			return []

func _stage_prompts(stage: String) -> Array:
	match stage:
		"timeline":
			return [
				"ANTES — qual peça registra a investigação?",
				"VIRADA — qual peça registra o resultado do julgamento?",
				"DEPOIS — qual decisão posterior preserva situações individuais?"
			]
		"origin":
			return CaseManager.ORIGIN_PROMPTS
		"individualization":
			return CaseManager.INDIVIDUALIZATION_PROMPTS
		"contradictory":
			return CaseManager.CONTRADICTORY_PROMPTS
		_:
			return []

func _clear_container(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func _refresh_board() -> void:
	if board_panel == null:
		return
	board_stage = _active_board_stage()
	board_card_buttons.clear()
	board_slot_buttons.clear()
	board_status_evidence_buttons.clear()
	_clear_container(board_workspace)
	_clear_container(board_tray)

	board_stage_label.text = "HIPÓTESE %d/6  •  %s" % [_stage_number(board_stage), _stage_name(board_stage)]
	board_progress.text = "%d/%d peças localizadas" % [GameState.discovered_evidence.size(), EvidenceDB.evidence_count()]
	board_question_label.text = _stage_question(board_stage)
	board_instruction_label.text = _stage_instruction(board_stage)

	board_validate_button.visible = not (board_stage in ["reconstruction", "complete"])
	board_reset_button.visible = not (board_stage in ["reconstruction", "complete"])
	board_hint_button.visible = not (board_stage in ["reconstruction", "complete"])

	if board_stage == "status":
		_build_status_board()
	elif board_stage in ["timeline", "origin", "individualization", "contradictory"]:
		_build_sequence_board(board_stage)
	elif board_stage == "reconstruction":
		_build_reconstruction_board()
	else:
		_build_complete_board()

func _stage_name(stage: String) -> String:
	match stage:
		"timeline":
			return "SEQUÊNCIA"
		"reconstruction":
			return "RECONSTRUÇÃO"
		"status":
			return "AUTORIDADE DA PEÇA"
		"origin":
			return "RASTRO DOCUMENTAL"
		"individualization":
			return "INDIVIDUALIZAÇÃO"
		"contradictory":
			return "CONTRADITÓRIO"
		_:
			return "RELATÓRIO"

func _build_sequence_board(stage: String) -> void:
	board_workspace.add_child(_make_label("LINHA DE RACIOCÍNIO", 13, false, Color("#6f9297")))
	var prompts := _stage_prompts(stage)
	var answer := _get_sequence_answer(stage)

	for i in range(prompts.size()):
		var slot_panel := PanelContainer.new()
		slot_panel.add_theme_stylebox_override("panel", _button_style(Color("#101f26"), Color(0.30, 0.49, 0.51, 0.42)))
		board_workspace.add_child(slot_panel)
		var margin := _make_margin(14, 14, 10, 10)
		slot_panel.add_child(margin)
		var slot_box := VBoxContainer.new()
		slot_box.add_theme_constant_override("separation", 5)
		margin.add_child(slot_box)
		slot_box.add_child(_make_label(str(prompts[i]), 13, true, Color("#9eb5b8")))
		var evidence_id := str(answer[i]) if i < answer.size() else ""
		var slot_text := "＋ ENCAIXAR EVIDÊNCIA"
		if not evidence_id.is_empty():
			slot_text = "▣ %s" % _short_title(evidence_id, 62)
		var slot_button := _make_button(slot_text, Callable(self, "_place_selected_in_slot").bind(i), 48)
		slot_box.add_child(slot_button)
		board_slot_buttons.append(slot_button)

	board_tray.add_child(_make_label("Toque numa peça; depois toque no slot.", 12, true, Color("#779095")))
	for evidence_id in _stage_evidence_ids(stage):
		if not GameState.has_evidence(str(evidence_id)):
			continue
		_add_evidence_card(str(evidence_id), stage)

	var complete := _sequence_complete(stage)
	board_validate_button.disabled = not _stage_ready(stage) or not complete
	if board_selected_evidence_id.is_empty():
		board_feedback.text = "Selecione uma peça na bandeja para começar." if not complete else "Linha preenchida. Teste a hipótese quando estiver satisfeito."
	else:
		board_feedback.text = "Selecionada: %s. Agora toque no slot desejado." % _short_title(board_selected_evidence_id, 72)

func _add_evidence_card(evidence_id: String, stage: String) -> void:
	var item := EvidenceDB.get_evidence(evidence_id)
	if item.is_empty():
		return
	var used := evidence_id in _get_sequence_answer(stage)
	var prefix := "✓ " if used else ""
	if evidence_id == board_selected_evidence_id:
		prefix = "◆ "
	var card := _make_button("%s%s" % [prefix, _short_title(evidence_id, 54)], Callable(self, "_select_board_evidence").bind(evidence_id), 52)
	if evidence_id == board_selected_evidence_id:
		card.add_theme_stylebox_override("normal", _button_style(Color("#1d3a3d"), Color(0.48, 0.84, 0.78, 0.92)))
	board_tray.add_child(card)
	board_card_buttons[evidence_id] = card

func _select_board_evidence(evidence_id: String) -> void:
	if board_selected_evidence_id == evidence_id:
		board_selected_evidence_id = ""
	else:
		board_selected_evidence_id = evidence_id
	AudioManager.play_ui()
	_refresh_board()

func _place_selected_in_slot(index: int) -> void:
	if not (board_stage in ["timeline", "origin", "individualization", "contradictory"]):
		return
	var answer := _get_sequence_answer(board_stage)
	if index < 0 or index >= answer.size():
		return
	if board_selected_evidence_id.is_empty():
		answer[index] = ""
		_set_sequence_answer(board_stage, answer)
		AudioManager.play_ui()
		_refresh_board()
		return

	for i in range(answer.size()):
		if str(answer[i]) == board_selected_evidence_id:
			answer[i] = ""
	answer[index] = board_selected_evidence_id
	_set_sequence_answer(board_stage, answer)
	board_selected_evidence_id = ""
	AudioManager.play_ui()
	_refresh_board()

func _build_status_board() -> void:
	board_workspace.add_child(_make_label("PEÇAS PARA CARIMBAR", 13, false, Color("#6f9297")))
	var ids := ["ev_pf_2024", "ev_stf_judgment_2025", "ev_fiction_draft"]
	for evidence_id in ids:
		var item := EvidenceDB.get_evidence(evidence_id)
		var discovered := GameState.has_evidence(evidence_id)
		var assigned := str(status_answer.get(evidence_id, ""))
		var text := "PEÇA AINDA NÃO LOCALIZADA"
		if discovered:
			text = _short_title(evidence_id, 62)
			if not assigned.is_empty():
				text += "\nCARIMBO: %s" % _status_display(assigned)
		var button := _make_button(text, Callable(self, "_select_status_evidence").bind(evidence_id), 72)
		button.disabled = not discovered
		if evidence_id == board_selected_evidence_id:
			button.add_theme_stylebox_override("normal", _button_style(Color("#1d3a3d"), Color(0.48, 0.84, 0.78, 0.92)))
		board_workspace.add_child(button)
		board_status_evidence_buttons[evidence_id] = button

	board_tray.add_child(_make_label("CARIMBOS", 13, false, Color("#6f9297")))
	board_tray.add_child(_make_label("Selecione primeiro uma peça à esquerda.", 12, true, Color("#779095")))
	for status_code in STATUS_CANDIDATES:
		var stamp := _make_button(_status_display(status_code).to_upper(), Callable(self, "_apply_status_stamp").bind(status_code), 54)
		stamp.disabled = board_selected_evidence_id.is_empty()
		board_tray.add_child(stamp)

	board_validate_button.disabled = not CaseManager.status_ready() or status_answer.size() < 3
	if board_selected_evidence_id.is_empty():
		board_feedback.text = "Escolha uma peça. Depois aplique o carimbo que descreve a autoridade daquela afirmação."
	else:
		board_feedback.text = "Peça selecionada: %s." % _short_title(board_selected_evidence_id, 72)

func _select_status_evidence(evidence_id: String) -> void:
	if not GameState.has_evidence(evidence_id):
		return
	board_selected_evidence_id = evidence_id if board_selected_evidence_id != evidence_id else ""
	AudioManager.play_ui()
	_refresh_board()

func _apply_status_stamp(status_code: String) -> void:
	if board_selected_evidence_id.is_empty():
		return
	status_answer[board_selected_evidence_id] = status_code
	board_selected_evidence_id = ""
	AudioManager.play_ui()
	_refresh_board()

func _build_reconstruction_board() -> void:
	board_feedback.text = "A hipótese não avança por outro formulário. Ela precisa ser confrontada na sala."
	var callout := PanelContainer.new()
	callout.add_theme_stylebox_override("panel", _button_style(Color("#10252a"), Color(0.39, 0.73, 0.68, 0.60)))
	board_workspace.add_child(callout)
	var margin := _make_margin(22, 22, 20, 20)
	callout.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)
	box.add_child(_make_label("VOLTE AO ESPAÇO", 14, false, Color("#72c7ba")))
	box.add_child(_make_label("Três projeções apareceram no Setor A.", 23, true, Color("#e2eceb")))
	box.add_child(_make_label("Atravesse-as na ordem que você acabou de sustentar. Se tentar pular uma passagem, a reconstrução recusa a sequência.", 16, true, Color("#b8cacc")))
	box.add_child(_make_label("Progresso: %d/3 estações registradas" % GameState.reconstruction_step, 15, false, Color("#8fcfc5")))
	board_tray.add_child(_make_label("Nenhuma seleção é necessária aqui.", 13, true, Color("#718b90")))

func _build_complete_board() -> void:
	board_feedback.text = "O caminho crítico deste dossiê está concluído."
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	board_workspace.add_child(box)
	box.add_child(_make_label("RELATÓRIO PROVISÓRIO PRONTO", 22, false, Color("#dff2ee")))
	box.add_child(_make_label("As peças foram organizadas sem apagar as diferenças entre investigação, acusação, defesa e decisão judicial.", 16, true, Color("#b9cccd")))
	var report_button := _make_button("ABRIR RELATÓRIO", _show_conclusion, 50)
	box.add_child(report_button)
	board_tray.add_child(_make_label("Você ainda pode voltar à sala e revisar qualquer peça descoberta.", 13, true, Color("#718b90")))

func _short_title(evidence_id: String, limit := 58) -> String:
	var item := EvidenceDB.get_evidence(evidence_id)
	var title := str(item.get("title", evidence_id))
	if title.length() <= limit:
		return title
	return title.substr(0, limit - 1) + "…"

func _get_sequence_answer(stage: String) -> Array:
	var value = sequence_answers.get(stage, [])
	if value is Array:
		return value.duplicate()
	return []

func _set_sequence_answer(stage: String, answer: Array) -> void:
	sequence_answers[stage] = answer.duplicate()

func _sequence_complete(stage: String) -> bool:
	var answer := _get_sequence_answer(stage)
	if answer.is_empty():
		return false
	for value in answer:
		if str(value).is_empty():
			return false
	return true

func _stage_ready(stage: String) -> bool:
	match stage:
		"timeline":
			return CaseManager.timeline_ready()
		"status":
			return CaseManager.status_ready()
		"origin":
			return CaseManager.origin_ready()
		"individualization":
			return CaseManager.individualization_ready()
		"contradictory":
			return CaseManager.contradictory_ready()
		_:
			return false

func _reset_active_board() -> void:
	board_selected_evidence_id = ""
	if board_stage == "status":
		status_answer.clear()
	elif board_stage in ["timeline", "origin", "individualization", "contradictory"]:
		var slots := _get_sequence_answer(board_stage)
		for i in range(slots.size()):
			slots[i] = ""
		_set_sequence_answer(board_stage, slots)
	AudioManager.play_ui()
	_refresh_board()

func _request_active_hint() -> void:
	if board_stage in ["timeline", "status", "origin", "individualization", "contradictory"]:
		_request_hint(board_stage)

func _validate_active_board() -> void:
	match board_stage:
		"timeline":
			_validate_timeline()
		"status":
			_validate_status()
		"origin":
			_validate_origin()
		"individualization":
			_validate_individualization()
		"contradictory":
			_validate_contradictory()

func _validate_timeline() -> void:
	var answer := _get_sequence_answer("timeline")
	if not CaseManager.validate_timeline(answer):
		AudioManager.play_fail()
		board_feedback.text = "A sequência ainda mistura etapas ou usa uma peça que não marca a passagem pedida."
		return
	GameState.timeline_solved = true
	SaveManager.save_game()
	AudioManager.play_success()
	board_panel.visible = false
	_pause_for_ui(false)
	_spawn_reconstruction()
	_refresh_world_state()
	_show_toast("Hipótese montada. Três projeções surgiram no Setor A: confronte a sequência no espaço.")

func _on_marker_focus(marker, focused: bool) -> void:
	if focused:
		current_focus = marker
		prompt_label.text = "[E / A] Registrar passagem — %s" % marker.title_text
		if mobile_interact_button != null:
			mobile_interact_button.text = "Registrar"
			mobile_interact_button.disabled = false
	elif current_focus == marker:
		current_focus = null
		prompt_label.text = "RECONSTRUÇÃO • percorra as projeções na ordem sustentada"
		if mobile_interact_button != null:
			mobile_interact_button.text = "Examinar"
			mobile_interact_button.disabled = true

func _on_reconstruction_activated(step_index: int) -> void:
	if not GameState.timeline_solved:
		return
	if step_index < GameState.reconstruction_step:
		_show_toast("Essa passagem já foi registrada.")
		return
	if step_index != GameState.reconstruction_step:
		AudioManager.play_fail()
		_show_toast("A reconstrução recusa o salto: falta a passagem anterior.")
		return
	GameState.reconstruction_step += 1
	AudioManager.play_discovery()
	if GameState.reconstruction_step >= 3:
		GameState.reconstruction_complete = true
		_show_toast("Reconstrução coerente. Agora classifique a autoridade das peças no quadro.")
	else:
		_show_toast("Passagem %d/3 registrada." % GameState.reconstruction_step)
	SaveManager.save_game()
	_refresh_world_state()

func _validate_status() -> void:
	if not CaseManager.validate_status(status_answer):
		AudioManager.play_fail()
		board_feedback.text = "Um carimbo confunde quem afirmou com quem decidiu. Releia a origem e a etapa de cada peça."
		return
	GameState.status_solved = true
	GameState.slice_complete = false
	phase_gate.call("sync_now")
	SaveManager.save_game()
	AudioManager.play_success()
	board_panel.visible = false
	_pause_for_ui(false)
	_spawn_evidence()
	_show_phase_banner("SETOR B LIBERADO\nO arquivo processual foi aberto.")
	_show_toast("Classificação sustentada. Novas peças estão disponíveis no Setor B.")
	_refresh_world_state()

func _validate_origin() -> void:
	var answer := _get_sequence_answer("origin")
	if not CaseManager.validate_origin(answer):
		AudioManager.play_fail()
		board_feedback.text = "Esse rastro confunde investigação, abertura da ação penal, posição da acusação ou julgamento."
		return
	GameState.origin_solved = true
	GameState.slice_complete = false
	individualization_gate.call("sync_now")
	SaveManager.save_game()
	AudioManager.play_success()
	board_panel.visible = false
	_pause_for_ui(false)
	_spawn_evidence()
	_show_phase_banner("SETOR C LIBERADO\nCompare pessoas e etapas.")
	_show_toast("Rastro sustentado. O Setor C abriu uma pergunta nova: onde a generalização quebra?")
	_refresh_world_state()

func _validate_individualization() -> void:
	var answer := _get_sequence_answer("individualization")
	if not CaseManager.validate_individualization(answer):
		AudioManager.play_fail()
		board_feedback.text = "A generalização ainda não foi derrubada pela peça certa. Priorize resultados individuais."
		return
	GameState.individualization_solved = true
	GameState.slice_complete = false
	contradictory_gate.call("sync_now")
	SaveManager.save_game()
	AudioManager.play_success()
	board_panel.visible = false
	_pause_for_ui(false)
	_spawn_evidence()
	_show_phase_banner("SETOR D LIBERADO\nSepare tese de defesa e resultado.")
	_show_toast("Individualização sustentada. O Setor D abre o contraditório.")
	_refresh_world_state()

func _validate_contradictory() -> void:
	var answer := _get_sequence_answer("contradictory")
	if not CaseManager.validate_contradictory(answer):
		AudioManager.play_fail()
		board_feedback.text = "O par mistura pessoa, parte processual ou resultado. Separe o que foi sustentado do que foi decidido."
		return
	GameState.contradictory_solved = true
	GameState.slice_complete = true
	SaveManager.save_game()
	AudioManager.play_success()
	board_panel.visible = false
	_show_conclusion()
	_refresh_world_state()

func _show_conclusion() -> void:
	conclusion_text.text = "O relatório agora preserva o contraditório.\n\n• A defesa de Bernardo pediu absolvição e questionou a força e o contexto das provas; depois, o resultado judicial registrou sua condenação.\n\n• A defesa de Márcio sustentou participação limitada e comparou sua situação a acusações rejeitadas; no julgamento, ele foi condenado após reenquadramento para crimes menos graves do que os apontados na denúncia.\n\nAs duas camadas permanecem lado a lado. Tese de defesa documenta o que uma parte sustentou. Decisão judicial documenta o que o tribunal decidiu. Uma não é reescrita pela outra."
	conclusion_panel.visible = true
	_pause_for_ui(true)

func _close_conclusion() -> void:
	conclusion_panel.visible = false
	_pause_for_ui(false)
	_show_toast("Dossiê provisório salvo. Você pode revisar qualquer peça na sala.")

func _request_hint(puzzle_id: String) -> void:
	var level := GameState.use_hint(puzzle_id)
	SaveManager.save_game()
	board_feedback.text = "PISTA %d/3 — %s" % [level, CaseManager.get_hint(puzzle_id, level)]
	AudioManager.play_ui()

func _refresh_objective_hud() -> void:
	if objective_stage == null:
		return
	var stage := _active_board_stage()
	match stage:
		"timeline":
			objective_stage.text = "SETOR A · TRIAGEM"
			objective_text.text = "Localize peças suficientes e abra HIPÓTESE para montar a primeira sequência."
		"reconstruction":
			objective_stage.text = "SETOR A · RECONSTRUÇÃO"
			objective_text.text = "Percorra as três projeções na ordem sustentada (%d/3)." % GameState.reconstruction_step
		"status":
			objective_stage.text = "QUADRO · AUTORIDADE"
			objective_text.text = "Carimbe quem está afirmando cada coisa para liberar o arquivo processual."
		"origin":
			objective_stage.text = "SETOR B · RASTRO"
			objective_text.text = "Examine as novas peças e reconstrua o rastro documental de “Copa 2022”."
		"individualization":
			objective_stage.text = "SETOR C · INDIVIDUALIZAÇÃO"
			objective_text.text = "Procure resultados diferentes entre pessoas e etapas. Depois volte à hipótese."
		"contradictory":
			objective_stage.text = "SETOR D · CONTRADITÓRIO"
			objective_text.text = "Reúna tese e resultado para cada pessoa sem misturar as duas camadas."
		_:
			objective_stage.text = "DOSSIÊ · RELATÓRIO"
			objective_text.text = "Caminho crítico concluído. Revise as peças ou abra o relatório no quadro."

func _status_display(status_code: String) -> String:
	return str(STATUS_DISPLAY.get(status_code, status_code.replace("_", " ").capitalize()))

func _status_color(status_code: String) -> Color:
	match status_code:
		"ALEGAÇÃO_OFICIAL":
			return Color("#d6a862")
		"TESE_DE_DEFESA":
			return Color("#ba9bd4")
		"FICÇÃO_DRAMÁTICA":
			return Color("#d4c778")
		_:
			return Color("#76c8bc")

func _pause_for_ui(paused_value: bool) -> void:
	get_tree().paused = paused_value
	if paused_value:
		Input.action_release("move_left")
		Input.action_release("move_right")
	if investigator != null:
		investigator.set_controls_enabled(not paused_value)
	if mobile_controls != null:
		mobile_controls.visible = not paused_value

func _show_phase_banner(message: String = "SETOR B LIBERADO\nNovas peças entraram no dossiê.") -> void:
	phase_banner_label.text = message
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
		_request_active_hint()
		get_viewport().set_input_as_handled()
