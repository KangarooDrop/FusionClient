extends Node2D

class_name SelectorBase

@export var canOpenFolder : bool = false
@export var canVote : bool = false

var holderToPreview : Dictionary = {}
var timers : Dictionary = {}
const dropTimeMax : float = 0.2
const dropMinY : float = 20.0
const dropMaxY : float = 0.0
const dropMinScale : float = 1.5
const dropMaxScale : float = 1.0
const timeBetweenAdd : float = dropTimeMax/2.0

var index : int = 0
const numRows : int = 2
const previewPosOffset : Vector2 = Vector2(300.0, 250.0)
const previewPosStart : Vector2 = Vector2(-previewPosOffset.x, -previewPosOffset.y/2.0)

const scrollSpeed : float = 1024.0
const scrollWidth : float = 196.0
var scrollMin : float = 0.0
var scrollMax : float = 0.0
var lastMousePositionLocal : Vector2 = Vector2()
var lastViewportSize : Vector2 = Vector2()

var newPreview = null
var randomPreview = null

@onready var holder : Node2D = $Holder

signal onSelect(preview : PreviewBase)
signal onVote(preview : PreviewBase)

func clear() -> void:
	for c in holderToPreview.keys():
		c.queue_free()
	holderToPreview.clear()
	randomPreview = null
	index = 0
	scrollMin = 0.0

func setVotes(votes : Dictionary, totalVotes : int = -1) -> void:
	if totalVotes == -1:
		totalVotes = 0
		for val in votes.values():
			totalVotes += val
	for id in holder.get_child_count():
		var prev : PreviewBase = holderToPreview[holder.get_child(id)]
		var numVotes : int = 0
		if votes.has(id):
			numVotes = votes[id]
		prev.setVotes(numVotes, totalVotes)

func getPreview() -> PreviewBase:
	return Preloader.previewNew.instantiate()

func addAllPreviews(data : Array) -> void:
	clear()
	for i in range(data.size()):
		if typeof(data[i]) == TYPE_STRING:
			if data[i] == "random":
				addPreviewRandom()
			elif data[i] == "new":
				addPreviewNew()
		else:
			addPreview(data[i])
		await get_tree().create_timer(timeBetweenAdd).timeout

func addPreview(data : Dictionary) -> void:
	var prev : PreviewBase = getPreview()
	addPreviewNode(prev)
	prev.preview(data)

func addPreviewRandom() -> void:
	if is_instance_valid(randomPreview):
		randomPreview.queue_free()
	randomPreview = Preloader.previewRandom.instantiate()
	addPreviewNode(randomPreview)

func addPreviewNew() -> void:
	if is_instance_valid(newPreview):
		newPreview.queue_free()
	newPreview = Preloader.previewNew.instantiate()
	addPreviewNode(newPreview)

func addPreviewNode(previewNode : PreviewBase):
	var prevHolder : Node2D = Node2D.new()
	holder.add_child(prevHolder)
	prevHolder.add_child(previewNode)
	holderToPreview[prevHolder] = previewNode
	timers[prevHolder] = 0.0
	previewNode.connect("onSelected", self.onPreviewSelected.bind(previewNode))
	if canVote:
		previewNode.setVotes(0, 0)
		previewNode.showVotes()
	
	prevHolder.position = previewPosStart + Vector2(index / numRows, index % numRows) * previewPosOffset
	scrollMin = min(scrollMin, -prevHolder.position.x + previewPosOffset.x)
	index += 1

func _process(delta):
	for prevHolder in timers.keys():
		timers[prevHolder] += delta
		var t : float = timers[prevHolder] / dropTimeMax
		if timers[prevHolder] >= dropTimeMax:
			t = 1.0
			timers.erase(prevHolder)
		holderToPreview[prevHolder].position.y = lerp(dropMinY, dropMaxY, t)
		prevHolder.scale = Vector2.ONE * lerp(dropMinScale, dropMaxScale, t)
	
	lastMousePositionLocal = get_viewport().get_mouse_position()
	lastViewportSize = get_viewport_rect().size
	
	checkMove(delta)

func checkMove(delta : float):
	var sld : float = 0.0
	if Input.is_action_pressed("left"):
		sld = 1.0
	else:
		sld = getDistScrollLeft()
	if sld > 0:
		position.x = min(scrollMax, position.x + scrollSpeed * delta * sld)
	
	var srd : float = 0.0
	if Input.is_action_pressed("right"):
		srd = 1.0
	else:
		srd = getDistScrollRight()
	if srd > 0:
		position.x = max(scrollMin, position.x - scrollSpeed * delta * srd)

func getDistScrollLeft() -> float:
	return min((scrollWidth - lastMousePositionLocal.x) / scrollWidth, 1.0)

func getDistScrollRight() -> float:
	return min((scrollWidth + lastMousePositionLocal.x - lastViewportSize.x) / scrollWidth, 1.0)

func onPreviewSelected(preview : PreviewBase) -> void:
	if canVote:
		emit_signal("onVote", preview)
		if get_tree().current_scene == self:
			setVotes({holderToPreview.values().find(preview) : 1})
	else:
		emit_signal("onSelect", preview)
