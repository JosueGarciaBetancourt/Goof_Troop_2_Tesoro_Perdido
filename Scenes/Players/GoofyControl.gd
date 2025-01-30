extends Node2D

@onready var player: CharacterBody2D = self.owner
@onready var animation_player: AnimationPlayer = player.get_node("AnimationPlayer")  

const SPEED = 350.0

enum STATE {
    STOP_DOWN, STOP_UP, STOP_RIGHT, STOP_LEFT,
    WALK_DOWN, WALK_UP, WALK_RIGHT, WALK_LEFT
}

var current_state: STATE = STATE.STOP_DOWN
var last_walk_state = STATE.WALK_DOWN  # Estado inicial

func _physics_process(delta):
    match current_state:
        STATE.STOP_DOWN, STATE.STOP_UP, STATE.STOP_RIGHT, STATE.STOP_LEFT:
            player.velocity = Vector2.ZERO

            var stop_state_map = {
                STATE.WALK_DOWN: STATE.STOP_DOWN,
                STATE.WALK_UP: STATE.STOP_UP,
                STATE.WALK_RIGHT: STATE.STOP_RIGHT,
                STATE.WALK_LEFT: STATE.STOP_LEFT,
            }
            var last_stop_state = stop_state_map.get(last_walk_state, STATE.STOP_DOWN)

            var stop_animations = {
                STATE.STOP_DOWN: "Goofy_Stop",
                STATE.STOP_UP: "Goofy_Stop_Up",
                STATE.STOP_RIGHT: "Goofy_Stop_Right",
                STATE.STOP_LEFT: "Goofy_Stop_Left",
            }
            animation_player.play(stop_animations.get(last_stop_state, "Goofy_Stop"))

            if Input.is_action_pressed("ui_left"):
                current_state = STATE.WALK_LEFT
            elif Input.is_action_pressed("ui_right"):
                current_state = STATE.WALK_RIGHT
            elif Input.is_action_pressed("ui_up"):
                current_state = STATE.WALK_UP
            elif Input.is_action_pressed("ui_down"):
                current_state = STATE.WALK_DOWN

        STATE.WALK_DOWN, STATE.WALK_UP, STATE.WALK_RIGHT, STATE.WALK_LEFT:
            var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
            player.velocity = direction * SPEED

            var walk_animations = {
                STATE.WALK_DOWN: "Goofy_Walk_Down",
                STATE.WALK_UP: "Goofy_Walk_Up",
                STATE.WALK_RIGHT: "Goofy_Walk_Right",
                STATE.WALK_LEFT: "Goofy_Walk_Left",
            }
            animation_player.play(walk_animations.get(current_state, "Goofy_Stop"))

            last_walk_state = current_state

    if Input.is_action_pressed("ui_left"):
        current_state = STATE.WALK_LEFT
    elif Input.is_action_pressed("ui_right"):
        current_state = STATE.WALK_RIGHT
    elif Input.is_action_pressed("ui_up"):
        current_state = STATE.WALK_UP
    elif Input.is_action_pressed("ui_down"):
        current_state = STATE.WALK_DOWN
    elif not (Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or 
              Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")):
        current_state = STATE.STOP_DOWN  

    player.move_and_slide()

func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.keycode == KEY_ESCAPE:
            get_tree().quit()
