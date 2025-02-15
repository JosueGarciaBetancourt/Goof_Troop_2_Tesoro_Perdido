extends StaticBody2D

@onready var actionAreaStarblock = $ActionAreaStarblock

# Called when the node enters the scene tree for the first time.
func _ready():
	actionAreaStarblock.kicked.connect(kicked)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func kicked():
	DebugHelperController.debugInfoMessageLabel("Starblock pateado")
