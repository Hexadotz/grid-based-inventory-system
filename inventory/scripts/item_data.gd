@tool
class_name ItemData extends Resource

@export var name: String = "" ##The name of the item that will be used later to find it, MAKE SURE IT'S UNIQUE
@export var icon: CompressedTexture2D ##The icon that will be displayed on the inventory
@export var grid_size: Vector2i = Vector2i.ONE ##The size of the item on the grid, in integers
@export var stackable: bool: ##Wether the item could be stacked or not
	set(value):
			stackable = value
			notify_property_list_changed()

@export var max_quantity: int = 1 ##The max quantity before needing to create another stack of the item

# gray out the max size option if the item isn't stackable for the sake of user friendly
func _validate_property(property: Dictionary):
	if property.name == "max_quantity" and not stackable: 
		property.usage |= PROPERTY_USAGE_READ_ONLY
