class_name NetworkHandler
extends Node

signal player_joined(peer_id)
signal player_left(peer_id)

signal connected_to_host()
signal connection_failed()
signal disconnected_from_host()

var peer : ENetMultiplayerPeer

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func create_host(port: int) -> bool:
	peer = ENetMultiplayerPeer.new()
	print("HOSTING ON PORT: ", port)
	var err = peer.create_server(port)
	if err != OK:
		print("Failed to create host")
		return false
	multiplayer.multiplayer_peer = peer
	print("HOST CREATED")
	return true

func create_client(ip: String, port_num: int) -> bool:
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, port_num)
	if err != OK:
		print("Failed to create client")
		return false
	multiplayer.multiplayer_peer = peer
	return true

func _on_peer_connected(id: int) -> void:
	#player_joined.emit(id)
	print("===================================")
	print("PLAYER JOINED THE HOSTED GAME")
	print("Peer ID: ", id)
	print("===================================")

func _on_peer_disconnected(id: int) -> void:
	player_left.emit(id)
	print("===================================")
	print("PLAYER LEFT THE GAME")
	print("Peer ID: ", id)
	print("===================================")

func _on_connected_to_server() -> void:
	#connected_to_host.emit()
	var id: int = multiplayer.get_unique_id()
	print("===================================")
	print("SUCCESSFULLY JOINED HOSTED GAME")
	print("My Peer ID: ", id)
	print("===================================")
	player_joined.emit(id)

func _on_connection_failed() -> void:
	connection_failed.emit()
	print("===================================")
	print("FAILED TO JOIN HOSTED GAME")
	print("===================================")

func _on_server_disconnected() -> void:
	disconnected_from_host.emit()
	print("===================================")
	print("DISCONNECTED FROM HOST")
	print("===================================")
