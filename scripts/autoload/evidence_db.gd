extends Node

const EVIDENCE_PATH := "res://data/evidence.json"
const SOURCES_PATH := "res://data/sources.json"

var _evidence: Dictionary = {}
var _sources: Dictionary = {}
var validation_errors: Array[String] = []

func _ready() -> void:
	reload()

func reload() -> void:
	_evidence.clear()
	_sources.clear()
	validation_errors.clear()
	_load_sources()
	_load_evidence()
	_validate_links()

func _read_json_array(path: String) -> Array:
	if not FileAccess.file_exists(path):
		validation_errors.append("Arquivo ausente: %s" % path)
		return []
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed == null or not parsed is Array:
		validation_errors.append("JSON inválido ou não-array: %s" % path)
		return []
	return parsed

func _load_sources() -> void:
	for item in _read_json_array(SOURCES_PATH):
		if not item is Dictionary:
			continue
		var source_id := str(item.get("id", ""))
		if source_id.is_empty():
			validation_errors.append("Fonte sem id")
		elif _sources.has(source_id):
			validation_errors.append("Fonte duplicada: %s" % source_id)
		else:
			_sources[source_id] = item

func _load_evidence() -> void:
	for item in _read_json_array(EVIDENCE_PATH):
		if not item is Dictionary:
			continue
		var evidence_id := str(item.get("id", ""))
		if evidence_id.is_empty():
			validation_errors.append("Evidência sem id")
		elif _evidence.has(evidence_id):
			validation_errors.append("Evidência duplicada: %s" % evidence_id)
		else:
			_evidence[evidence_id] = item

func _validate_links() -> void:
	for item in _evidence.values():
		var source_id := str(item.get("source_id", ""))
		if source_id.is_empty() or not _sources.has(source_id):
			validation_errors.append("source_id ausente no ledger: %s" % source_id)
		if str(item.get("factual_status", "")).is_empty():
			validation_errors.append("Evidência sem factual_status: %s" % str(item.get("id", "?")))

func get_evidence(evidence_id: String) -> Dictionary:
	return _evidence.get(evidence_id, {})

func get_source(source_id: String) -> Dictionary:
	return _sources.get(source_id, {})

func has_source(source_id: String) -> bool:
	return _sources.has(source_id)

func all_evidence() -> Array:
	return _evidence.values()

func evidence_count() -> int:
	return _evidence.size()
