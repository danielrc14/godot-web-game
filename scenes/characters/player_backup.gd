extends CharacterBody2D

@export var speed = 300.0
@export var attack_speed = 1.7
@export var left_weapon_class: PackedScene = null
@export var right_weapon_class: PackedScene = null

func _ready():
	if left_weapon_class:
		var left_weapon = left_weapon_class.instantiate()
		$Body/LeftHand.add_child(left_weapon)
	if right_weapon_class:
		var right_weapon = right_weapon_class.instantiate()
		$Body/RightHand.add_child(right_weapon)

func can_act():
	return not $AnimationPlayer.current_animation == "slash"

func handle_inputs(delta):
	if can_act():	
		var velocity_vector = Vector2.ZERO # The player's movement vector.
		if Input.is_action_pressed("move_right"):
			velocity_vector.x += 1
		if Input.is_action_pressed("move_left"):
			velocity_vector.x -= 1
		if Input.is_action_pressed("move_down"):
			velocity_vector.y += 1
		if Input.is_action_pressed("move_up"):
			velocity_vector.y -= 1
		move(velocity_vector, delta)
			
		if Input.is_action_just_pressed("attack"):
			attack()

func attack():
	$AnimationPlayer.play("slash", -1, attack_speed, false)

func move(velocity_vector, delta):
	if velocity_vector.length() > 0:
		velocity_vector = velocity_vector.normalized() * speed
		$AnimationPlayer.play("run")
	else:
		$AnimationPlayer.play("idle")
		
	position += velocity_vector * delta

	if velocity_vector.x != 0:
		$Body.scale.x = abs($Body.scale.x)
		if velocity_vector.x < 0:
			$Body.scale.x *= -1

func _process(delta):
	handle_inputs(delta)
