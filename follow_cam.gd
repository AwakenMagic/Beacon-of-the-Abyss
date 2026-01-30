extends Camera2D

@export var follow_speed := 240.0
@export var pixel_material: ShaderMaterial

@export var idle_delay: float = 1.0

@export var look_ahead_strength := 0.15
@export var look_ahead_max := 96.0
@export var look_ahead_response := 6.0

@export var snap_fall_speed := 800.0

@export var dz_left : float = 40.0
@export var dz_right : float = 80.0
@export var dz_up : float = 30.0
@export var dz_down : float = 70.0

var actual_cam_pos: Vector2
var look_ahead := Vector2.ZERO
var deadzone_center : Vector2
var idle_time := 0.0
var movement_threshold := 5.0


func _ready() -> void:
	actual_cam_pos = global_position
	make_current()
	deadzone_center = actual_cam_pos
	

func _process(delta: float) -> void:
	$FPS_Label.text = "FPS: %d" % Engine.get_frames_per_second()
	$Engine_FTPS.text = "%d" % Engine.physics_ticks_per_second

func _physics_process(delta: float) -> void:
	if pixel_material == null:
		return

	
	
	var saba := $"../Saba" as CharacterBody2D
	var vel: Vector2 = saba.velocity
	var player_pos: Vector2 = saba.global_position

	# --- Look-ahead (velocity-based) ---
	var desired_look := vel * look_ahead_strength
	desired_look.x = clamp(desired_look.x, -look_ahead_max, look_ahead_max)
	desired_look.y = 0.0  # optional: most platformers disable vertical look-ahead

	look_ahead = look_ahead.lerp(desired_look, min(delta * look_ahead_response, 1.0))
	var target := player_pos + look_ahead
	
	
	#Difference describes the difference in the distance between the Player (target) & the Deadzone_center (location of the camera at previous frame)
	var difference = target - deadzone_center
	
	# --- Normal follow smoothing ---

	# If the target is too far to the RIGHT of the dead zone
	# (X increases to the right in Godot; positive X)
	if difference.x > dz_right:
		deadzone_center.x += (difference.x - dz_right)
		
	# If the target is too far to the LEFT of the dead zone
	# (X decreases to the left in Godot; negative X)
	if difference.x < -dz_left:
		deadzone_center.x += (difference.x + dz_left)
		
	# If the target is too far DOWN the screen
	# (Y increases downward in Godot; positive Y)
	if difference.y > dz_down:
		deadzone_center.y += (difference.y - dz_down)
	
	# If the target is too far UP the screen
# (Y decreases upward in Godot; negative Y)
	if difference.y < -dz_up:
		deadzone_center.y += difference.y + dz_up
	
	
	# --- Snap rule (fast downward fall) ---
	if vel.y > snap_fall_speed:
		actual_cam_pos = player_pos  # or player_pos + look_ahead if you prefer
		deadzone_center = player_pos
		_apply_pixel_snap()
		return
	
	#print(player_pos.x)
	var speed = vel.length()
	
	if speed < movement_threshold and saba.is_on_floor():
		idle_time += delta
		idle_time = clamp(idle_time, 0.0, idle_delay)
		
		if idle_time >= idle_delay:
			deadzone_center = deadzone_center.lerp(player_pos, min(delta * look_ahead_response, 1))
	else:
		idle_time = 0
	
#print("Player Y: ", player_pos.y, " Player X: ", player_pos.x)
	actual_cam_pos = actual_cam_pos.move_toward(deadzone_center, follow_speed * delta)
	_apply_pixel_snap()
	


func _apply_pixel_snap() -> void:
	var snapped_pos := actual_cam_pos.floor()
	var subpixel_offset := snapped_pos - actual_cam_pos
	pixel_material.set_shader_parameter("cam_offset", subpixel_offset)
	global_position = snapped_pos
