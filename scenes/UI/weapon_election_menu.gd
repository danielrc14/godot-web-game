extends Control

const weapon_names = [
	"wooden_sword",
	"wooden_axe",
	"wooden_dagger"
]


# Called when the node enters the scene tree for the first time.
func _ready():
	$ContinueButton.connect("pressed", _on_continue_button_pressed)

	
func _on_continue_button_pressed():
	var selections = $ItemListContainer/ItemList.get_selected_items()
	if selections.size() > 0:
		Autoload.player_weapon_name = weapon_names[selections[0]]
		get_tree().change_scene_to_file("res://scenes/client.tscn")
