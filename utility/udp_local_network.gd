extends Node

const DISCOVERY_PORT := 8911

var udp := PacketPeerUDP.new()
var timer := Timer.new()

var game_port := 51683
var session_id := 12345


func _ready():
	add_child(timer)

	timer.wait_time = 1.0
	timer.timeout.connect(_broadcast_server)
	timer.start()

	udp.set_broadcast_enabled(true)


func _broadcast_server():
	var local_ip = get_local_ipv4()

	var message = {
		"type": "game_host",
		"session_id": session_id,
		"ip": local_ip,
		"port": game_port
	}

	var packet = JSON.stringify(message).to_utf8_buffer()

	udp.set_dest_address("255.255.255.255", DISCOVERY_PORT)
	udp.put_packet(packet)


func get_local_ipv4() -> String:
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") \
		or ip.begins_with("10.") \
		or ip.begins_with("172."):
			return ip

	return "127.0.0.1"
