extends Character

@export var max_enemy_hp: int = 30
@export var enemy_speed: int = 100
var followed_player: Node2D = null


func _ready():
	max_hp = max_enemy_hp
	speed = enemy_speed
	super()


func _physics_process(delta):
	if can_act():
		var movement_vector = Vector2.ZERO
		if followed_player:
			if followed_player.position.x > position.x + 5:
				movement_vector.x += 1
			elif followed_player.position.x < position.x - 5:
				movement_vector.x -= 1
			if followed_player.position.y > position.y + 5:
				movement_vector.y += 1
			elif followed_player.position.y < position.y - 5:
				movement_vector.y -= 1
			print("player: " + str(followed_player.position.x) + ", " + str(followed_player.position.y))
			print("enemy: " + str(position.x) + ", " + str(position.y))
			
		move(movement_vector, delta)
		

func _on_detection_area_area_entered(area):
	if not followed_player and area.get_parent().get_parent().name == "Player":
		followed_player = area.get_parent().get_parent()


func _on_detection_area_area_exited(area):
	if area.get_parent().get_parent().name == "Player":
		followed_player = null
