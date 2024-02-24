extends Node

"""
#IN GAME
var mainPacked : PackedScene = load("res://Game/Scenes/InGame/Main.tscn")
var cardPacked : PackedScene = load("res://Game/Scenes/InGame/CardNode.tscn")

#IN EDITOR
var boardPacked : PackedScene = load("res://Game/Scenes/InGame/Boards/BoardNode.tscn")
var territoryPacked : PackedScene = load("res://Game/Scenes/InGame/Territories/TerritoryNode.tscn")
"""

#Textures
var chipTexture : Texture = load("res://Art/chip.png")

#Menu
var startScreen : PackedScene = load("res://Scenes/UI/StartScreen.tscn")
var editorBoard : PackedScene = load("res://Scenes/InGame/Editors/EditorBoard.tscn")
var editorDeck : PackedScene = load("res://Scenes/InGame/Editors/EditorDeck.tscn")
var multiplayerLobby : PackedScene = load("res://Scenes/Multiplayer/MultiplayerLobby.tscn")
var main : PackedScene = load("res://Scenes/InGame/Main.tscn")

#Previews
var previewDeck : PackedScene = load("res://Scenes/InGame/Previews/PreviewDeck.tscn")
var previewBoard : PackedScene = load("res://Scenes/InGame/Previews/PreviewBoard.tscn")
var previewRandom : PackedScene = load("res://Scenes/InGame/Previews/PreviewRandom.tscn")
var previewNew : PackedScene = load("res://Scenes/InGame/Previews/PreviewNew.tscn")

#Base nodes
var territoryNodeBase : PackedScene = load("res://Scenes/InGame/Territories/TerritoryNodeBase.tscn")
var boardNodeBase : PackedScene = load("res://Scenes/InGame/Boards/BoardNodeBase.tscn")

#Board editor nodes
var territoryNodeEditable : PackedScene = load("res://Scenes/InGame/Territories/TerritoryNodeEditable.tscn")
var boardNodeEditable : PackedScene = load("res://Scenes/InGame/Boards/BoardNodeEditable.tscn")
var deckDisplayEntry : PackedScene = load("res://Scenes/InGame/Editors/DeckDisplayEntry.tscn")
var cardNodeEditor : PackedScene = load("res://Scenes/InGame/CardNodeEditor.tscn")

#Game nodes
var mainPacked : PackedScene = load("res://Scenes/InGame/Main.tscn")
var cardPacked : PackedScene = load("res://Scenes/InGame/CardNode.tscn")
var territoryNodeGame : PackedScene = load("res://Scenes/InGame/Territories/TerritoryNodeGame.tscn")
var boardNodeGame : PackedScene = load("res://Scenes/InGame/Boards/BoardNodeGame.tscn")
var chipNode : PackedScene = load("res://Scenes/InGame/Chip.tscn")
var slotNode : PackedScene = load("res://Scenes/InGame/Territories/CreatureSlot.tscn")
var playerNode : PackedScene = load("res://Scenes/InGame/PlayerNode.tscn")
