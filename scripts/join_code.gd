class_name JoinCode
extends RefCounted

#####################
## JOIN CODE ENCODING
#####################

const BASE62 := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
const SECRET_KEY : int = 0x5A3F29C1

static func generate_join_code(ip: String, port: int, session_id: int) -> String:
	var octets = ip.split(".")

	if octets.size() != 4:
		printerr("Invalid IP")
		return ""
	if port < 1 or port > 65535:
		printerr("Invalid Port")
		return ""
	var values: Array[int] = []

	for octet in octets:
		var value = int(octet)
		if value < 0 or value > 255:
			printerr("Invalid IP")
			return ""
		values.append(value)

	var ip_int : int = 0

	ip_int |= values[0] << 24
	ip_int |= values[1] << 16
	ip_int |= values[2] << 8
	ip_int |= values[3]
	
	var encoded_ip : int = ip_int ^ SECRET_KEY
	var version : int = 1

	# Layout:
	# [version:8]
	# [session_id:8]
	# [port:16]
	# [encoded_ip:32]
	#
	# TOTAL = 64 bits

	var payload : int = 0

	payload |= version << 56
	payload |= session_id << 48
	payload |= port << 32
	payload |= encoded_ip

	return int_to_base62(payload)

static func int_to_base62(value: int) -> String:
	if value == 0:
		return "0"

	var result := ""
	var current = value

	while current > 0:
		var remainder = current % 62
		result = BASE62[remainder] + result
		current = int(current / 62)

	return result

#####################
## JOIN CODE DECODING
#####################

static func decode_join_code(code: String) -> Dictionary:
	if code.is_empty():
		return { "success": false }
	
	var payload : int = base62_to_int(code)
	if payload == -1:
		return { "success": false }
		
	var version : int = (payload >> 56) & 0xFF

	var session_id : int = (payload >> 48) & 0xFF

	var port : int = (payload >> 32) & 0xFFFF

	var encoded_ip : int = payload & 0xFFFFFFFF

	var ip_int : int = encoded_ip ^ SECRET_KEY

	var ip = "%d.%d.%d.%d" % [
		(ip_int >> 24) & 0xFF,
		(ip_int >> 16) & 0xFF,
		(ip_int >> 8) & 0xFF,
		ip_int & 0xFF
	]

	return {
		"success": true,
		"version": version,
		"session_id": session_id,
		"port": port,
		"ip": ip
	}

static func base62_to_int(text: String) -> int:
	var value : int = 0
	for c in text:
		var index = BASE62.find(c)
		if index == -1:
			printerr("Invalid Base62 character")
			return -1
		value = value * 62 + index
	return value
