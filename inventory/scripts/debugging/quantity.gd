extends LineEdit
class_name QuantityPicker

#NOTE: Default quantity is 1
var value:int = 1

func _ready(): 
	_update_text(value)

func _on_decrease_quantity_pressed() -> void:
	value = clampi(value - 1, 0, 99)
	_update_text(value)

func _on_increase_quantity_pressed() -> void:
	value = clampi(value + 1, 0, 99)
	_update_text(value)

func _update_text(new_value:int)->void: 
	self.text = "{0}".format([new_value])
