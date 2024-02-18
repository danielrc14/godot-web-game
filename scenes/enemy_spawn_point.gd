extends Node2D

class_name EnemySpawnPoint

@export_enum("Left:-1", "Right:1") var direction = 1
@export var max_enemy_hp: int = 30
@export var left_weapon_class: PackedScene = null
@export var right_weapon_class: PackedScene = null
@export var sprite_frames: SpriteFrames = null
@export var respawn_seconds: int = 5
var enemy_node: Node2D = null


# Called when the node enters the scene tree for the first time.
func create_enemy():
	enemy_node = load("res://scenes/characters/enemy.tscn").instantiate()
	enemy_node.direction = direction
	enemy_node.max_enemy_hp = max_enemy_hp
	enemy_node.left_weapon_class = left_weapon_class
	enemy_node.right_weapon_class = right_weapon_class
	enemy_node.sprite_frames = sprite_frames
	enemy_node.position = position
	enemy_node.connect("died", _on_enemy_died)
	get_parent().get_parent().get_node("Network").add_child(enemy_node)
	
	
func _on_enemy_died():
	await get_tree().create_timer(respawn_seconds).timeout
	create_enemy()
	
	
func _ready():
	create_enemy()
