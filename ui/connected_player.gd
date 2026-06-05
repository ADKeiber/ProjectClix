class_name ConnectedPlayer
extends Control

@onready var username: Label = $HBoxContainer/Label
@onready var ready_box: CheckBox = $HBoxContainer/CheckBox

var text: String

func get_username() -> String:
	return username.text

func set_player_name(name:String) -> void:
	username.text = name

func set_ready(ready: bool) -> void:
	ready_box.button_pressed = ready
