class_name LanDiscovery
extends Node

const DISCOVERY_PORT := 8911
var discovery_broadcast := PacketPeerUDP.new()
var discovery_listener := PacketPeerUDP.new()
var discovered_lan_hosts : Dictionary = {}
var host_session_id : int = -1
var host_port : int = -1
var broadcast_timer : Timer
var printed = false
func _ready() -> void:
	var err = discovery_listener.bind(DISCOVERY_PORT)

	if err != OK:
		printerr("Failed to bind LAN discovery")

	broadcast_timer = Timer.new()
	broadcast_timer.wait_time = 1.0
	broadcast_timer.autostart = false
	broadcast_timer.timeout.connect(_broadcast_host)
	add_child(broadcast_timer)

func _process(_delta: float) -> void:
	while discovery_listener.get_available_packet_count() > 0:
		var packet = discovery_listener.get_packet()
		
		var sender_ip = discovery_listener.get_packet_ip()
		#print("PACKET FROM:", sender_ip)
		
		var text = packet.get_string_from_utf8()
		var data = JSON.parse_string(text)
		if data == null:
			continue
		var session_id : int = int(data["session_id"])
		discovered_lan_hosts[session_id] = {
			"ip": discovery_listener.get_packet_ip(),
			"port": int(data["port"])
		}
		#print("DISCOVERED HOST:")
		#print(discovered_lan_hosts[session_id])

func start_host(session_id: int,port: int) -> void:
	discovered_lan_hosts.clear()
	host_session_id = session_id
	host_port = port
	discovery_broadcast.set_broadcast_enabled(true)
	if broadcast_timer.is_stopped():
		broadcast_timer.start()

func stop_host() -> void:
	host_session_id = -1
	host_port = -1
	if not broadcast_timer.is_stopped():
		broadcast_timer.stop()

func get_host(session_id: int) -> Dictionary:
	if discovered_lan_hosts.has(session_id):
		return discovered_lan_hosts[session_id]
	return {}

func clear_hosts() -> void:
	discovered_lan_hosts.clear()

func _broadcast_host() -> void:
	#print("BROADCASTING HOST IP:", get_local_ipv4())
	if host_session_id < 0:
		return
	var message = {
		"session_id": host_session_id,
		"ip": get_local_ipv4(),
		"port": host_port
	}
	var packet = JSON.stringify(message).to_utf8_buffer()
	discovery_broadcast.set_dest_address("255.255.255.255", DISCOVERY_PORT)
	discovery_broadcast.put_packet(packet)

func get_local_ipv4() -> String:
	var candidates: Array[String] = []

	for ip in IP.get_local_addresses():
		if ip.contains(":"):
			continue

		if ip.begins_with("127."):
			continue

		if ip.begins_with("169.254."):
			continue

		if ip.begins_with("192.168.") \
		or ip.begins_with("10.") \
		or ip.begins_with("172."):
			candidates.append(ip)
	if candidates.is_empty():
		return "127.0.0.1"

	return candidates[0]

func get_unused_session_id() -> int:
	var current_session_id = randi() & 0xFF
	while discovered_lan_hosts.has(current_session_id):
		current_session_id = randi() & 0xFF
	return current_session_id
