
extends PlayerController

@onready var animationTree = $AnimationTree
@onready var ActionMarker = $ActionableMarker
@onready var actionArea = $ActionableMarker/ActionableArea2D

var moveDirection = Vector2.ZERO
var nearestActionable: ActionArea
var readyPressFBallon: ActionArea
var handsUp = false

func _ready():
	animationTree.active =  true
	movement_speed = 400.0 
	move_left = "ui_left2"
	move_right = "ui_right2"
	move_up = "ui_up2"
	move_down = "ui_down2"

func get_movement_input() -> Vector2:
	return Input.get_vector(move_left, move_right, move_up, move_down)

func _physics_process(_delta: float) -> void:
	animate_movement()
	handle_movement()
	check_actionables()

func animate_movement():
	# velocity y movement_direction están declaradas en la clase PlayerController
	if Input.is_action_just_pressed("ui_mainInteract"):
		handsUp = !handsUp

	if (velocity.length() == 0):
		if handsUp:
			animationTree["parameters/conditions/stoppingHandsUp"] = true
			animationTree["parameters/conditions/stopping"] = false
		else:
			animationTree["parameters/conditions/stopping"] = true
			animationTree["parameters/conditions/stoppingHandsUp"] = false
		
		animationTree["parameters/conditions/walking"] = false
		animationTree["parameters/conditions/walkingHandsUp"] = false
	else:
		if handsUp:
			animationTree["parameters/conditions/walkingHandsUp"] = true
			animationTree["parameters/conditions/walking"] = false
		else:
			animationTree["parameters/conditions/walking"] = true
			animationTree["parameters/conditions/walkingHandsUp"] = false

		animationTree["parameters/conditions/stopping"] = false
		animationTree["parameters/conditions/stoppingHandsUp"] = false

		animationTree["parameters/stop/blend_position"] = movement_direction
		animationTree["parameters/stop_hands_up/blend_position"] = movement_direction
		animationTree["parameters/walk/blend_position"] = movement_direction
		animationTree["parameters/walk_hands_up/blend_position"] = movement_direction

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_accept") && nearestActionable != null:
		if is_instance_valid(nearestActionable):
			nearestActionable.emit_signal("actionated")
			
func check_actionables() -> void:
	var areas: Array[Area2D] = actionArea.get_overlapping_areas()
	var shortDistance: float = INF
	var nextActionable: ActionArea = null

	for area in areas:
		var distance: float = area.global_position.distance_to(global_position)
		if distance < shortDistance:
			shortDistance = distance
			nextActionable = area

	# Si encontramos un objeto interactuable
	if nextActionable != null:
		if nextActionable != nearestActionable or not is_instance_valid(nearestActionable):
			nearestActionable = nextActionable

		# Asignamos el área más cercana a readyPressFBallon
		readyPressFBallon = nextActionable

		# Emitir la señal mientras el jugador esté cerca
		if readyPressFBallon.has_signal("ready"):
			readyPressFBallon.emit_signal("ready")

	else:
		# Si no hay ningún objeto cerca, ocultamos el ícono
		if readyPressFBallon != null and readyPressFBallon.has_signal("hideballoon"):
			readyPressFBallon.emit_signal("hideballoon")
			
		nearestActionable = null
		readyPressFBallon = null # Evita referencias inválidas