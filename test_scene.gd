extends Control
#NOTE: This scene is just for testing only it is not required for the inventory to function
#in order to make an invetory, simply add the node to your actual scene

@export var Grid_node: Inventory
@export var inv2: Inventory

#------------------------DEBUGGING-------------------------#
func _ready() -> void:
	_prep_itemList()

func _process(_delta: float) -> void:
	debugger_lebelA.text = str(Grid_node.item_held)
	debugger_lebelB.text = str(inv2.item_held)

#NOTE: remove this shit later
@onready var debugger_lebelA: Label = $"CanvasLayer/debug pannel/VBoxContainer/inv1_lbl"
@onready var debugger_lebelB: Label = $"CanvasLayer/debug pannel/VBoxContainer/inv2_lbl"
@onready var quantit: LineEdit = $"CanvasLayer/debug pannel/VBoxContainer/quantity"
func _on_debug_button_pressed() -> void:
	#var itemSize: Vector2i = Vector2i(int($"CanvasLayer/debug pannel/VBoxContainer/HBoxContainer/width".text), int($"CanvasLayer/debug pannel/VBoxContainer/HBoxContainer/height".text))
	var item_id: String = itemList.get_item_text(itemList.get_selected_id())
	var qt: int = 1 if quantit.text == "" else int(quantit.text)
	Grid_node.add_item(item_id, qt)

func _on_change_grid_size_pressed() -> void:
	var width: int = int($"CanvasLayer/debug pannel/VBoxContainer/HBoxContainer2/Gwidth".text)
	var height: int = int($"CanvasLayer/debug pannel/VBoxContainer/HBoxContainer2/Gheight".text)
	
	Grid_node.grid_height = height
	Grid_node.grid_width = width
	Grid_node.custom_minimum_size = Vector2i(Grid_node.cell_size * Grid_node.grid_width, Grid_node.cell_size * Grid_node.grid_height)

@onready var itemList: OptionButton = $"CanvasLayer/debug pannel/VBoxContainer/OptionButton"
func _prep_itemList() -> void:
	for ids in Grid_node.data.items:
		itemList.add_item(ids.name)
	
	itemList.add_item("null")

func _on_save_btn_pressed() -> void:
	Grid_node.save_items()

func _on_load_btn_pressed() -> void:
	Grid_node.load_items()

func _on_view_btn_pressed() -> void:
	print(Grid_node.load_from_file("res://saved_data.dat"))

func _on_restart_btn_pressed() -> void:
	get_tree().reload_current_scene()
