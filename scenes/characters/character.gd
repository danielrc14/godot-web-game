extends CharacterBody2D
class_name Character

@export_enum("Left:-1", "Right:1") var direction = 1
@export var speed = 300.0
@export var attack_speed = 1.7
@export var left_weapon_class: PackedScene = null
@export var right_weapon_class: PackedScene = null
@export var sprite_frames: SpriteFrames = null
@export var max_hp: int = 0
var hp: int = 0

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

func can_act():
	return not $AnimationPlayer.current_animation in ["slash", "death", "hit"]

func attack():
	$AnimationPlayer.play("slash", -1, attack_speed, false)

func move(velocity_vector, delta):
	if velocity_vector.length() > 0:
		velocity_vector = velocity_vector.normalized() * speed
		$AnimationPlayer.play("run")
	else:
		$AnimationPlayer.play("idle")
		
	set_velocity(velocity_vector)
	move_and_slide()

	if velocity_vector.x != 0:
		$Body.scale.x = abs($Body.scale.x)
		if velocity_vector.x < 0:
			$Body.scale.x *= -1
			
func die():
	$AnimationPlayer.play("death")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "death":
		queue_free()

func _on_hurt_area_area_entered(area):
	if self.name != area.get_parent().get_parent().name and area.name == "HitArea":
		$AnimationPlayer.play("hit")
		hp -= 10
		$HealthBar.set_value_no_signal(hp)
		if hp <= 0:
			die()
