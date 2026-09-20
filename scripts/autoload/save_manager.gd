extends Node

const SAVE_PATH := "user://linha_de_sombra_save_v1.json"

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game() -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Não foi possível abrir o save para escrita.")
		return false
	file.store_string(JSON.stringify(GameState.to_save_dict(), "\t"))
	return true

func load_game() -> bool:
	if not has_save():
		return false
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if parsed == null or not parsed is Dictionary:
		return false
	return GameState.from_save_dict(parsed)

func clear_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
