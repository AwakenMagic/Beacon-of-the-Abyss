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


var jump_buffer_timer := 0.0
var coyote_timer := 0.0
var GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var face_direction: Vector2
var last_tap_dir: Vector2 = Vector2.ZERO
var tap_count: int = 0
var tap_timer: float = 0.0

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

	
	var direction := Input.get_axis("left", "right")
	velocity.x = direction * SPEED

	
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = max(jump_buffer_timer,0)
		coyote_timer = max(coyote_timer, 0)
	
	
	
	flip_animation_h(direction)
	update_animation()
	move_and_slide()
	
	var dash_dir := poll_double_tap(delta)
	if dash_dir != Vector2.ZERO:
		print(dash_dir)
		velocity += dash_dir * 400
	
	
	
	
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
	
	if Input.is_action_just_pressed("up"):
		return Vector2.UP
	elif Input.is_action_just_pressed("down"):
		return Vector2.DOWN
	elif Input.is_action_just_pressed("left"):
		return Vector2.LEFT
	elif Input.is_action_just_pressed("right"):
		return Vector2.RIGHT
	return Vector2.ZERO


func poll_double_tap(delta: float) -> Vector2:
	
	#Countdown the window
	if tap_timer > 0.0:
		tap_timer -= delta
	else:
		tap_count = 0
		last_tap_dir = Vector2.ZERO
	
	
	var tap_dir = get_tap_direction()
	if tap_dir == Vector2.ZERO:
		return Vector2.ZERO
	
	#New tap happened
	if tap_dir == last_tap_dir and tap_timer > 0.0:
		tap_count += 1
	else:
		tap_count = 1
		last_tap_dir = tap_dir
	
	#Refresh the timer window
	tap_timer = DOUBLE_TAP_WINDOW
	
	if tap_count >= 2:
		tap_count = 0
		tap_timer = 0
		last_tap_dir = Vector2.ZERO
		return tap_dir
		
	return Vector2.ZERO
