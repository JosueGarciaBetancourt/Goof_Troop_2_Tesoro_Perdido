extends PlayerController

@onready var animationTree = $AnimationTree
@onready var ActionMarker = $ActionableMarker
@onready var actionArea = $ActionableMarker/ActionableArea2D

var nearestActionable: ActionArea
var readyPressFBallon: ActionArea
var handsUp = false
var change_direction = false

const VECTOR_DIRECTIONS = {
	"RIGHT": Vector2(1, 0),
	"LEFT": Vector2(-1, 0),
	"UP": Vector2(0, -1),
	"DOWN": Vector2(0, 1),
	"RIGHT_DOWN": Vector2(1, 1),
	"RIGHT_UP": Vector2(1, -1),
	"LEFT_DOWN": Vector2(-1, 1),
	"LEFT_UP": Vector2(-1, -1),
}

var aux_direction: Vector2
var prev_direction: Vector2 = Vector2.ZERO  # Nueva variable para almacenar la dirección anterior

func _ready():
	animationTree.active =  true
	movement_speed = 400.0 
	move_left = "ui_left2"
	move_right = "ui_right2"
	move_up = "ui_up2"
	move_down = "ui_down2"

func get_movement_input() -> Vector2:
	var input_vector = Vector2.ZERO

	# Manejo de izquierda y derecha
	var left_pressed = Input.is_action_pressed(move_left)
	var right_pressed = Input.is_action_pressed(move_right)
	var up_pressed = Input.is_action_pressed(move_up)
	var down_pressed = Input.is_action_pressed(move_down)

	if left_pressed and not right_pressed:
		input_vector.x = -1
	elif right_pressed and not left_pressed:
		input_vector.x = 1
	elif left_pressed and right_pressed: # Si ambos están presionados, prevalece izquierda (x = -1)
		input_vector.x = -1

	if up_pressed and not down_pressed:
		input_vector.y = -1
	elif down_pressed and not up_pressed:
		input_vector.y = 1
	elif up_pressed and down_pressed: # Si ambos están presionados, prevalece arriba (y = -1)
		input_vector.y = -1

	movement_direction = input_vector

	return input_vector.normalized()  # Normalizamos para evitar movimientos más rápidos en diagonal

func _physics_process(_delta: float) -> void:
	animate_movement()
	handle_movement()
	check_actionables()

func animate_movement():
	# velocity, movement_direction y movement_direction_normalized están declaradas en la clase PlayerController
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

		change_direction = false
	else:
		# Detectar cambio de dirección de horizontal a diagonal/vertical
		if prev_direction.y == 0 and movement_direction.x != 0 and movement_direction.y != 0:
			change_direction = true

		if movement_direction == VECTOR_DIRECTIONS["UP"] or movement_direction == VECTOR_DIRECTIONS["DOWN"] :
			change_direction = false

		# Guardar la dirección actual como anterior para la próxima verificación
		prev_direction = movement_direction

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

		if (change_direction):
			animationTree["parameters/walk/blend_position"] = Vector2(movement_direction.x, 0)
			animationTree["parameters/walk_hands_up/blend_position"] = Vector2(movement_direction.x, 0)

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
