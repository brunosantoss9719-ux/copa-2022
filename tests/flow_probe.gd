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

func _collect(main: Node, evidence_ids: Array[String]) -> void:
	for evidence_id in evidence_ids:
		main.call("_on_evidence_activated", evidence_id)
		_check(GameState.has_evidence(evidence_id), "Evidência não registrada: %s" % evidence_id)
		main.call("_close_evidence")

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
	var investigator: CharacterBody2D = main.get_node("Investigator") as CharacterBody2D
	var phase_gate: Node = main.get_node("PhaseGate")
	var individualization_gate: Node = main.get_node("IndividualizationGate")
	investigator.position.x = 2760.0
	await get_tree().physics_frame
	await get_tree().process_frame
	_check(investigator.position.x <= 2050.1, "Ala II acessível antes da classificação")
	_check(not bool(phase_gate.call("is_unlocked")), "Porta da ala II começou liberada")

	_collect(main, [
		"ev_pf_2024",
		"ev_copa_label",
		"ev_stf_vote_2025",
		"ev_stf_judgment_2025",
		"ev_anpp_2026",
		"ev_fiction_draft"
	])
	_check(GameState.discovered_evidence.size() == 6, "Primeira ala deveria ter seis evidências")
	main.call("_refresh_board")

	var timeline_options: Array = main.get("timeline_options")
	var timeline_solution: Array[String] = ["ev_pf_2024", "ev_stf_judgment_2025", "ev_anpp_2026"]
	for index in range(timeline_solution.size()):
		var option: OptionButton = timeline_options[index] as OptionButton
		_check(option != null and _select_metadata(option, timeline_solution[index]), "Falha ao montar cronologia")
	main.call("_validate_timeline")
	_check(GameState.timeline_solved, "Cronologia correta não avançou o fluxo")

	for step_index in range(3):
		main.call("_on_reconstruction_activated", step_index)
	_check(GameState.reconstruction_complete, "Reconstrução completa não foi marcada")
	main.call("_refresh_board")

	var status_options: Dictionary = main.get("status_options")
	var expected_status: Dictionary = {
		"ev_pf_2024": "ALEGAÇÃO_OFICIAL",
		"ev_stf_judgment_2025": "DECISÃO_JUDICIAL",
		"ev_fiction_draft": "FICÇÃO_DRAMÁTICA"
	}
	for evidence_id in expected_status.keys():
		var option: OptionButton = status_options.get(evidence_id) as OptionButton
		_check(option != null and _select_metadata(option, str(expected_status[evidence_id])), "Falha ao classificar %s" % evidence_id)
	main.call("_validate_status")
	_check(GameState.status_solved, "Classificação correta não liberou a segunda ala")
	_check(not GameState.slice_complete, "Slice terminou antes do rastro documental")
	_check(bool(phase_gate.call("is_unlocked")), "Marco visual da ala II não foi liberado")
	var phase_banner: PanelContainer = main.get("phase_banner") as PanelContainer
	_check(phase_banner != null and phase_banner.visible, "Transição ARQUIVO II não foi exibida")
	investigator.position.x = 2760.0
	await get_tree().physics_frame
	await get_tree().process_frame
	_check(investigator.position.x > 2050.0, "Limite físico da ala II não abriu")
	main.call("_open_board")
	await get_tree().process_frame
	await get_tree().process_frame
	var board_scroll: ScrollContainer = main.get("board_scroll") as ScrollContainer
	_check(board_scroll != null and board_scroll.scroll_vertical > 0, "Quadro não focou automaticamente o Puzzle 3")
	main.call("_close_board")

	_collect(main, ["ev_pet13236_2024", "ev_denuncia_received_2025", "ev_pgr_argument_2025"])
	_check(GameState.discovered_evidence.size() == 9, "Segunda ala deveria encerrar com nove evidências antes do Arquivo III")
	main.call("_refresh_board")

	var origin_options: Array = main.get("origin_options")
	var origin_solution: Array[String] = ["ev_pet13236_2024", "ev_denuncia_received_2025", "ev_stf_judgment_2025"]
	for index in range(origin_solution.size()):
		var option: OptionButton = origin_options[index] as OptionButton
		_check(option != null and _select_metadata(option, origin_solution[index]), "Falha ao montar rastro documental")
	main.call("_validate_origin")

	_check(GameState.origin_solved, "Rastro documental correto não avançou")
	_check(not GameState.slice_complete, "Slice terminou antes da individualização")
	_check(bool(individualization_gate.call("is_unlocked")), "Marco visual do Arquivo III não foi liberado")
	var phase_banner_after_origin: PanelContainer = main.get("phase_banner") as PanelContainer
	_check(phase_banner_after_origin != null and phase_banner_after_origin.visible, "Transição ARQUIVO III não foi exibida")
	investigator.position.x = 3600.0
	await get_tree().physics_frame
	await get_tree().process_frame
	_check(investigator.position.x > 2900.0, "Limite físico do Arquivo III não abriu")

	_collect(main, ["ev_denuncia_filtered_2025", "ev_acquittal_2025", "ev_group_method_note"])
	_check(GameState.discovered_evidence.size() == EvidenceDB.evidence_count(), "Fluxo não coletou todas as evidências 0.3")
	main.call("_refresh_board")
	main.call("_open_board")
	await get_tree().process_frame
	await get_tree().process_frame
	_check(board_scroll.scroll_vertical > 0, "Quadro não focou o Puzzle 4")
	main.call("_close_board")

	var individualization_options: Array = main.get("individualization_options")
	var individualization_solution: Array[String] = ["ev_denuncia_filtered_2025", "ev_acquittal_2025", "ev_anpp_2026"]
	for index in range(individualization_solution.size()):
		var option: OptionButton = individualization_options[index] as OptionButton
		_check(option != null and _select_metadata(option, individualization_solution[index]), "Falha ao montar individualização")
	main.call("_validate_individualization")

	_check(GameState.individualization_solved, "Individualização correta não avançou")
	_check(GameState.slice_complete, "Slice 0.3 não terminou após o caminho correto")
	var conclusion_panel: PanelContainer = main.get("conclusion_panel") as PanelContainer
	_check(conclusion_panel != null and conclusion_panel.visible, "Relatório final 0.3 não foi exibido")
	_check(SaveManager.has_save(), "Fluxo completo não deixou save")

	SaveManager.clear_save()
	main.queue_free()
	await get_tree().process_frame
	_finish()

func _finish() -> void:
	if failures.is_empty():
		print("FLOW_OK: caminho 0.3 validado até individualização e relatório final.")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error("FLOW_FAIL: %s" % failure)
	get_tree().quit(1)
