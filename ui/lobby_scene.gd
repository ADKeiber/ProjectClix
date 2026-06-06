class_name LobbyScene
extends Node2D


@onready var session_creator: SessionCreator = $SessionCreator
@onready var team_importer: TeamImporter = $TeamImporter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GState.get_figures_data.connect(GState.get_figures)
	GState.load_units()
	team_importer.visible = false
	session_creator.visible = true
	GState.session_joined.connect(_switch_to_team_importer)

func _switch_to_team_importer() -> void:
	session_creator.visible = false
	team_importer.visible = true
	team_importer.hide_start_game_button()
