class_name GameObjectImport
extends HBoxContainer

@onready var player_name_input: LineEdit = %PlayerNameInput
@onready var figure_url_label: Label = $MarginContainer/FigureUrlLabel
@onready var option_button: OptionButton = $MarginContainer2/OptionButton

var current_text: String = ""

func _ready() -> void:
	current_text = option_button.get_item_text(0)

func get_url() -> String:
	return player_name_input.text

func get_type() -> GameObject.Type:
	var clean_string = current_text.replace(" ", "_").to_upper()
	return GameObject.Type.get(clean_string)

func set_field_name(num: int) -> void:
	figure_url_label.text = str(num)
	
func _on_option_button_item_selected(index: int) -> void:
	current_text = option_button.get_item_text(index)
	print(current_text)
