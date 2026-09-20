extends Node

const SAVE_VERSION := 1

var discovered_evidence: Array[String] = []
var timeline_solved := false
var reconstruction_step := 0
var reconstruction_complete := false
var status_solved := false
var origin_solved := false
var slice_complete := false
var hints_used := {"timeline": 0, "status": 0, "origin": 0}

func reset_state() -> void:
	discovered_evidence.clear()
	timeline_solved = false
	reconstruction_step = 0
	reconstruction_complete = false
	status_solved = false
	origin_solved = false
	slice_complete = false
	hints_used = {"timeline": 0, "status": 0, "origin": 0}

func discover_evidence(evidence_id: String) -> bool:
	if evidence_id in discovered_evidence:
		return false
	discovered_evidence.append(evidence_id)
	return true

func has_evidence(evidence_id: String) -> bool:
	return evidence_id in discovered_evidence

func use_hint(puzzle_id: String) -> int:
	var current := int(hints_used.get(puzzle_id, 0))
	current = min(current + 1, 3)
	hints_used[puzzle_id] = current
	return current

func to_save_dict() -> Dictionary:
	return {
		"save_version": SAVE_VERSION,
		"discovered_evidence": discovered_evidence.duplicate(),
		"timeline_solved": timeline_solved,
		"reconstruction_step": reconstruction_step,
		"reconstruction_complete": reconstruction_complete,
		"status_solved": status_solved,
		"origin_solved": origin_solved,
		"slice_complete": slice_complete,
		"hints_used": hints_used.duplicate(true)
	}

func from_save_dict(data: Dictionary) -> bool:
	if int(data.get("save_version", -1)) != SAVE_VERSION:
		return false
	reset_state()
	for item in data.get("discovered_evidence", []):
		discovered_evidence.append(str(item))
	timeline_solved = bool(data.get("timeline_solved", false))
	reconstruction_step = clampi(int(data.get("reconstruction_step", 0)), 0, 3)
	reconstruction_complete = bool(data.get("reconstruction_complete", reconstruction_step >= 3))
	status_solved = bool(data.get("status_solved", false))
	origin_solved = bool(data.get("origin_solved", false))
	slice_complete = bool(data.get("slice_complete", false)) and origin_solved
	var loaded_hints = data.get("hints_used", {})
	if loaded_hints is Dictionary:
		hints_used["timeline"] = clampi(int(loaded_hints.get("timeline", 0)), 0, 3)
		hints_used["status"] = clampi(int(loaded_hints.get("status", 0)), 0, 3)
		hints_used["origin"] = clampi(int(loaded_hints.get("origin", 0)), 0, 3)
	return true
