extends Node2D

class_name CardExpander

var cam : Camera2D

var waitingForRulesShown : bool = false
var waitingForRulesHidden : bool = false
var expandTimer : float = 0.0
var expandedCardNode : CardNode = null
var returningCardNodes : Dictionary = {}
var rulesHidingCardNodes : Array = []

const EXPAND_TIME : float = 0.25
const Z_INC : int = 8
const SCALE_MIN : Vector2 = Vector2.ONE
const SCALE_MAX : Vector2 = Vector2.ONE*2.0

func easeSin(t : float) -> float:
	return t * (sin(2*PI*t)+2.0)/2.0
func easeCos(t : float) -> float:
	return t * (cos(2*PI*t)+1.0)/2.0

const p=1.54
const h=1.1
func easeScaleX(t : float) -> float:
	return -(4*h)/(p*p) * t * (t-p)
func easeScaleY(t : float) -> float:
	return 2*t*(t-0.5)

func setExpanded(cardNode : CardNode) -> void:
	if waitingForRulesHidden or cardNode == expandedCardNode:
		return
	
	if is_instance_valid(expandedCardNode):
		expandedCardNode.setShowRules(false)
		rulesHidingCardNodes.append(expandedCardNode)
		waitingForRulesHidden = true
	
	if waitingForRulesShown:
		onRulesShown(expandedCardNode)
		if expandedCardNode.rulesHolder.size.x <= 0:
			onRulesHidden(expandedCardNode)
	
	expandedCardNode = cardNode
	if expandedCardNode != null:
		waitingForRulesShown = true
		expandedCardNode.holder.z_index += Z_INC
		expandedCardNode.connect("rules_shown", self.onRulesShown.bind(expandedCardNode))
		expandedCardNode.connect("rules_hidden", self.onRulesHidden.bind(expandedCardNode))

func _process(delta):
	if is_instance_valid(expandedCardNode):
		if expandTimer < EXPAND_TIME:
			expandTimer += delta
			if expandTimer > EXPAND_TIME:
				expandTimer = EXPAND_TIME
			var t : float = expandTimer/EXPAND_TIME
			expandedCardNode.holder.global_position = lerp(expandedCardNode.global_position, cam.global_position + cam.get_viewport_rect().size/2.0 + Vector2(-expandedCardNode.rulesHolder.size.x, 0.0), t)
			expandedCardNode.holder.scale.x = lerp(SCALE_MIN.x, SCALE_MAX.x, easeScaleY(t))
			expandedCardNode.holder.scale.y = lerp(SCALE_MIN.y, SCALE_MAX.y, easeScaleY(t))
		elif not expandedCardNode.showRules:
			expandedCardNode.setShowRules(true)
		else:
			expandedCardNode.holder.global_position = cam.global_position + cam.get_viewport_rect().size/2.0 + Vector2(-expandedCardNode.rulesHolder.size.x, 0.0)
	elif expandedCardNode != null:
		onRulesHidden(expandedCardNode)
		expandedCardNode = null
	
	for cardNode in rulesHidingCardNodes:
		cardNode.holder.global_position = cam.global_position + cam.get_viewport_rect().size/2.0 + Vector2(-cardNode.rulesHolder.size.x, 0.0)
	
	for cardNode in returningCardNodes.keys():
		if is_instance_valid(cardNode) and returningCardNodes[cardNode] > 0.0:
			returningCardNodes[cardNode] -= delta
			if returningCardNodes[cardNode] <= 0:
				returningCardNodes[cardNode] = 0
			var t : float = returningCardNodes[cardNode]/EXPAND_TIME
			cardNode.holder.global_position = lerp(cardNode.global_position, cam.global_position + cam.get_viewport_rect().size/2.0, t)
			cardNode.holder.scale.x = lerp(SCALE_MIN.x, SCALE_MAX.x, easeScaleX(t))
			cardNode.holder.scale.y = lerp(SCALE_MIN.y, SCALE_MAX.y, easeScaleX(t))
		else:
			if is_instance_valid(cardNode):
				cardNode.holder.z_index -= Z_INC
			returningCardNodes.erase(cardNode)

func onRulesShown(cardNode : CardNode) -> void:
	cardNode.disconnect("rules_shown", self.onRulesShown.bind(cardNode))
	waitingForRulesShown = false

func onRulesHidden(cardNode : CardNode) -> void:
	if is_instance_valid(cardNode):
		cardNode.disconnect("rules_hidden", self.onRulesHidden.bind(cardNode))
		returningCardNodes[cardNode] = expandTimer
		rulesHidingCardNodes.erase(cardNode)
	expandTimer = 0.0
	waitingForRulesHidden = false
