extends Node

var prevDirectionLabel: Label = null
var movementDirectionLabel: Label = null
var handsUpLabel: Label = null
var kickingLabel: Label = null

func set_labels(prev_label: Label, move_label: Label, hands_label: Label, kick_label: Label):
	prevDirectionLabel = prev_label
	movementDirectionLabel = move_label
	handsUpLabel = hands_label
	kickingLabel = kick_label

func debugPrevDirectionLabel(prevDirection):
	if prevDirectionLabel:
		prevDirectionLabel.text = "prev_direction: " + str(prevDirection)

func debugMovementDirectionLabel(movementDirection):
	if movementDirectionLabel:
		movementDirectionLabel.text = "movement_direction: " + str(movementDirection)

func debugHandsUpLabel(handsUp):
	if handsUpLabel:
		handsUpLabel.text = "handsUp: " + str(handsUp)

func debugKickingLabel(kicking):
	if kickingLabel:
		kickingLabel.text = "kicking: " + str(kicking)
