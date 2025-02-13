extends Node2D

@onready var nubes_izq = $NubesTormentaIz
@onready var nubes_der = $NubesTormentaDer
@onready var fondo_negro = $FondoNegro
@onready var anim_player = $AnimationPlayer
@onready var lluvia = $Lluvia

func _ready():
	Signals.special_event_triggered.connect(_on_special_event_triggered)

func _on_special_event_triggered(dialogue_name, line_number):
	print("🎯 Señal recibida en", dialogue_name, "línea", line_number)
	var tween = get_tree().create_tween().set_parallel(true)  # Mover todo al mismo tiempo
	
	# Mover ambas nubes simultáneamente
	tween.tween_property(nubes_izq, "position", nubes_izq.position + Vector2(1450, 0), 3.0)
	tween.tween_property(nubes_der, "position", nubes_der.position - Vector2(1000, 0), 3.0)

	# Aumentar opacidad de FondoNegro al mismo tiempo
	tween.tween_property(fondo_negro, "modulate:a", 0.7, 3.0)
	tween.tween_property(lluvia, "modulate:a", 1.0, 3.0)

	# Reproducir la animación de lluvia después de la transición
	tween.tween_callback(anim_player.play.bind("Rain"))
