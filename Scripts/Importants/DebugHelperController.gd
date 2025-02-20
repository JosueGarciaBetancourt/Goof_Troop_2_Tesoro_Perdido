extends Node

@onready var prevDirectionLabel: Label = get_node("/root/Stage_1/DebugLabels/prev_direction_label")
@onready var prevOrthogonalDirectionLabel: Label = get_node("/root/Stage_1/DebugLabels/prev_orthogonal_direction_label")
@onready var movementDirectionLabel: Label = get_node("/root/Stage_1/DebugLabels/movement_direction_label")
@onready var handsUpLabel: Label = get_node("/root/Stage_1/DebugLabels/handsUp_label")
@onready var kickingLabel: Label = get_node("/root/Stage_1/DebugLabels/kicking_label")
@onready var infoMessageLabel: Label = get_node("/root/Stage_1/DebugLabels/infoMessage_label")

func _ready():
	pass

func debugInfoMessageLabel(infoMessage):
	if infoMessageLabel:
		infoMessageLabel.text = str(infoMessage)

func debugPrevDirectionLabel(prevDirection):
	if prevDirectionLabel:
		prevDirectionLabel.text = "prev_direction: " + str(prevDirection)

func debugPrevOrthogonalDirectionLabel(prev_orthogonal_direction):
	if prevOrthogonalDirectionLabel:
		prevOrthogonalDirectionLabel.text = "prev_orthogonal_direction: " + str(prev_orthogonal_direction)

func debugMovementDirectionLabel(movementDirection):
	if movementDirectionLabel:
		movementDirectionLabel.text = "movement_direction: " + str(movementDirection)

func debugHandsUpLabel(handsUp):
	if handsUpLabel:
		handsUpLabel.text = "handsUp: " + str(handsUp)

func debugKickingLabel(kicking):
	if kickingLabel:
		kickingLabel.text = "kicking: " + str(kicking)
