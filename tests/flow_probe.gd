extends Node

var failures: Array[String] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _collect(main: Node, evidence_ids: Array[String]) -> void:
	for evidence_id in evidence_ids:
		main.call("_on_evidence_activated", evidence_id)
		_check(GameState.has_evidence(evidence_id), "Evidência não registrada: %s" % evidence_id)
		main.call("_close_evidence")

func _place_sequence(main: Node, entries: Array[String]) -> void:
	for i in range(entries.size()):
		main.call("_select_board_evidence", entries[i])
		main.call("_place_selected_in_slot", i)

func _stamp(main: Node, evidence_id: String, status_code: String) -> void:
	main.call("_select_status_evidence", evidence_id)
	main.call("_apply_status_stamp", status_code)

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
	_check(str(main.get("board_stage")) == "timeline", "Pergunta ativa inicial deveria ser a sequência")

	var investigator: CharacterBody2D = main.get_node("Investigator") as CharacterBody2D
	var phase_gate: Node = main.get_node("PhaseGate")
	var individualization_gate: Node = main.get_node("IndividualizationGate")
	var contradictory_gate: Node = main.get_node("ContradictoryGate")

	investigator.position.x = 2760.0
	await get_tree().physics_frame
	await get_tree().process_frame
	_check(investigator.position.x <= 2050.1, "Setor B acessível antes da classificação")
	_check(not bool(phase_gate.call("is_unlocked")), "Porta do Setor B começou liberada")

	_collect(main, [
		"ev_pf_2024",
		"ev_copa_label",
		"ev_stf_vote_2025",
		"ev_stf_judgment_2025",
		"ev_anpp_2026",
		"ev_fiction_draft"
	])
	_check(GameState.discovered_evidence.size() == 6, "Triagem deveria ter seis evidências")

	main.call("_open_board")
	_check(str(main.get("board_stage")) == "timeline", "Primeira hipótese não é a sequência")
	_place_sequence(main, ["ev_pf_2024", "ev_stf_judgment_2025", "ev_anpp_2026"])
	main.call("_validate_active_board")
	_check(GameState.timeline_solved, "Sequência correta não avançou o fluxo")
	_check(not bool(main.get("board_panel").visible), "Quadro não fechou após sequência correta")

	for step_index in range(3):
		main.call("_on_reconstruction_activated", step_index)
	_check(GameState.reconstruction_complete, "Reconstrução completa não foi marcada")

	main.call("_open_board")
	_check(str(main.get("board_stage")) == "status", "Quadro não avançou para carimbos de autoridade")
	_stamp(main, "ev_pf_2024", "ALEGAÇÃO_OFICIAL")
	_stamp(main, "ev_stf_judgment_2025", "DECISÃO_JUDICIAL")
	_stamp(main, "ev_fiction_draft", "FICÇÃO_DRAMÁTICA")
	main.call("_validate_active_board")

	_check(GameState.status_solved, "Classificação correta não liberou o Setor B")
	_check(not GameState.slice_complete, "Slice terminou antes do rastro documental")
	_check(bool(phase_gate.call("is_unlocked")), "Portal do Setor B não foi liberado")
	var phase_banner: PanelContainer = main.get("phase_banner") as PanelContainer
	_check(phase_banner != null and phase_banner.visible, "Transição do Setor B não foi exibida")

	investigator.position.x = 2760.0
	await get_tree().physics_frame
	await get_tree().process_frame
	_check(investigator.position.x > 2050.0, "Limite físico do Setor B não abriu")

	_collect(main, ["ev_pet13236_2024", "ev_denuncia_received_2025", "ev_pgr_argument_2025"])
	_check(GameState.discovered_evidence.size() == 9, "Setor B deveria encerrar com nove evidências")

	main.call("_open_board")
	_check(str(main.get("board_stage")) == "origin", "Quadro não focou o rastro documental")
	_place_sequence(main, ["ev_pet13236_2024", "ev_denuncia_received_2025", "ev_stf_judgment_2025"])
	main.call("_validate_active_board")

	_check(GameState.origin_solved, "Rastro documental correto não avançou")
	_check(not GameState.slice_complete, "Slice terminou antes da individualização")
	_check(bool(individualization_gate.call("is_unlocked")), "Portal do Setor C não foi liberado")

	investigator.position.x = 3600.0
	await get_tree().physics_frame
	await get_tree().process_frame
	_check(investigator.position.x > 2900.0, "Limite físico do Setor C não abriu")

	_collect(main, ["ev_denuncia_filtered_2025", "ev_acquittal_2025", "ev_group_method_note"])
	_check(GameState.discovered_evidence.size() == 12, "Setor C deveria encerrar com doze evidências")

	main.call("_open_board")
	_check(str(main.get("board_stage")) == "individualization", "Quadro não focou individualização")
	_place_sequence(main, ["ev_denuncia_filtered_2025", "ev_acquittal_2025", "ev_anpp_2026"])
	main.call("_validate_active_board")

	_check(GameState.individualization_solved, "Individualização correta não avançou")
	_check(not GameState.slice_complete, "Slice terminou antes do contraditório")
	_check(bool(contradictory_gate.call("is_unlocked")), "Portal do Setor D não foi liberado")

	investigator.position.x = 4680.0
	await get_tree().physics_frame
	await get_tree().process_frame
	_check(investigator.position.x > 3790.0, "Limite físico do Setor D não abriu")

	_collect(main, ["ev_defense_bernardo_2025", "ev_outcome_bernardo_2025", "ev_defense_marcio_2025", "ev_outcome_marcio_2025"])
	_check(GameState.discovered_evidence.size() == EvidenceDB.evidence_count(), "Fluxo não coletou todas as evidências")

	main.call("_open_board")
	_check(str(main.get("board_stage")) == "contradictory", "Quadro não focou contraditório")
	_place_sequence(main, ["ev_defense_bernardo_2025", "ev_outcome_bernardo_2025", "ev_defense_marcio_2025", "ev_outcome_marcio_2025"])
	main.call("_validate_active_board")

	_check(GameState.contradictory_solved, "Contraditório correto não avançou")
	_check(GameState.slice_complete, "Slice não terminou após o caminho correto")
	var conclusion_panel: PanelContainer = main.get("conclusion_panel") as PanelContainer
	_check(conclusion_panel != null and conclusion_panel.visible, "Relatório final não foi exibido")
	_check(SaveManager.has_save(), "Fluxo completo não deixou save")

	SaveManager.clear_save()
	main.queue_free()
	await get_tree().process_frame
	_finish()

func _finish() -> void:
	if failures.is_empty():
		print("FLOW_OK: investigação 0.5 validada por cartões, carimbos, reconstrução e contraditório.")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error("FLOW_FAIL: %s" % failure)
	get_tree().quit(1)
