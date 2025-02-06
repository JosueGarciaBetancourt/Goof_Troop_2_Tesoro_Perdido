extends Node2D

@export var objects: Array[PackedScene]
@onready var area = $ActionArea
@onready var press_f_ballon = $PressFBallon  # Referencia al Sprite2D

var resource = load("res://Dialogos/dialogue.dialogue")

func _ready():
	area.actionated.connect(actioned)
	area.ready.connect(readies)
	area.hideballoon.connect(noreadies)

func actioned():
	DialogueManager.show_dialogue_balloon(load("res://Dialogos/dialogue.dialogue"), "dialogo1")
	
func readies():
	press_f_ballon.visible = true  # Muestra el ícono cuando recibe la señal

func noreadies():
	press_f_ballon.visible = false  # Oculta el ícono cuando el jugador se aleja
