extends VBoxContainer

signal roll_die(num_of_die:int)

func _on_d_6_button_pressed() -> void:
	roll_die.emit(1)

func _on_2_d_6_button_pressed() -> void:
	roll_die.emit(2)

func _on_d_6_manual_button_pressed() -> void:
	GState.change_dice_to_roll.emit(1)

func _on_2_d_6_manual_button_pressed() -> void:
	GState.change_dice_to_roll.emit(2)
