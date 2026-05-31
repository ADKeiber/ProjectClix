class_name SessionPlayers
extends Control

@onready var players: VBoxContainer = %Players

var currentPlayers: Array[String]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GState.refresh_state.connect(update_players)

func update_players() -> void:
	for player_id in GState.players:
		var player: Player = GState.players[player_id]
		if not currentPlayers.has(player.username):
			var player_label: Label = Label.new()
			player_label.text = player.username
			if player_id == 1:
				player_label.text = player_label.text + " (HOST)" 
			players.add_child(player_label)
		currentPlayers.append(player.username)
		
