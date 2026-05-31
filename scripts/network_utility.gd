class_name NetworkUtility
extends Node


var http_request : HTTPRequest
var public_ip: String = ""

func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

func get_public_ip() -> void:
	var error = http_request.request("http://icanhazip.com/")
	if error != OK:
		print("FAILED TO GET PUBLIC IP!")

func _on_request_completed(result:int, response_code:int, headers:PackedStringArray, body:PackedByteArray) -> void :
	print("RESULT: ", result)
	print("RESPONSE CODE: ", response_code)
	print("BODY:")
	print(body.get_string_from_utf8())
	if response_code != 200:
		print("FAILED TO GET PUBLIC IP!!")
		return
	print("SUCCESSFULLY GOT PUBLIC IP!")
	
	public_ip = body.get_string_from_utf8().strip_edges()

func get_cached_public_ip() -> String:
	return public_ip

func setup_upnp(port: int) -> bool:
	var upnp = UPNP.new()
	var discover_result = upnp.discover()
	if discover_result != UPNP.UPNP_RESULT_SUCCESS:
		print("UPNP Discover Failed")
		return false
	var gateway = upnp.get_gateway()
	if gateway == null:
		print("No gateway found")
		return false
	if not gateway.is_valid_gateway():
		print("Invalid gateway")
		return false
	var map_result = gateway.add_port_mapping(
		port,          # external port
		port,          # internal port
		"GodotGame",   # description
		"UDP"          # protocol
	)
	if map_result != UPNP.UPNP_RESULT_SUCCESS:
		print("Failed to map port")
		return false
	return true
