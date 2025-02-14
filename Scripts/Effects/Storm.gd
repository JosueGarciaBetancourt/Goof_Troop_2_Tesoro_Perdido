extends Node2D

@onready var nubes_izq = $NubesTormentaIz
@onready var nubes_der = $NubesTormentaDer
@onready var fondo_negro = $FondoNegro
@onready var anim_player = $AnimationPlayer
@onready var lluvia = $Lluvia
@onready var EfectosDeSonido = $SoundEffects
@onready var storm_audio = $SoundEffects/StormAudio  # Nodo para la tormenta
@onready var thunder_audio = $SoundEffects/ThunderAudio  # Nodo para los truenos
@onready var lightning_flash = $LightningFlash  # Nodo para el destello

var thunder_timer = Timer.new()  # Temporizador para los truenos

func _ready():
	Signals.special_event_triggered.connect(_on_special_event_triggered)
	
	# Configurar temporizador para los truenos
	thunder_timer.wait_time = randf_range(5, 10)  # Tiempo aleatorio entre 5 y 10 segundos
	thunder_timer.autostart = false
	thunder_timer.one_shot = false
	thunder_timer.timeout.connect(play_thunder)
	add_child(thunder_timer)

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

	# Cargar el audio de la tormenta y activar el loop
	var storm_stream = load("res://assets/effects/soundeffects/Storm.ogg")
	storm_stream.set_loop(true)  # Activar loop en el recurso de audio
	storm_audio.stream = storm_stream
	storm_audio.volume_db = -40  # Comenzar con volumen bajo
	storm_audio.play()

	# Aumentar el volumen de la tormenta gradualmente
	tween.tween_property(storm_audio, "volume_db", 0, 2.0)

	# Iniciar el temporizador de los truenos
	thunder_timer.start()

func play_thunder():
	# Reproducir trueno
	thunder_audio.stream = load("res://assets/effects/soundeffects/Thunder.ogg")
	thunder_audio.play()

	# Efecto de destello
	lightning_flash.modulate.a = 1.0  # Iluminar
	var tween = get_tree().create_tween()
	tween.tween_property(lightning_flash, "modulate:a", 0.0, 0.2)  # Apagar rápido

	# Reiniciar el temporizador con un nuevo tiempo aleatorio
	thunder_timer.wait_time = randf_range(5, 10)
	thunder_timer.start()
