extends Node

"""
#IN GAME
const mainPacked : PackedScene = preload("res://Game/Scenes/InGame/Main.tscn")
const cardPacked : PackedScene = preload("res://Game/Scenes/InGame/CardNode.tscn")

#IN EDITOR
const boardPacked : PackedScene = preload("res://Game/Scenes/InGame/Boards/BoardNode.tscn")
const territoryPacked : PackedScene = preload("res://Game/Scenes/InGame/Territories/TerritoryNode.tscn")
"""

#Menu
const startScreen : PackedScene = preload("res://Scenes/UI/StartScreen.tscn")
const editorBoard : PackedScene = preload("res://Scenes/InGame/Editors/EditorBoard.tscn")

#Base nodes
const territoryNode : PackedScene = preload("res://Scenes/InGame/Territories/TerritoryNode.tscn")
const boardNode : PackedScene = preload("res://Scenes/InGame/Boards/BoardNode.tscn")

#Board editor nodes
const territoryEditable : PackedScene = preload("res://Scenes/InGame/Territories/TerritoryEditable.tscn")
const boardEditable : PackedScene = preload("res://Scenes/InGame/Boards/BoardEditable.tscn")

#Game nodes
const mainPacked : PackedScene = preload("res://Scenes/InGame/MainNode.tscn")
const cardPacked : PackedScene = preload("res://Scenes/InGame/CardNode.tscn")
