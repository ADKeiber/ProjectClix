class_name DiceTray
extends Node3D

@export var MIN_X: float
@export var MIN_Z: float
@export var MAX_X: float
@export var MAX_Z: float

@onready var roll_buttons: VBoxContainer = %RollButtons
@onready var dice_manager: Node3D = %DiceManager
var dice_to_roll: int = 2

func _ready() -> void:
	roll_buttons.roll_die.connect(roll_dice)

func roll_dice(num_dice_to_roll: int) -> void:
	dice_manager.random_roll(num_dice_to_roll)
