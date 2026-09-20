extends Node

var failures: Array[String] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _run() -> void:
	var packed: PackedScene = load("res://scenes/Main.tscn") as PackedScene
	_check(packed != null, "Main.tscn não carregou")
	if packed == null:
		_finish()
		return

	var instance: Node = packed.instantiate()
	add_child(instance)
	get_tree().paused = false
	await get_tree().process_frame
	await get_tree().process_frame

	_check(EvidenceDB.validation_errors.is_empty(), "EvidenceDB: %s" % str(EvidenceDB.validation_errors))
	_check(EvidenceDB.evidence_count() >= 5, "Menos de cinco evidências carregadas")
	for item in EvidenceDB.all_evidence():
		_check(EvidenceDB.has_source(str(item.get("source_id", ""))), "source_id sem ledger: %s" % str(item.get("id", "?")))

	_check(CaseManager.validate_timeline(["ev_pf_2024", "ev_stf_judgment_2025", "ev_anpp_2026"]), "Timeline correta foi recusada")
	_check(not CaseManager.validate_timeline(["ev_stf_judgment_2025", "ev_pf_2024", "ev_anpp_2026"]), "Timeline errada foi aceita")

	var correct_status: Dictionary = {
		"ev_pf_2024": "ALEGAÇÃO_OFICIAL",
		"ev_stf_judgment_2025": "DECISÃO_JUDICIAL",
		"ev_fiction_draft": "FICÇÃO_DRAMÁTICA"
	}
	var wrong_status: Dictionary = correct_status.duplicate()
	wrong_status["ev_pf_2024"] = "DECISÃO_JUDICIAL"
	_check(CaseManager.validate_status(correct_status), "Classificação correta foi recusada")
	_check(not CaseManager.validate_status(wrong_status), "Classificação errada foi aceita")

	GameState.reset_state()
	GameState.discover_evidence("ev_pf_2024")
	GameState.timeline_solved = true
	GameState.reconstruction_step = 2
	_check(SaveManager.save_game(), "Falha ao salvar")
	GameState.reset_state()
	_check(SaveManager.load_game(), "Falha ao carregar")
	_check(GameState.has_evidence("ev_pf_2024"), "Save perdeu evidência")
	_check(GameState.timeline_solved, "Save perdeu flag do puzzle")
	_check(GameState.reconstruction_step == 2, "Save perdeu etapa da reconstrução")
	SaveManager.clear_save()

	instance.queue_free()
	await get_tree().process_frame
	_finish()

func _finish() -> void:
	if failures.is_empty():
		print("SMOKE_OK: Main, EvidenceDB, puzzles e save/load validados.")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error("SMOKE_FAIL: %s" % failure)
	get_tree().quit(1)
