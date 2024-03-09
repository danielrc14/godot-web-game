extends CharacterBody2D
class_name Character

@export_enum("Left:-1", "Right:1") var direction = 1
@export var speed = 150.0
@export var attack_speed = 1.7
@export var left_weapon_class: PackedScene = null
@export var right_weapon_class: PackedScene = null
@export var sprite_frames: SpriteFrames = null
@export var max_hp: int = 0
enum {IDLE, RUN, ATTACK, HIT, DEATH}
@export var state: int = IDLE;
@export var hp: int = 0
var dead = false

func _ready():
	$Body.scale.x *= direction
	if left_weapon_class:
		var left_weapon = left_weapon_class.instantiate()
		$Body/LeftHand.add_child(left_weapon)
	else:
		$Body/LeftHand.frame -= 1
	if right_weapon_class:
		var right_weapon = right_weapon_class.instantiate()
		$Body/RightHand.add_child(right_weapon)
	else:
		$Body/RightHand.frame -= 1
	if sprite_frames:
		$Body.sprite_frames = sprite_frames
	hp = max_hp
	$HealthBar.min_value = 0
	$HealthBar.max_value = max_hp
	$HealthBar.set_value_no_signal(hp)
	
func animate_state():
	match state:
		IDLE:
			$AnimationPlayer.play("idle")
		RUN: 
			$AnimationPlayer.play("run")
		ATTACK:
			$AnimationPlayer.play("attack", -1, attack_speed, false)
		HIT:
			if not $AnimationPlayer.current_animation in ["hit", "RESET"]:
				$AnimationPlayer.play("RESET")
				$AnimationPlayer.queue("hit")
		DEATH:
			$AnimationPlayer.play("death")
			
func _physics_process(delta):
	$Label.set_text(str(state))
	animate_state()

func can_act():
	return not dead and not state in [ATTACK, DEATH, HIT]

func attack():
	state = ATTACK

func move(velocity_vector, delta):
	if velocity_vector.length() > 0:
		velocity_vector = velocity_vector.normalized() * speed
		state = RUN
	else:
		state = IDLE
		
	set_velocity(velocity_vector)
	move_and_slide()

	if velocity_vector.x != 0:
		$Body.scale.x = abs($Body.scale.x)
		if velocity_vector.x < 0:
			$Body.scale.x *= -1
			
func die():
	state = DEATH
	dead = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name in ["attack", "hit", "RESET"]:
		state = IDLE

func _on_hurt_area_area_entered(area):
	if self.scene_file_path != area.get_parent().get_parent().scene_file_path and area.name == "HitArea" and hp > 0:
		state = HIT
		hp -= 10
		$HealthBar.set_value_no_signal(hp)
		if hp <= 0:
			die()
