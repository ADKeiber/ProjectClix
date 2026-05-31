class_name GameState
extends Node

signal get_figures_data(username: String)
signal refresh_state()
signal session_joined()


var players: Dictionary[int,Player]  = {} # Data is peer ID, Player information


######################################
## Client to host data sync
######################################
#Host player sync
@rpc("any_peer", "reliable")
func register_player(username: String):
	var sender_id = multiplayer.get_remote_sender_id()
	print("Player registered: ", username)
	var player: Player = Player.new()
	player.username = username
	GState.players[sender_id] = player
	print("USER ADDED TO GLOBAL STATE!")
	GState.refresh_state.emit()

	#Will need to update to transfer more potentially
	var player_data := {}
	for peer_id in GState.players:
		player_data[peer_id] = {
			"username": GState.players[peer_id].username
		}
	sync_players.rpc(player_data)

######################################
## Host to Clients data sync
######################################
#client player sync
@rpc("authority", "reliable")
func sync_players(player_data: Dictionary):
	GState.players.clear()
	for peer_id in player_data:
		var player := Player.new()
		player.username = player_data[peer_id]["username"]
		GState.players[peer_id] = player
	GState.refresh_state.emit()
