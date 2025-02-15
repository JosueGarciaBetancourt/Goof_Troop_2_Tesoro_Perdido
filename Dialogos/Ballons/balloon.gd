extends CanvasLayer

@export var next_action: StringName = &"ui_kicking"
@export var skip_action: StringName = &"ui_cancel"

var resource: DialogueResource
var current_title: String = ""

@onready var portrait_left: TextureRect = %Balloon/PortraitLeft
@onready var portrait_right: TextureRect = %Balloon/PortraitRight
@onready var voice_player: AudioStreamPlayer2D = $VoicePlayer

var portraits = {
	"Goofy": preload("res://assets/portraits/GoofPortrait.png"),
	"Max": preload("res://assets/portraits/MaxPortrait.png"),
	"Pedro": preload("res://assets/portraits/PedroPortrait.png"),
	"Taka": preload("res://assets/portraits/TakaPortrait.png")
}

var active_characters: Array = []
var upcoming_speaker: String = ""  # Renombrado para evitar SHADOWED_VARIABLE

var temporary_game_states: Array = []
var is_waiting_for_input: bool = false
var will_hide_balloon: bool = false
var locals: Dictionary = {}

var _locale: String = TranslationServer.get_locale()

var dialogue_line: DialogueLine:
	set(next_dialogue_line):
		is_waiting_for_input = false
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()

		# Si el diálogo ha terminado, cerrar el globo de diálogo
		if not next_dialogue_line:
			queue_free()
			return

		if not is_node_ready():
			await ready

		dialogue_line = next_dialogue_line
		# Llamar a la función para verificar eventos especiales
		check_special_events()
		character_label.visible = not dialogue_line.character.is_empty()
		character_label.text = tr(dialogue_line.character, "dialogue")

		# Obtener el próximo hablante si existe
		var upcoming_speaker = ""
		if dialogue_line.next_id != "": 
			var next_line = await resource.get_next_dialogue_line(dialogue_line.next_id, temporary_game_states)
			if next_line:
				upcoming_speaker = next_line.character

		# Inicializar personajes activos solo en la primera línea
		if active_characters.is_empty():
			active_characters.append(dialogue_line.character)
			if upcoming_speaker != "":
				active_characters.append(upcoming_speaker)
			else:
				active_characters.append("Max" if dialogue_line.character != "Max" else "Goofy")

		# Actualizar los retratos según el personaje actual y el próximo
		update_portraits(dialogue_line.character, upcoming_speaker)
		play_voice_clip(current_title, dialogue_line.id)

		dialogue_label.hide()
		dialogue_label.dialogue_line = dialogue_line

		responses_menu.hide()
		responses_menu.set_responses(dialogue_line.responses)

		# Mostrar el globo de diálogo
		balloon.show()
		will_hide_balloon = false

		dialogue_label.show()
		if not dialogue_line.text.is_empty():
			dialogue_label.type_out()
			await dialogue_label.finished_typing

		# Verificar si hay respuestas o si el diálogo debe avanzar automáticamente
		if dialogue_line.responses.size() > 0:
			balloon.focus_mode = Control.FOCUS_NONE
			responses_menu.show()
		elif dialogue_line.time != "":
			var time = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
			await get_tree().create_timer(time).timeout
			next(dialogue_line.next_id)
		else:
			is_waiting_for_input = true
			balloon.focus_mode = Control.FOCUS_ALL
			balloon.grab_focus()

	get:
		return dialogue_line

func update_portraits(speaker: String, future_speaker: String):  # Renombrado para evitar conflicto
	if speaker not in active_characters:
		if active_characters.size() < 2:
			active_characters.append(speaker)
		else:
			if future_speaker in active_characters:
				var index_to_replace = 1 if active_characters[0] == future_speaker else 0
				active_characters[index_to_replace] = speaker
			else:
				active_characters[1] = speaker

	if active_characters.size() == 1:
		active_characters.append("Max" if active_characters[0] != "Max" else "Goofy")

	portrait_left.texture = portraits.get(active_characters[0], null)
	portrait_right.texture = portraits.get(active_characters[1], null)

	apply_shader(portrait_left, active_characters[0] != speaker)
	apply_shader(portrait_right, active_characters[1] != speaker)

func apply_shader(portrait: TextureRect, should_fade: bool):
	if not portrait.material:
		portrait.material = ShaderMaterial.new()
		portrait.material.shader = load("res://Dialogos/Shaders/portrait_shader.gdshader")

	var mat: ShaderMaterial = portrait.material  # Renombrado para evitar CONFUSABLE_LOCAL_DECLARATION
	var target_darkness = 0.6 if should_fade else 0.0

	# Aplicar transición suave
	var tween = create_tween()
	tween.tween_property(mat, "shader_parameter/darkness", target_darkness, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func play_voice_clip(dialogue_id: String, line_id: String):
	# Convertir a número y restar 1 para corregir el desplazamiento
	var line_number = line_id.to_int() - 1
	var audio_path = "res://Dialogos/Audios/" + dialogue_id + "L" + str(line_number) + ".ogg"
	
	# Verificar si el archivo existe antes de intentar cargarlo
	if FileAccess.file_exists(audio_path):
		voice_player.stream = load(audio_path)
		voice_player.play()
	else:
		print("Archivo de audio no encontrado: ", audio_path)

func check_special_events():
	if current_title == "E1D1" and dialogue_line.id.to_int() == 6:
		print("✅ Señal enviada: E1D1 - Línea 6")
		Signals.special_event_triggered.emit(current_title, 6)

@onready var balloon: Control = %Balloon
@onready var character_label: RichTextLabel = %CharacterLabel
@onready var dialogue_label: DialogueLabel = %DialogueLabel
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu

func _ready() -> void:
	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	# If the responses menu doesn't have a next action set, use this one
	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action

func _unhandled_input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio = dialogue_label.visible_ratio
		self.dialogue_line = await resource.get_next_dialogue_line(dialogue_line.id)
		if visible_ratio < 1:
			dialogue_label.skip_typing()

func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	if not is_node_ready():
		await ready
	
	print("Starting dialogue with title: ", title)  # Depuración

	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	resource = dialogue_resource
	current_title = title
	
	self.dialogue_line = await resource.get_next_dialogue_line(title, temporary_game_states)

	# Si el título del diálogo es "END", cerramos inmediatamente
	if title == "END":
		print("Detected END in start(), hiding balloon.")
		balloon.hide()
		queue_free()

func next(next_id: String) -> void:
	self.dialogue_line = await resource.get_next_dialogue_line(next_id, temporary_game_states)

func _on_mutated(_mutation: Dictionary) -> void:
	is_waiting_for_input = false
	will_hide_balloon = true
	get_tree().create_timer(0.1).timeout.connect(func():
		if will_hide_balloon:
			will_hide_balloon = false
			balloon.hide()
	)

func _on_balloon_gui_input(event: InputEvent) -> void:
	# See if we need to skip typing of the dialogue
	if dialogue_label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		next(dialogue_line.next_id)
	elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)

func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)
