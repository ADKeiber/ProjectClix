class_name ImportedFigureTable
extends VBoxContainer

const IMPORTED_FIGURE_ROW = preload("res://ui/imported_figure_row.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GState.import_team.connect(add_imported_figures)

func get_row_data() -> void:
	pass

func add_imported_figures(peer_id: int, figure_urls: Array[String], figure_types: Array[GameObject.Type]) -> void:
	if len(figure_urls) != len(figure_types):
		return
	for i in range(len(figure_urls)):
		var row: ImportedFigureRow = IMPORTED_FIGURE_ROW.instantiate()
		self.add_child(row)
		var numOfFigure: int = self.get_child_count(false) - 1
		var gameObject: GameObject = GState.get_object_from_url(figure_urls[i], figure_types[i])
		var cost: String
		if gameObject.has_method("get_point_values"):
			cost = ", ".join(gameObject.get_point_values().map(func(n): return str(n)))
		elif gameObject.has_method("get_point_value"):
			cost = str(gameObject.get_point_value())
		else:
			cost = "-"
		row.update_row(str(numOfFigure), GameObject.Type.keys()[figure_types[i]], gameObject.get_name(), gameObject.get_set_id(), cost, true)
	pass
