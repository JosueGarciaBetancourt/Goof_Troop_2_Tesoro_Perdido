extends CharacterBody2D  # Usamos CharacterBody2D en lugar de StaticBody2D

@onready var actionAreaStarblock = $ActionAreaStarblock
var move_speed_vector: Vector2  
@export var move_speed: int = 1200
var moving := false 
var characterWhoKicked: Node2D = null

func _ready():
	actionAreaStarblock.kicked.connect(kicked)

func kicked(characWhoKicked):
	characterWhoKicked = characWhoKicked
	DebugHelperController.debugInfoMessageLabel("Starblock pateado por: " + characterWhoKicked.name)
	detectDirectionToMove()
	await get_tree().create_timer(0.2).timeout
	moving = true  # Activa el movimiento

func detectDirectionToMove():
	if not is_instance_valid(characterWhoKicked):
		return
	
	# Obtener la dirección normalizada del jugador
	var direction = characterWhoKicked.velocity.normalized()

	# Si el jugador no se movía al patear, usa la dirección previa
	if direction == Vector2.ZERO and characterWhoKicked.has_method("get_facing_direction"):
		direction = characterWhoKicked.get_facing_direction()
	
	# Aplicar la dirección al movimiento del bloque
	move_speed_vector = direction * move_speed  # Ahora move_speed es un Vector2 con dirección y magnitud
	
	DebugHelperController.debugInfoMessageLabel("Dirección del Starblock: " + str(direction))

func _physics_process(delta):
	if moving:
		var motion = move_speed_vector * delta  # Usa la dirección correcta
		var collision = move_and_collide(motion)  # Detecta colisión

		if collision:
			moving = false  # Detiene el movimiento al colisionar
			DebugHelperController.debugInfoMessageLabel("Starblock colisionó con: " + str(collision.get_collider().name))

	if Input.is_action_pressed("ui_auxKey"):  
		global_position = Vector2(908, 776)
		moving = false
