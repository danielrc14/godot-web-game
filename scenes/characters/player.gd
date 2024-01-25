extends Character
signal camera_shake

@export var max_player_hp: int = 50

func _ready():
	super()
	max_hp = max_player_hp

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

func _physics_process(delta):
	handle_inputs(delta)

func _on_hit_area_area_entered(area):
	if self.name != area.get_parent().get_parent().name and area.name == "HurtArea":
		camera_shake.emit()
		
func _on_hurt_area_area_entered(area):
	super(area)
	if self.name != area.get_parent().get_parent().name and area.name == "HitArea":
		camera_shake.emit()
