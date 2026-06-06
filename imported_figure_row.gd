class_name ImportedFigureRow
extends HBoxContainer
@onready var number_label: Label = %NumberLabel
@onready var object_type_label: Label = %ObjectTypeLabel
@onready var set_number_label: Label = %SetNumberLabel
@onready var object_name_label: Label = %ObjectNameLabel
@onready var cost_label: Label = %CostLabel
@onready var delete_button: Button = %DeleteButton

func update_row(number: String, objectType: String, setNumber: String, objectName: String, cost: String, enableDelete: bool) -> void:
	number_label.text = number
	object_type_label.text = objectType
	set_number_label.text = setNumber
	object_name_label.text = objectName
	cost_label.text = cost
	delete_button.visible = enableDelete

func _on_delete_button_pressed() -> void:
	var player: Player = GState.players[GState.my_peer_id()]
	var index := -1

	for i in player.gameObjectUrls.size():
		if player.gameObjectUrls[i].contains(number_label.text):
			index = i
	player.gameObjectUrls.remove_at(index)
	player.gameObjectTypes.remove_at(index)
	queue_free()
	print("Removed imported game object")
