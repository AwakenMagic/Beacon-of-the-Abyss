extends SubViewport


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	render_target_update_mode = SubViewport.UPDATE_DISABLED
	await get_tree().process_frame
	render_target_update_mode = SubViewport.UPDATE_ALWAYS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
