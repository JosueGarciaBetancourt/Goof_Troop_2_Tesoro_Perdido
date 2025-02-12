extends CharacterBody2D
class_name PlayerController

@export var movement_speed: float = 350.0
@export var move_left: String = "ui_left"
@export var move_right: String = "ui_right"
@export var move_up: String = "ui_up"
@export var move_down: String = "ui_down"

var movement_direction: Vector2 = Vector2.ZERO
var movement_direction_normalized: Vector2 = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	pass

# Método virtual para permitir distintos tipos de control en las clases hijas
func get_movement_input() -> Vector2:
	return Vector2.ZERO  # Por defecto, no hace nada

func handle_movement() -> void:
	movement_direction_normalized = get_movement_input()
	velocity = movement_direction_normalized * movement_speed
	move_and_slide()
	