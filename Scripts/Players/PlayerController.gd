extends CharacterBody2D
class_name PlayerController

@export var movement_speed: float = 350.0
@export var move_left: String = "ui_left"
@export var move_right: String = "ui_right"
@export var move_up: String = "ui_up"
@export var move_down: String = "ui_down"

var handsUp: bool = false
var change_direction_to_vertical: bool = false
var change_direction_to_horizontal: bool = false

var movement_direction: Vector2 = Vector2.ZERO
var movement_direction_normalized: Vector2 = Vector2.ZERO
var prev_direction: Vector2 = Vector2.ZERO
var canMove: bool = true

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

@onready var prevDirectionLabel = $DebugLabels/prev_direction_label
@onready var movementDirectionLabel = $DebugLabels/movement_direction_label
@onready var handsUpLabel = $DebugLabels/handsUp_label
@onready var kickingLabel = $DebugLabels/kicking_label

func _ready():
	print(DebugHelperController)
	DebugHelperController.set_labels(prevDirectionLabel, movementDirectionLabel, handsUpLabel, kickingLabel)

func _physics_process(_delta: float) -> void:
	pass

# Método virtual para permitir distintos tipos de control en las clases hijas
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

	DebugHelperController.debugMovementDirectionLabel(movement_direction)

	return input_vector.normalized()  # Normalizamos para evitar movimientos más rápidos en diagonal

func handle_movement() -> void:
	movement_direction_normalized = get_movement_input()
	velocity = movement_direction_normalized * movement_speed
	move_and_slide()
	
func detect_change_direction():
	# Detectar cambio de dirección de horizontal a diagonal/vertical
	if prev_direction.y == 0 and movement_direction.x != 0 and movement_direction.y != 0:
		change_direction_to_vertical = true
	
	if movement_direction == VECTOR_DIRECTIONS["UP"] or movement_direction == VECTOR_DIRECTIONS["DOWN"] :
		change_direction_to_vertical = false

	# Detectar cambio de dirección de vertical a diagonal/horizontal
	if prev_direction.x == 0 and movement_direction.y != 0 and movement_direction.x != 0:
		change_direction_to_horizontal = true

	if movement_direction == VECTOR_DIRECTIONS["RIGHT"] or movement_direction == VECTOR_DIRECTIONS["LEFT"] :
		change_direction_to_horizontal = false

	
