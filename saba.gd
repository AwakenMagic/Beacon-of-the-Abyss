extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $IdleState

const ANIM_IDLE := "Idle_State"

@export var SPEED =  140.0
@export var JUMP_VELOCITY = -350
@export var GRAVITY_MULTIPLIER := 2.5
@export var FALL_MULTIPLIER := 1.5
@export var JUMP_BUFFER_TIME := 0.08
@export var COYOTE_TIME := 0.05
@export var DOUBLE_TAP_WINDOW : float = 0.25

@export var DASH_DURATION : float = 0.12
@export var DASH_SPEED: float = 400.0


var jump_buffer_timer := 0.0
var coyote_timer := 0.0
var GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var face_direction: Vector2
var last_tap_dir: Vector2 = Vector2.ZERO
var tap_count: int = 0
#var tap_timer: float = 0.0

var between_dashes_cooldown_timer: float = 0.0
var between_dashes_cooldown_window: float = 0.25
var between_dashes_cooldown: bool = false

var dash_reset_timer: float = 0.0
var dash_reset_window: float = 3.0

var dash_cooldown_window: float = 2.0
var dash_count: int = 0
var dash_cooldown_message: String

var is_dashing: bool = false
var dash_timer: float = 0.0

var dash_direction: Vector2 = Vector2.ZERO
func _physics_process(delta):
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta
	
	if is_on_floor():
		coyote_timer = COYOTE_TIME
		# Usually you do NOT need to force this; move_and_slide handles it.
		# velocity.y = 0a
	else:
		coyote_timer -= delta

		var mult := 1.0

		# Rising but jump released early -> stronger gravity (jump cut)
		if velocity.y < 0.0 and not Input.is_action_pressed("jump"):
			mult = GRAVITY_MULTIPLIER
		# Falling -> stronger gravity (snappier fall)
		elif velocity.y > 0.0:
			mult = FALL_MULTIPLIER

		velocity.y += GRAVITY * mult * delta

	var dash_dir := activate_dash(delta)
	var direction := Input.get_axis("left", "right")
	
	if dash_dir != Vector2.ZERO:
		dash_direction = dash_dir

		
		
	
	
	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * DASH_SPEED
		if dash_timer <= 0.0:
			is_dashing = false
	else:
		velocity.x = direction * SPEED
	

	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = max(jump_buffer_timer,0)
		coyote_timer = max(coyote_timer, 0)
	
	
	flip_animation_h(direction)
	update_animation()
	
	
	#if dash_dir != Vector2.ZERO:
	#	print("Dashed!")
	#	velocity = velocity + (dash_dir * 400)
	#	print(dash_cooldown_message, ", Cooldown time : ", between_dashes_cooldown_timer, ", Dashes: ", dash_count,)
	
	move_and_slide()
	
	#var dash_dir := poll_double_tap(delta)
	#if dash_dir != Vector2.ZERO:
	#	print(dash_dir)
	#	velocity += dash_dir * 400
	
	
	
func update_animation() -> void:
	#var next_anim := ANIM_IDLE
	
	if abs(velocity.x) <= 5.0:
		pass
		
		if anim.animation != ANIM_IDLE or not anim.is_playing():
			anim.play(ANIM_IDLE)
	else:
		anim.stop()
		
func flip_animation_h(direction) -> void:
	
	if direction == -1:
		anim.flip_h = true
	if direction == 1:
		anim.flip_h = false
	
func get_tap_direction() -> Vector2:
	
	if Input.is_action_pressed("up"):
		return Vector2.UP
	elif Input.is_action_pressed("down"):
		return Vector2.DOWN
	elif Input.is_action_pressed("left"):
		return Vector2.LEFT
	elif Input.is_action_pressed("right"):
		return Vector2.RIGHT
	return Vector2.ZERO

func activate_dash(delta: float) -> Vector2:

	if is_dashing:
		return Vector2.ZERO
	
	var dash_dir = get_tap_direction()
	var dash_pressed: bool = Input.is_action_just_pressed("dash")
	
	#is cooldown between dashes active
	if between_dashes_cooldown_timer > 0.0:
		between_dashes_cooldown_timer = max(0.0, between_dashes_cooldown_timer - delta)
	if dash_reset_timer > 0.0:
		dash_reset_timer = max(0.0, dash_reset_timer - delta)
	else:
		dash_count = 0
		
	if dash_dir == Vector2.ZERO:
		return Vector2.ZERO
	if not dash_pressed:
		return Vector2.ZERO
	if between_dashes_cooldown_timer > 0.0:
		return Vector2.ZERO

		#Limit consequtive dashes
	if dash_count >= 3:
		between_dashes_cooldown_timer = dash_cooldown_window
		dash_cooldown_message = "3 consecutive dashes cooldown active"
		dash_count = 0
		return Vector2.ZERO
		
	is_dashing = true
	dash_timer = DASH_DURATION
	dash_count += 1
	between_dashes_cooldown_timer = between_dashes_cooldown_window
	dash_reset_timer = dash_reset_window
	dash_cooldown_message = "between dashes cooldown active, "
	return dash_dir
		
	

func poll_double_tap(delta: float) -> Vector2:
	
	#Countdown the window		
#	if tap_timer > 0.0:
#		tap_timer -= delta
#	else:
#		tap_count = 0
#		last_tap_dir = Vector2.ZERO
	
	
	var tap_dir = get_tap_direction()
	if tap_dir == Vector2.ZERO:
		return Vector2.ZERO
	
	#New tap happened
#	if tap_dir == last_tap_dir and tap_timer > 0.0:
#		tap_count += 1
#	else:
#		tap_count = 1
#		last_tap_dir = tap_dir
	
	#Refresh the timer window
#	tap_timer = DOUBLE_TAP_WINDOW
	
#	if tap_count >= 2:
#		tap_timer = 0
#		last_tap_dir = Vector2.ZERO
#		return tap_dir
#		tap_count = 0
		
	return Vector2.ZERO
