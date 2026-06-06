class_name TeamImporter
extends Control

@onready var add_figure: Button = %AddFigure
@onready var team_import: VBoxContainer = %TeamImport
@onready var ready_up_button: Button = %ReadyUpButton
@onready var start_game_button: Button = %StartGameButton

@onready var GAME_OBJECT_IMPORT_UI = preload("res://ui/game_object_import.tscn")
var num_urls: int = 1
var player_ready: bool = false

func _ready() -> void:
	start_game_button.visible = false
	GState.all_players_ready.connect(display_start_button)

func _on_import_button_pressed() -> void:
	var player: Player = GState.players[GState.my_peer_id()]
	var urls: Array[String] = []
	var gameObjectType: Array[GameObject.Type] = []
	##gets the URL values :)
	for child in team_import.get_children():
		if child.get_url()[len(child.get_url()) - 1] == "/":
			urls.append(child.get_url().substr(0, len(child.get_url()) - 1))
		else:
			urls.append(child.get_url())
		gameObjectType.append(child.get_type())
		child.queue_free()
	player.gameObjectUrls.append_array(urls)
	player.gameObjectTypes.append_array(gameObjectType)
	GState.import_team.emit(GState.my_peer_id(), urls, gameObjectType)
	for child in team_import.get_children():
		child.queue_free()
	
	num_urls = 0
	_on_add_figure_pressed()
	
	#
	#GState.players[GState.my_peer_id()] = player
	##GState.get_figures_data.emit(player.username)
	#print("MY ID: ", multiplayer.get_unique_id())
	#print("IS SERVER: ", multiplayer.is_server())
	#if multiplayer.is_server():
		#print("Host team sync")
		#GState.import_team_sync(1, player.to_dict())
	#else:
		#GState.import_team_sync.rpc_id(1, GState.my_peer_id(), player.to_dict())


func _on_add_figure_pressed() -> void:
	num_urls += 1
	var newObjectImport = GAME_OBJECT_IMPORT_UI.instantiate()
	team_import.add_child(newObjectImport)
	newObjectImport.set_field_name(num_urls)
	print("Added additonal figure field")


func _on_ready_up_button_pressed() -> void:
	if ready_up_button.text == "Ready Up!":
		ready_up_button.text = " Unready "
		player_ready = true
	else:
		ready_up_button.text = "Ready Up!"
		player_ready = false
	print("Ready? %s" % player_ready)
	if multiplayer.is_server():
		print("Host team sync")
		GState.ready_player_host(1, player_ready)
	else:
		GState.ready_player_host.rpc_id(1, GState.my_peer_id(), player_ready)

func display_start_button(visible: bool) -> void:
	if multiplayer.is_server():
		start_game_button.visible = visible
	else:
		start_game_button.visible = false
	
func _on_start_game_button_pressed() -> void:
	GState.demand_units_from_clients.rpc()
	GState.move_to_battle_host()

func hide_start_game_button() -> void:
	start_game_button.visible = false
