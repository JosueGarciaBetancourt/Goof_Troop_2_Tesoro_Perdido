extends CharacterBody2D  # Usamos CharacterBody2D en lugar de StaticBody2D

@onready var actionAreaStarblock = $ActionAreaStarblock
@onready var reja: Node2D = get_node("/root/Stage_1/Reja")
@onready var reja_scene = preload("res://Scenes/Objects/Reja.tscn")  

var move_speed_vector: Vector2  
var move_speed: int = 1200
var moving := false 
var characterWhoKicked: Node2D = null
var initial_position: Vector2  # Almacena la posición inicial del Starblock
var actionableStarblock = ActionableObjects.new()

func _ready():
	initial_position = global_position  # Guarda la posición inicial del bloque
	actionAreaStarblock.body_entered.connect(check_enter_holeStarblock)
	actionAreaStarblock.set_deferred("monitoring", false)  # Desactiva detección al inicio
	actionAreaStarblock.kicked.connect(kicked)

func get_collision_shape_rect(obj):
	var shape_owner = obj.find_child("CollisionShapeHoleStarblock2D")  # Asegúrate de que el nombre es correcto
	
	if shape_owner and shape_owner.shape is RectangleShape2D:
		var shape = shape_owner.shape
		var extents = shape.extents  # Tamaño del rectángulo de colisión
		return Rect2(obj.global_position - extents / 2, extents * 2)  # Ajuste para centrar mejor
	return null

func get_tile_collision_rect(obj):
	if obj is TileMap:  # Si el body es un TileMap
		var tilemap = obj as TileMap
		var tile_size = tilemap.tile_set.tile_size  # Obtener tamaño del tile (64x64)
		
		var tile_pos = tilemap.local_to_map(global_position)  # Obtener la celda más cercana
		var tile_global_pos = tilemap.map_to_local(tile_pos)  # Convertir la celda a posición global

		return Rect2(tile_global_pos, tile_size)  # Devolver rectángulo del tile

	return get_collision_shape_rect(obj)  # Si no es TileMap, usar colisión normal

func check_enter_holeStarblock(body):
	if body != null and !moving:
		var starblock_rect = get_collision_shape_rect(self)  # Obtener colisión de Starblock
		var holestarblock_rect = get_tile_collision_rect(body)  # Obtener colisión del tile

		if starblock_rect and holestarblock_rect:
			var intersection = starblock_rect.intersection(holestarblock_rect)  # Intersección
			
			if intersection.size != Vector2.ZERO:  # Si hay intersección
				var starblock_area = starblock_rect.size.x * starblock_rect.size.y
				var intersection_area = intersection.size.x * intersection.size.y
				var overlap_percentage = (intersection_area / starblock_area) * 100.0 * 1.85

				DebugHelperController.debugInfoMessageLabel("Superposición: " + str(overlap_percentage) + "%")
				
				"""
				print("Starblock Rect:", starblock_rect)
				print("HoleStarblock Rect:", holestarblock_rect)
				print("Intersección Rect:", intersection)
				print("Área intersección:", intersection_area, "Área starblock:", starblock_area)
				"""

				if overlap_percentage >= 90.0: 
					if is_instance_valid(reja):
						actionableStarblock.emit_signal("starblockInHole", reja)
					else:
						DebugHelperController.debugInfoMessageLabel("Starblock encajó en el hoyo, reja ya está abierta")

func kicked(characWhoKicked):
	characterWhoKicked = characWhoKicked
	#DebugHelperController.debugInfoMessageLabel("Starblock pateado por: " + characterWhoKicked.name)
	detectDirectionToMove()
	await get_tree().create_timer(0.2).timeout
	moving = true
	actionAreaStarblock.set_deferred("monitoring", false)  # Desactiva detección mientras se mueve

func detectDirectionToMove():
	if not is_instance_valid(characterWhoKicked):
		return
	
	var direction = Vector2.ZERO
	if characterWhoKicked.has_method("get_facing_direction"):
		direction = characterWhoKicked.get_facing_direction()
	
	move_speed_vector = direction * move_speed
	#DebugHelperController.debugInfoMessageLabel("Dirección del Starblock: " + str(direction))

func _physics_process(delta):
	if moving:
		var motion = move_speed_vector * delta
		var collision = move_and_collide(motion)

		if collision:
			moving = false
			actionAreaStarblock.set_deferred("monitoring", true)  # Reactiva detección
			DebugHelperController.debugInfoMessageLabel("Starblock se ha detenido")

func _unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed("ui_auxKey"):  
		reset_position()

func reset_position():
	global_position = initial_position
	moving = false
	move_speed_vector = Vector2.ZERO
	DebugHelperController.debugInfoMessageLabel("Starblock reseteado a su posición inicial")
	