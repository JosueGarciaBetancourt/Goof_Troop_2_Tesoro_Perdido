extends StaticBody2D
class_name StarblockController

var player_is_down: bool = false

func _ready():
	pass # Replace with function body.

func _process(_delta):
	detect_player_down()

func detect_player_down():
	player_is_down = true