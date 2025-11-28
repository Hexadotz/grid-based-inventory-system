extends LineEdit

var value:int = 1

func _ready() -> void:
	self.text_submitted.connect(_on_text_submitted)
	self.focus_exited.connect(_on_focus_exited)
	_update_text(value)

func _on_focus_exited(): 
	var new_text = self.text
	_on_text_submitted(new_text)

func _on_text_submitted(new_text:String)->void: 
	var regex := RegEx.new()
	regex.compile("[^0-9]") # match anything that is not 0–9
	var filtered:String = regex.sub(new_text, "", true)
	value = clamp(int(filtered), 1, 99)
	_update_text(value)

func _update_text(new_value:int)->void: 
	self.text = "{0}".format([new_value])
