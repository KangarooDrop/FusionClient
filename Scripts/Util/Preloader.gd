extends Node

"""
#IN GAME
const mainPacked : PackedScene = preload("res://Game/Scenes/InGame/Main.tscn")
const cardPacked : PackedScene = preload("res://Game/Scenes/InGame/CardNode.tscn")

#IN EDITOR
const boardPacked : PackedScene = preload("res://Game/Scenes/InGame/Boards/BoardNode.tscn")
const territoryPacked : PackedScene = preload("res://Game/Scenes/InGame/Territories/TerritoryNode.tscn")
"""

#Textures
const chipTexture : Texture = preload("res://Art/chip.png")

#Menu
const startScreen : PackedScene = preload("res://Scenes/UI/StartScreen.tscn")
const editorBoard : PackedScene = preload("res://Scenes/InGame/Editors/EditorBoard.tscn")
const editorDeck : PackedScene = preload("res://Scenes/InGame/Editors/EditorDeck.tscn")
const multiplayerLobby : PackedScene = preload("res://Scenes/Multiplayer/MultiplayerLobby.tscn")
const main : PackedScene = preload("res://Scenes/InGame/Main.tscn")

#Previews
const previewDeck : PackedScene = preload("res://Scenes/InGame/Previews/PreviewDeck.tscn")
const previewBoard : PackedScene = preload("res://Scenes/InGame/Previews/PreviewBoard.tscn")
const previewRandom : PackedScene = preload("res://Scenes/InGame/Previews/PreviewRandom.tscn")
const previewNew : PackedScene = preload("res://Scenes/InGame/Previews/PreviewNew.tscn")

#Base nodes
const territoryNodeBase : PackedScene = preload("res://Scenes/InGame/Territories/TerritoryNodeBase.tscn")
const boardNodeBase : PackedScene = preload("res://Scenes/InGame/Boards/BoardNodeBase.tscn")

#Board editor nodes
const territoryNodeEditable : PackedScene = preload("res://Scenes/InGame/Territories/TerritoryNodeEditable.tscn")
const boardNodeEditable : PackedScene = preload("res://Scenes/InGame/Boards/BoardNodeEditable.tscn")

#Game nodes
const mainPacked : PackedScene = preload("res://Scenes/InGame/Main.tscn")
const cardPacked : PackedScene = preload("res://Scenes/InGame/CardNode.tscn")
const territoryNodeGame : PackedScene = preload("res://Scenes/InGame/Territories/TerritoryNodeGame.tscn")
const boardNodeGame : PackedScene = preload("res://Scenes/InGame/Boards/BoardNodeGame.tscn")
const chipNode : PackedScene = preload("res://Scenes/InGame/Chip.tscn")
