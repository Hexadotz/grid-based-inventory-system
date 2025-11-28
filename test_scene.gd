extends Control
#NOTE: This scene is just for testing only it is not required for the inventory to function
#in order to make an invetory, simply add the node to your actual scene
@export var grid: Inventory
#NOTE: remove this shit later, 
#NOTE: revised 2025-11-17, this shit is relevant for debugging 
@onready var debugger_label: Label = %DebuggerLabel
@onready var quantity: QuantityPicker = %Quantity
@onready var grid_width_le: LineEdit = %GridWidth
@onready var grid_height_le: LineEdit = %GridHeight
@onready var item_list: OptionButton = %ItemOptionDropdown

#------------------------DEBUGGING-------------------------#
func _ready() -> void:
	_prep_itemList()

func _process(_delta: float) -> void:
	debugger_label.text = str(grid.item_held)


func _on_add_item_button_pressed() -> void:
	var selected_item = item_list.get_selected_id()
	var item_id: String = item_list.get_item_text(selected_item)
	var qt: int = quantity.value
	grid.add_item(item_id, qt)

func _on_change_grid_size_pressed() -> void:
	var width: int = int(grid_width_le.text)
	var height: int = int(grid_height_le.text)
	
	grid.grid_height = height
	grid.grid_width = width
	grid.custom_minimum_size = Vector2i(grid.cell_size * grid.grid_width, grid.cell_size * grid.grid_height)

func _prep_itemList() -> void:
	for ids in grid.data.items:
		item_list.add_item(ids.name)
	
	item_list.add_item("null")

func _on_save_btn_pressed() -> void:
	grid.save_items()

func _on_load_btn_pressed() -> void:
	grid.load_items()

func _on_view_btn_pressed() -> void:
	print(grid.load_from_file("res://saved_data.dat"))

func _on_restart_btn_pressed() -> void:
	get_tree().reload_current_scene()
