extends Character

@export var max_enemy_hp: int = 30

func _ready():
	max_hp = max_enemy_hp
	super()

func _physics_process(delta):
	if can_act():
		move(Vector2.ZERO, delta)
