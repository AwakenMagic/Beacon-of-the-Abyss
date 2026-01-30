extends Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$fps_counter.add_theme_font_size_override("font_size", 16)
	#Engine.max_fps = 60
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	position = position.lerp($"../Saba".position, delta * 3)
	
	#$fps_counter.text = "FPS: %d" % Engine.get_frames_per_second()
	
	
