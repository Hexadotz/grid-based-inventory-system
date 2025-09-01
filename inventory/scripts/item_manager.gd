extends Node
# This script is used for you items funtionality, when an item is used it emits a signal, which this script
# picks up and then do the logic neccessary
# NOTE: this is not the definitive way to do it, i'm sure there are better methods to achieve the same
# resault you are not tied to this


@warning_ignore("unused_signal")
signal item_used(id: String, qty: int) ##A signal that is emitted once an item is used

func medkit_used() -> void:
	print("Medkit used")

@warning_ignore("unused_parameter")
func _on_item_used(item: ItemData, qty: int) -> void:
	if item.name == "con_medkit":
		medkit_used()
	
	print(item.name, " is used!")
