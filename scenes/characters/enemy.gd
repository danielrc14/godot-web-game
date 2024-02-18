extends Character
signal died

@export var max_enemy_hp: int = 30
@export var enemy_speed: int = 80
@export var enemy_attack_speed: float = 1.4
@export var distance_to_attack: float = 50
@export var attack_cooldown: float = 1.5
var followed_players = []
var attack_on_cooldown: bool = false


func _ready():
	max_hp = max_enemy_hp
	speed = enemy_speed
	attack_speed = enemy_attack_speed
	super()


func _physics_process(delta):
	if can_act():
		var movement_vector = Vector2.ZERO
		var will_attack = false
		var followed_player = null
		if followed_players.size() > 0:
			followed_player = followed_players[0]
		if followed_players and not followed_player.dead:
			var position_vector = Vector2()
			var distance_to_player = Vector2(position.x, position.y).distance_to(Vector2(
				followed_player.position.x,
				followed_player.position.y
			))
			if distance_to_player > distance_to_attack:
				if followed_player.position.x > position.x + 5:
					movement_vector.x += 1
				elif followed_player.position.x < position.x - 5:
					movement_vector.x -= 1
				if followed_player.position.y > position.y + 5:
					movement_vector.y += 1
				elif followed_player.position.y < position.y - 5:
					movement_vector.y -= 1
			else:
				will_attack = true
		
		move(movement_vector, delta)
		if will_attack:
			enemy_attack()
			

func enemy_attack():
	if not attack_on_cooldown:
		attack()
		attack_on_cooldown = true
		await get_tree().create_timer(attack_cooldown).timeout
		attack_on_cooldown = false


func _on_detection_area_area_entered(area):
	if area.name == "HurtArea" and area.get_parent().get_parent() is Player:
		followed_players.append(area.get_parent().get_parent()) 


func _on_detection_area_area_exited(area):
	if area.name == "HurtArea" and area.get_parent().get_parent() in followed_players:
		followed_players.erase(area.get_parent().get_parent())
		
		
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "death":
		died.emit()
		queue_free()
