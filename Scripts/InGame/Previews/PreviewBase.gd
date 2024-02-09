extends Node2D

class_name PreviewBase

@onready var nameLabel : Label = $NameLabel
@onready var selectionRect : Control = $SelectionRect
@onready var votesLabel : Label = $VotesLabel

#Vars for hovering and selecting
var canSelect : bool = true
var isHovering : bool = false
const hoverScaleMin : float = 1.0
const hoverScaleMax : float = 1.05
var hoverTimer : float = 0.0
const hoverTimeMax : float = 0.1

#Signal emitted when the node is pressed
signal onSelected()

func setName(text : String) -> void:
	self.nameLabel.set_text(text)

func getName() -> String:
	return self.nameLabel.get_text()

func showVotes() -> void:
	votesLabel.show()

func hideVotes() -> void:
	votesLabel.hide()

func setVotes(votes : int, totalVotes : int) -> void:
	votesLabel.show()
	votesLabel.set_text("Votes: " + str(votes) + "/" + str(totalVotes))

func onChildAdded(child) -> void:
	if is_instance_valid(selectionRect):
		move_child(selectionRect, get_child_count() - 1)

func onHoverEnter() -> void:
	isHovering = true

func onHoverExit() -> void:
	isHovering = false

func _process(delta):
	if canSelect:
		if isHovering:
			if hoverTimer < hoverTimeMax:
				hoverTimer += delta
				scale = Vector2.ONE * lerp(hoverScaleMin, hoverScaleMax, hoverTimer / hoverTimeMax)
			else:
				scale = Vector2.ONE * hoverScaleMax
		else:
			if hoverTimer > 0.0: 
				hoverTimer -= delta
				scale = Vector2.ONE * lerp(hoverScaleMin, hoverScaleMax, hoverTimer / hoverTimeMax)
			else:
				scale = Vector2.ONE * hoverScaleMin

func _input(event):
	if canSelect and isHovering:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and not event.is_echo():
			emit_signal("onSelected")
			print("Preview pressed: ", getName())

#Function to be overloaded to set preview data
func preview(data : Dictionary) -> void:
	pass
