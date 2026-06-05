class_name SessionPlayers
extends Control

@onready var players_list: VBoxContainer = %PlayersList
@onready var connected_player_header: Label = %ConnectedPlayerHeader

const CONNECTED_PLAYER_UI = preload("res://ui/connected_player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GState.refresh_state.connect(update_players)
	GState.ready_player.connect(ready_player)

func update_players() -> void:
	for child in players_list.get_children():
		child.queue_free()
	#send to clients that player left
	for player_id in GState.players:
		var player_connection: ConnectedPlayer = CONNECTED_PLAYER_UI.instantiate()
		players_list.add_child(player_connection)
		var player: Player = GState.players[player_id]
		if player_id == 1:
				player_connection.set_player_name(player.username + " (HOST)")
		else:
			player_connection.set_player_name(player.username)
		player_connection.set_ready(player.ready)
	connected_player_header.text = "Connected Players: (%s/%s)" % [len(GState.players), GState.max_number_of_players]

func ready_player(peer_id: int, ready: bool) -> void:
	var player: Player = GState.players[peer_id]
	for child in players_list.get_children():
		var text:String = child.get_username().replace(" (HOST)","")
		if text == player.username:
			child.set_ready(ready)
