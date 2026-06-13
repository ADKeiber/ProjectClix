class_name DiceManager
extends Node3D

signal start_roll(die, num_of_dice) #die == inital die pickup and num_of_dice determines if its just that die or others too
signal end_roll
var all_dice: Array[Die]
var dice_rolling: Array[Die]
var rolling: bool = false
var num_of_dice_to_roll: int

func _ready() -> void:
	for child in get_children():
		all_dice.append(child)
	start_roll.connect(pickup_dice)
	end_roll.connect(drop_dice)
	GState.change_dice_to_roll.connect(set_die_to_roll)
	

func random_roll(num_of_dice: int) -> void:
	for i in range(num_of_dice):
		all_dice[i].random_roll()

func pickup_dice(die: Die, num_of_dice: int) -> void:
	var num_of_dice_picked_up: int = 0
	for child in get_children():
		if child == die:
			dice_rolling.append(child)
			num_of_dice_picked_up += 1
	for child in get_children():
		if not child == die and num_of_dice_picked_up < num_of_dice:
			num_of_dice_picked_up += 1
			#child.MAX_Z = child.MAX_Z - child.offset.z TODO REVIST so unselected dice remain inside 
			#child.MAX_X = child.MAX_X - child.offset.x
			dice_rolling.append(child)
	for die_rolling in dice_rolling:
		die_rolling.start_drag(die_rolling == die, die.global_position)

func drop_dice() -> void:
	for die_rolling in dice_rolling:
		die_rolling.end_drag()
	dice_rolling.clear()

func set_die_to_roll(dice: int) -> void:
	num_of_dice_to_roll = dice
