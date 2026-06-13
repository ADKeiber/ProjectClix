class_name Die
extends RigidBody3D


var dragging: bool = false
var previous_position: Vector3
var velocity: Vector3
var MIN_X: float
var MIN_Z: float
var MAX_X: float
var MAX_Z: float
var offset:Vector3 = Vector3(0.04, 0.00, 0.00)
var picked_die: bool = false
var previous_global_postion: Vector3
var at_rest: bool = false
var thrown: bool = false
var has_started_rolling: bool = false

func _ready() -> void:
	previous_global_postion = global_position
	linear_velocity
	var tray = get_parent().get_parent()
	MIN_X = tray.MIN_X
	MIN_Z = tray.MIN_Z
	MAX_X = tray.MAX_X
	MAX_Z = tray.MAX_Z

func _physics_process(delta):
	if dragging:
		velocity = (global_position - previous_position) / delta
	at_rest = (
		linear_velocity.length() < 0.01
		and angular_velocity.length() < 0.01
	)
	if thrown and not has_started_rolling:
		if (
			linear_velocity.length() > 0.01
			or angular_velocity.length() > 0.01
		):
			has_started_rolling = true

	if thrown and has_started_rolling and at_rest:
		thrown = false
		has_started_rolling = false

		print("Finished")
		print(get_face_value())


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			get_parent().start_roll.emit(self,get_parent().num_of_dice_to_roll)

func _input(event: InputEvent) -> void:
	# Handle release anywhere on screen
	if event is InputEventMouseButton:
		if not event.pressed and dragging:
			get_parent().end_roll.emit()
	# Handle dragging
	if dragging and freeze:
		previous_position = global_position
		var pos: Vector3 = convert_mouse_position_to_3D_space(event.position)
		pos.x = clamp(pos.x, MIN_X, MAX_X)
		pos.z = clamp(pos.z, MIN_Z, MAX_Z)
		if not picked_die:
			global_position = Vector3(pos.x, global_position.y, pos.z) + offset
		else:
			global_position = Vector3(pos.x, global_position.y, pos.z)
		#print(global_position)

func convert_mouse_position_to_3D_space(mouse_position: Vector2) -> Vector3:
	var camera = get_viewport().get_camera_3d()
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_direction = camera.project_ray_normal(mouse_position)
	# Find where the ray hits y = 0
	var distance = -ray_origin.y / ray_direction.y
	return ray_origin + ray_direction * distance

func random_torque(middle_removed: float, bounds: float) -> float:
	var value = randf_range(bounds * -1, bounds)
	while abs(value) < middle_removed:
		value = randf_range(bounds * -1, bounds)
	return value

func random_roll() -> void:
	freeze = false
	# Lift the die off the felt a bit.
	global_position.y += 0.03
	# If we're in the bottom half, throw north.
	# If we're in the top half, throw south.
	var z_direction := -1.0 if global_position.z > 0.0 else 1.0
	var x_direction := -1.0 if global_position.x > 0.0 else 1.0
	var impulse := Vector3(
		abs(random_torque(0.01, .075)) * x_direction,
		.125,
		abs(random_torque(0.01, .075)) * z_direction
	)
	var torque := Vector3(
		random_torque(2, 4.0),
		random_torque(2, 4.0),
		random_torque(2, 4.0)
	)
	#print(impulse)
	#print(torque)
	apply_impulse(impulse)
	apply_torque_impulse(torque)

func start_drag(is_primary_die: bool, clicked_die_location: Vector3) -> void:
	print("Dragging")
	dragging = true
	freeze = true
	picked_die = is_primary_die
	thrown = false
	if not picked_die:
		global_position = Vector3(clicked_die_location.x, 0.05, clicked_die_location.z) + offset
	else:
		global_position = Vector3(clicked_die_location.x, 0.05, clicked_die_location.z)

func end_drag() -> void:
	print("Stopped Dragging")
	dragging = false
	freeze = false
	thrown = true
	has_started_rolling = false
	#print("Velocity: %s" % velocity)
	apply_impulse(velocity * 0.075)
	var torque: Vector3 = Vector3(
			random_torque(.2, 3),
			random_torque(.2, 3),
			random_torque(.2, 3)
		) * velocity.length()
	#print("Torque: %s" % torque)
	apply_torque_impulse(torque)

func get_face_value() -> int:
	var highest_face: int = 1
	var highest_y: float = $Face1.global_position.y
	for i in range(2, 7):
		var face: Node3D = get_node("Face%d" % i)
		if face.global_position.y > highest_y:
			highest_y = face.global_position.y
			highest_face = i
	return highest_face
