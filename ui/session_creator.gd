class_name SessionCreator
extends Control

@onready var host_v_box_container: VBoxContainer = $HostVBoxContainer
@onready var join_v_box_container: VBoxContainer = $JoinVBoxContainer
@onready var host_button: Button = $HostButton
@onready var join_button: Button = $JoinButton
const BOX_THEME = preload("res://resources/box_theme.tres")
@onready var session_creator: SessionCreator = %SessionCreator
@onready var team_importer: TeamImporter = %TeamImporter

@onready var create_session_button: Button = %CreateSessionButton
@onready var join_code_value: Label = %JoinCodeValue
@onready var player_name_input: LineEdit = %PlayerNameInput

@onready var player_name_join_input: LineEdit = %PlayerNameJoinInput
@onready var join_code_input: LineEdit = %JoinCodeInput

@onready var number_of_players_dropdown: OptionButton = %NumberOfPlayersDropdown

var selectedTab : int = 0
var join_code: String = ""
var join_ip: String = "127.0.0.1" #updates if it isn't hosted on same machine that is joining
var port = 7777

#local network hosting stuff
var current_session_id : int = 0
var last_connection_status := -1 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	current_session_id = LAN.get_unused_session_id()
	NetUtil.get_public_ip()
	Network.player_joined.connect(_add_player_state)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if multiplayer.multiplayer_peer == null:
		return
	var status = multiplayer.multiplayer_peer.get_connection_status()
	if status != last_connection_status:
		last_connection_status = status
		match status:
			MultiplayerPeer.CONNECTION_DISCONNECTED:
				print("STATUS: DISCONNECTED")
			MultiplayerPeer.CONNECTION_CONNECTING:
				print("STATUS: CONNECTING")
			MultiplayerPeer.CONNECTION_CONNECTED:
				print("STATUS: CONNECTED")

func _on_host_button_pressed() -> void:
	switch_tab(0)

func _on_join_button_pressed() -> void:
	switch_tab(1)

func switch_tab(tab:int) -> void:
	if tab == 0:
		join_v_box_container.visible = false
		host_v_box_container.visible = true
		host_button.theme = BOX_THEME
		join_button.theme = null
	if tab == 1:
		join_v_box_container.visible = true
		host_v_box_container.visible = false
		host_button.theme = null
		join_button.theme = BOX_THEME
		join_code_value.text = "----------"

func _on_copy_button_pressed() -> void:
	#if len(join_code) < 10 || join_code == "----------":
	join_code = JoinCode.generate_join_code(NetUtil.public_ip, port, current_session_id)
		#public_ip = "1.1.1.1" used to test if its on the internet
	join_code_value.text = join_code
	DisplayServer.clipboard_set(join_code_value.text)

func _on_create_session_button_pressed() -> void:
	if len(player_name_input.text) <= 1:
		OS.alert("Player must have a player name with length greater than 1...")
		return
	if not NetUtil.setup_upnp(port):
		OS.alert("Failed to setup port fowarding on router...")
	if not Network.create_host(port):
		return
	LAN.start_host(current_session_id, port)
	print("Hosting Session")
	print("Join Code: ", JoinCode.generate_join_code(NetUtil.public_ip, port, current_session_id))
	Network.player_joined.emit(1)
	_add_player_state
	

func _on_join_session_button_pressed() -> void:
	if  len(player_name_join_input.text) <= 1:
		OS.alert("Player must have a player name with length greater than 1...")
		return
	#if  len(join_code_input.text) != 10:
		#OS.alert("Join code must be 9 digits long...")
		#return
	var join_info: Dictionary = JoinCode.decode_join_code(join_code_input.text)
	print("HOST IP FROM JOIN CODE:")
	print(join_info)

	print("MY PUBLIC IP:")
	print(NetUtil.public_ip)
	if not join_info.has("success"):
		print("Malformed response")
		return

	if not join_info["success"]:
		print("FAILED TO DECODE JOIN CODE")
		return

	if join_info["port"] != port:
		print("PORTS DO NOT MATCH!! INCORRECT CONVERSION")
	print("COMPARE:")
	print("'" + join_info["ip"] + "'")
	print("'" + NetUtil.public_ip + "'")

	if join_info["ip"].strip_edges() == NetUtil.public_ip.strip_edges():

		var session_id = join_info["session_id"]

		print("JOIN CODE SESSION:")
		print(session_id)
	
		var host = LAN.get_host(session_id)
		if not host.is_empty():
			join_ip = host["ip"]
			print("LAN HOST FOUND")
			print(join_ip)
		else:
			print("Same public IP but LAN host not found")
			join_ip = join_info["ip"]
	else:
		join_ip = join_info["ip"]

	print("JOINING HOST AT:")
	print(join_ip)

	Network.create_client(
		join_ip,
		join_info["port"]
	)

func _add_player_state(id: int) -> void:
	var player: Player = Player.new()
	print("ID in add player state:")
	print(id)
	if id != 1:
		player.username = player_name_join_input.text
		GState.register_player.rpc_id(1, player.to_dict())
		GState.players[id] = player
	else:
		player.username = player_name_input.text
		GState.players[id] = player
	GState.refresh_state.emit()
	GState.session_joined.emit() #switches to team importer instead of game create

##Maybe should be in Lobby Scene?

func _on_number_of_players_dropdown_item_selected(index: int) -> void:
	GState.max_number_of_players = int(number_of_players_dropdown.get_item_text(index))
