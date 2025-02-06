#region Movimiento general del player
extends PlayerController

func _ready():
	movement_speed = 400.0  # Modificamos la velocidad
	move_left = "ui_left2"  # Modificando las direcciones de movimiento
	move_right = "ui_right2"
	move_up = "ui_up2"
	move_down = "ui_down2"
	
func _physics_process(_delta: float) -> void:
	handle_movement()
	check_actionables()

func get_movement_input() -> Vector2:
	return Input.get_vector(move_left, move_right, move_up, move_down)
#endregion

@onready var ActionMarker = $ActionableMarker
@onready var actionArea = $ActionableMarker/ActionableArea2D

var nearestActionable: ActionArea
var readyPressFBallon: ActionArea

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
