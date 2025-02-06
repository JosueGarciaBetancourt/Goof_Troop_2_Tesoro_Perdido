extends CharacterBody2D

@onready var ActionMarker = $ActionableMarker
@onready var actionArea = $ActionableMarker/ActionableArea2D

var nearestActionable: ActionArea
var readyPressFBallon: ActionArea

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta):

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	check_actionables()

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
		readyPressFBallon = null  # Evita referencias inválidas
