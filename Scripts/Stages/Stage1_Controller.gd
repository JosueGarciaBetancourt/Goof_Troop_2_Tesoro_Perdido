extends Node2D

@onready var reja = $Reja
@onready var starblock_container = $StarblockController  # Contenedor de los Starblocks

func _ready():
	for starblock in starblock_container.get_children():  # Obtener todas las instancias
		var starblockActionInstance = starblock.actionableStarblock
		if (starblockActionInstance):
			starblockActionInstance.starblockInHole.connect(self.on_starblock_in_hole)  # Conectar cada uno

func on_starblock_in_hole(doorToOpen):
	if doorToOpen:
			doorToOpen.disminuirStarblocksRequeridos()