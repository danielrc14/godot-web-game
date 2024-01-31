extends Camera2D

@export var randomStrength: float = 15.0
@export var shakeFade: float = 10.0

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakeFade*delta)
		offset = randomOffset()
	
func apply_shake():
	shake_strength = randomStrength
	
func randomOffset() -> Vector2:
	return Vector2(
		rng.randf_range(-shake_strength, shake_strength),
		rng.randf_range(-shake_strength, shake_strength)
	)

func _on_player_camera_shake():
	apply_shake()
