class_name InventoryContainer extends Control

@onready var inventories: Array[Inventory] = get_tree().get_nodes_in_group("inv") as Array[Inventory]
var item_held: Item = null

#------------------------------------------------------#
func _ready() -> void:
	pass
