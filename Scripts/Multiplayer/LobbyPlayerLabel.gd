extends Label

@onready var readyLabel : Label = $Label
@onready var kickButton : Button = $KickButton
@onready var banButton : Button = $BanButton

var username : String = ""

signal onKick(username)
signal onBan(username)

func setUsername(username : String) -> void:
	self.username = username
	self.text = self.username

func setReady(isReady : bool) -> void:
	readyLabel.text = "[R]" if isReady else "[   ]"

func showOptions() -> void:
	kickButton.show()
	banButton.show()

func hideOptions() -> void:
	kickButton.hide()
	banButton.hide()

func onKickPressed() -> void:
	emit_signal("onKick", username)

func onBanPressed() -> void:
	emit_signal("onBan", username)
