extends StaticBody2D

@export var abierta: bool = false  # Propiedad editable en el Inspector
@export var starblocksRequeridos: int = 3

func _ready():
	pass

func disminuirStarblocksRequeridos():
	if not abierta:  # Solo abrir si está cerrada
		self.starblocksRequeridos -= 1
		
		if (self.starblocksRequeridos == 0):
			abrir()

func abrir():
	if not abierta:  # Solo abrir si está cerrada
		abierta = true
		DebugHelperController.debugInfoMessageLabel("Todos los Starblocks requeridos están en los hoyos, abriendo " + self.name)
		await get_tree().create_timer(0.3).timeout
		queue_free() 	

