extends Character
signal camera_shake
signal player_moved(player_id, velocity_vector, previous_x, previous_y)
signal player_attacked(player_id)

@export var max_player_hp: int = 50
var is_remote_player = false
var player_id: int
var player_velocity_vector = Vector2.ZERO

func _ready():
	max_hp = max_player_hp
	super()
	if is_remote_player:
		remove_child($Camera)
	else:
		$Body/HitArea.area_entered.connect(_on_hit_area_area_entered)
		

func handle_inputs(delta):
	if can_act():
		player_velocity_vector = Vector2.ZERO
		if Input.is_action_pressed("move_right"):
			player_velocity_vector.x += 1
		if Input.is_action_pressed("move_left"):
			player_velocity_vector.x -= 1
		if Input.is_action_pressed("move_down"):
			player_velocity_vector.y += 1
		if Input.is_action_pressed("move_up"):
			player_velocity_vector.y -= 1
		var previous_x = position.x
		var previous_y = position.y
		move(player_velocity_vector, delta)
		player_moved.emit(player_id, player_velocity_vector, previous_x, previous_y)
			
		if Input.is_action_just_pressed("attack"):
			attack()
			player_attacked.emit(player_id)

func _physics_process(delta):
	if is_remote_player:
		if can_act():
			move(player_velocity_vector, delta)
	else:
		handle_inputs(delta)

func _on_hit_area_area_entered(area):
	if self.scene_file_path != area.get_parent().get_parent().scene_file_path and area.name == "HurtArea":
		camera_shake.emit()

		
func _on_hurt_area_area_entered(area):
	super(area)
	if !is_remote_player and self.name != area.get_parent().get_parent().name and area.name == "HitArea":
		camera_shake.emit()
