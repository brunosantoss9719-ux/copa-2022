extends Node

var failures: Array[String] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _select_metadata(option: OptionButton, wanted: String) -> bool:
	for index in range(option.item_count):
		if str(option.get_item_metadata(index)) == wanted:
			option.select(index)
			return true
	return false

func _run() -> void:
	SaveManager.clear_save()
	GameState.reset_state()

	var packed: PackedScene = load("res://scenes/Main.tscn") as PackedScene
	_check(packed != null, "Main.tscn não carregou no flow probe")
	if packed == null:
		_finish()
		return

	var main: Node = packed.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	main.call("_new_game")
	_check(not get_tree().paused, "Novo jogo não liberou a cena")

	var evidence_ids: Array[String] = [
		"ev_pf_2024",
		"ev_copa_label",
		"ev_stf_vote_2025",
		"ev_stf_judgment_2025",
		"ev_anpp_2026",
		"ev_fiction_draft"
	]
	for evidence_id in evidence_ids:
		main.call("_on_evidence_activated", evidence_id)
		_check(GameState.has_evidence(evidence_id), "Evidência não registrada: %s" % evidence_id)
		main.call("_close_evidence")

	_check(GameState.discovered_evidence.size() == EvidenceDB.evidence_count(), "Fluxo não coletou todas as evidências")
	main.call("_refresh_board")

	var timeline_options_value: Variant = main.get("timeline_options")
	_check(timeline_options_value is Array, "timeline_options indisponível")
	if timeline_options_value is Array:
		var timeline_options: Array = timeline_options_value
		var timeline_solution: Array[String] = [
			"ev_pf_2024",
			"ev_stf_judgment_2025",
			"ev_anpp_2026"
		]
		for index in range(timeline_solution.size()):
			var option: OptionButton = timeline_options[index] as OptionButton
			_check(option != null, "OptionButton da cronologia ausente")
			if option != null:
				_check(_select_metadata(option, timeline_solution[index]), "Opção da cronologia não encontrada: %s" % timeline_solution[index])
		main.call("_validate_timeline")

	_check(GameState.timeline_solved, "Cronologia correta não avançou o fluxo")

	for step_index in range(3):
		main.call("_on_reconstruction_activated", step_index)

	_check(GameState.reconstruction_complete, "Reconstrução completa não foi marcada")
	main.call("_refresh_board")

	var status_options_value: Variant = main.get("status_options")
	_check(status_options_value is Dictionary, "status_options indisponível")
	if status_options_value is Dictionary:
		var status_options: Dictionary = status_options_value
		var expected: Dictionary = {
			"ev_pf_2024": "ALEGAÇÃO_OFICIAL",
			"ev_stf_judgment_2025": "DECISÃO_JUDICIAL",
			"ev_fiction_draft": "FICÇÃO_DRAMÁTICA"
		}
		for evidence_id in expected.keys():
			var option: OptionButton = status_options.get(evidence_id) as OptionButton
			_check(option != null, "OptionButton de status ausente: %s" % evidence_id)
			if option != null:
				_check(_select_metadata(option, str(expected[evidence_id])), "Status não encontrado para %s" % evidence_id)
		main.call("_validate_status")

	_check(GameState.status_solved, "Classificação correta não avançou")
	_check(GameState.slice_complete, "Slice não terminou após o caminho correto")
	var conclusion_panel: PanelContainer = main.get("conclusion_panel") as PanelContainer
	_check(conclusion_panel != null and conclusion_panel.visible, "Relatório provisório final não foi exibido")
	_check(SaveManager.has_save(), "Fluxo completo não deixou save")

	SaveManager.clear_save()
	main.queue_free()
	await get_tree().process_frame
	_finish()

func _finish() -> void:
	if failures.is_empty():
		print("FLOW_OK: caminho crítico completo validado da abertura ao relatório final.")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error("FLOW_FAIL: %s" % failure)
	get_tree().quit(1)
