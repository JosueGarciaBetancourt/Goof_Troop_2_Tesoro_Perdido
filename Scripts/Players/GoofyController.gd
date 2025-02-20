extends PlayerController

@onready var animationTree = $AnimationTree
@onready var ActionMarker = $ActionableMarker
@onready var actionArea = $ActionableMarker/ActionableArea2D
@onready var area2DDetectObject = $Area2DDetectObject
@onready var collisionShape2DDetectObject = $Area2DDetectObject/CollisionShape2DDetectObject 

var nearestActionable: ActionArea
var readyPressFBallon: ActionArea
var nearest_object: ActionAreaObjects

func _ready():
	animationTree.active =  true
	movement_speed = 400.0 
	move_left = "ui_left2"
	move_right = "ui_right2"
	move_up = "ui_up2"
	move_down = "ui_down2"

func _physics_process(_delta: float) -> void:
	animate_movement()
	if canMove: 
		handle_movement()
	check_actionables()
	debugLabels()

func animate_movement():
	if Input.is_action_just_pressed("ui_mainInteract"):
		handsUp = !handsUp

	if (movement_direction == Vector2.ZERO and velocity.length() == 0):
		change_direction_to_vertical = false
		change_direction_to_horizontal = false

		animationTree["parameters/conditions/walking"] = false
		animationTree["parameters/conditions/walkingHandsUp"] = false
		animationTree["parameters/conditions/stopping"] = !handsUp
		animationTree["parameters/conditions/stoppingHandsUp"] = handsUp
	else:
		detect_change_direction()

		# Guardar la dirección actual como anterior para la próxima verificación
		prev_direction = movement_direction
		

		animationTree["parameters/conditions/stopping"] = false
		animationTree["parameters/conditions/stoppingHandsUp"] = false
		animationTree["parameters/conditions/walking"] = !handsUp
		animationTree["parameters/conditions/walkingHandsUp"] = handsUp
		
		# Designar direcciones
		animationTree["parameters/stop/blend_position"] = movement_direction
		animationTree["parameters/stop_hands_up/blend_position"] = movement_direction
		
		if (change_direction_to_vertical):
			animationTree["parameters/walk/blend_position"] = Vector2(movement_direction.x, 0)
			animationTree["parameters/walk_hands_up/blend_position"] = Vector2(movement_direction.x, 0)
			collisionShape2DDetectObject.rotation = Vector2(movement_direction.x, 0).angle()
		elif (change_direction_to_horizontal):
			collisionShape2DDetectObject.rotation = Vector2(0, movement_direction.y).angle()
		else: 
			animationTree["parameters/walk/blend_position"] = movement_direction
			animationTree["parameters/walk_hands_up/blend_position"] = movement_direction
			collisionShape2DDetectObject.rotation = prev_direction.angle()

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_kicking") && nearestActionable != null:
		if is_instance_valid(nearestActionable):
			nearestActionable.emit_signal("actionated")

	if event.is_action_pressed("ui_kicking") and !animationTree["parameters/conditions/stoppingHandsUp"] \
											 and !animationTree["parameters/conditions/walkingHandsUp"]:

		var nearestObj = check_nearest_object()
		
		if nearestObj:
			# Emitir la señal mientras el jugador esté cerca
			nearestObj.emit_signal("kicked", self)

			if (change_direction_to_vertical):
				animationTree["parameters/kicking/blend_position"] = Vector2(movement_direction.x, 0)
			elif (change_direction_to_horizontal):
				animationTree["parameters/kicking/blend_position"] = Vector2(0, movement_direction.y)
			else: 
				animationTree["parameters/kicking/blend_position"] = Vector2(prev_direction)

			animationTree["parameters/conditions/kicking"] = true

			canMove = false
			kicking = true

			await get_tree().create_timer(0.3).timeout

			animationTree["parameters/conditions/kicking"] = false
			canMove = true
			kicking = false

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

func check_nearest_object():
	var areas: Array[Area2D] = area2DDetectObject.get_overlapping_areas()

	if (areas == [] or areas == null):
		DebugHelperController.debugInfoMessageLabel("No hay áreas cercanas")
		return null

	var shortDistance: float = INF
	nearest_object = null  # Guardará el objeto más cercano

	for area in areas:
		var distance: float = area.global_position.distance_to(global_position)
		if distance < shortDistance:
			shortDistance = distance
			nearest_object = area  # Guarda el objeto más cercano

	if nearest_object:
		DebugHelperController.debugInfoMessageLabel("Objeto más cercano: " + nearest_object.name)
		return nearest_object  # Devuelve el objeto más cercano
	else:
		DebugHelperController.debugInfoMessageLabel("No hay objetos cercanos")

	return null  # Si no hay objetos, devuelve null
