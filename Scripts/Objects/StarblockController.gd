extends StaticBody2D

@onready var actionArea = $ActionAreaStarblock

# Called when the node enters the scene tree for the first time.
func _ready():
	print(actionArea.name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
