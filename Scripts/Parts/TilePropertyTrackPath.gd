class_name TilePropertyTrackPath
extends TilePropertyContainer

func on_pressed() -> void:
	editing_node.editing = true
	editing_node.update_pieces()
	owner.close()
	await owner.closed
	Global.level_editor.current_state = LevelEditor.EditorState.TRACK_EDITING
