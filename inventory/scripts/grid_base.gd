class_name Inventory extends TextureRect

#NOTE: #if GridBase is a child of a container you need to use this to reference the container
#that control GridBBases's transform not doing so will cause the hover rect to be offseted

@export_subgroup("Grid")
@export var cell_size: int = 32
@export_range(1, 100, 1) var grid_height: int = 4
@export_range(1, 100, 1) var grid_width: int = 4

@export_subgroup("sounds")
@export var mouse_moved: AudioStreamMP3
@export var item_selected: AudioStreamMP3

@onready var itemBase: PackedScene = preload("res://inventory/item_base.tscn")
@onready var hover_rect: TextureRect = $HoverRect

var item_held: Item = null
var offset: Vector2 = Vector2.ZERO
var mouse_pos: Vector2 = Vector2.ZERO
var item_last_position: Vector2i = Vector2i.ZERO

var item_list: Array[Item] = []

signal focus_grid_moved()
signal item_rotated()
signal item_swapped()

#TODO: fix this retarded pixel offset, the reason the hover rect get's offseted is because the position of the grid
#intervene with the way it moves
#--------------------------------------------------#
func _ready() -> void:
	stretch_mode = TextureRect.STRETCH_TILE
	hover_rect.size = Vector2i(cell_size, cell_size)
	
	custom_minimum_size = Vector2i(cell_size * grid_height, cell_size * grid_width)
	_prep_itemList()
	
	await get_tree().create_timer(1).timeout
	add_item("wep_grenad")

func _physics_process(_delta: float) -> void:
	mouse_pos = get_global_mouse_position()
	_hover_mouse()
	
	debugger_lebel.text = str(item_held)
	
	if Input.is_action_just_pressed("rotate") and item_held == null:
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("mouse1"):
		if item_held == null:
			_grab()
		else:
			_release()
	
	if item_held != null:
		item_held.global_position = mouse_pos + offset
		
		var zone: Rect2 = Rect2(hover_rect.global_position , item_held.get_global_rect().size)
		if area_is_clear(zone, [item_held]):
			item_held.shadow.color = item_held.VALID_SPOT
		else:
			# the shadow color will be orange if there is only one item in the zone otherwise it will be red 
			item_held.shadow.color = item_held.SWITCH_SPOT if items_in_zone() == 1 else item_held.OCCUPIED_SPOT 
		
		# rotate the item
		if Input.is_action_just_pressed("rotate"):
			item_held.rotate()

var prev_position: Vector2 = Vector2.ZERO
func _hover_mouse() -> void:
	if is_on_grid(mouse_pos):
		var resault_position: Vector2 = Vector2.ZERO
		
		prev_position = hover_rect.position
		
		if item_held == null:
			var steps: Vector2i = (mouse_pos - global_position) / cell_size
			resault_position = (steps * cell_size)
		else:
			var steps2: Vector2i = (item_held.global_position - global_position) / cell_size
			resault_position = (steps2 * cell_size) 
		
		hover_rect.position = resault_position
		
		if resault_position != prev_position:
			emit_signal("focus_grid_moved")

#---------------------item handeling----------------------#
func add_item(itemId: String = "", quantity: int = 1) -> void:
	# spawn the item in an empty place
	for line in range(global_position.y, global_position.y + (cell_size * grid_width), cell_size):
		for column in range(global_position.x, global_position.x + (cell_size * grid_height), cell_size):
			
			var place_point: Vector2i = Vector2i(column, line)
			# check if the location we're putting in is valid
			var dick: Dictionary = ItemsDB.get_item(itemId)
			var area: Rect2 = Rect2(Vector2i(place_point), Vector2i(dick.grid_size * cell_size))
			
			if dick.stackble:
				for itm in item_list:
					if itm.item_id == itemId:
						itm.quantity += quantity
						return
			
			if area_is_clear(area, [item_held]):
				var item_instance: Item = itemBase.instantiate()
				add_child(item_instance)
				item_instance.prep_item(itemId)
				item_instance.global_position = place_point
				item_list.append(item_instance)
				return # gtfo once done

func _grab() -> void:
	# if we have an item already pickeed up, don't bother
	if item_held != null:
		return
	
	if not location_is_clear(mouse_pos) and is_on_grid(mouse_pos):
		for cell: Item in item_list:
			if cell.get_global_rect().has_point(mouse_pos):
				item_held = cell
				offset = cell.global_position - mouse_pos
				move_child(item_held, get_child_count()) # display the item on top of the other items
				item_last_position = cell.global_position
				

func _release() -> void:
	if item_held == null:
		return
	
	var area: Rect2 = Rect2(hover_rect.global_position , item_held.get_global_rect().size)
	#for loops, so many for loops...
	for itm in item_list:
		if itm != item_held:
			if itm.get_global_rect().intersects(area) and itm.item_id == item_held.item_id:
				itm.quantity += item_held.quantity
				item_list.erase(item_held)
				item_held.queue_free()
				item_held = null
				return
	
	if not is_on_grid(mouse_pos) or not is_inside_rect(area):
		item_held.global_position = item_last_position
		item_last_position = Vector2i.ZERO
		item_held = null
	else:
		if area_is_clear(area, [item_held]):
			item_held.global_position = hover_rect.global_position
			offset = Vector2.ZERO
			item_held = null
		else:
			_swap()

@onready var debugger_lebel: Label = $"CanvasLayer/debug pannel/PrintLabel"
#i fucking hate this
func _swap() -> void:
	var occupied: Array = []
	for cell: Item in item_list:
		if cell == item_held:
			continue
		if cell.get_global_rect().intersects(item_held.get_global_rect()):
			occupied.append(cell)
	
	var zone: Rect2 = Rect2(occupied[0].global_position, item_held.size)
	if occupied.size() != 1 or not area_is_clear(zone, [item_held, occupied[0]]):
		item_held.global_position = item_last_position
		item_last_position = Vector2i.ZERO
		item_held = null
		return
	
	item_held.global_position = hover_rect.global_position
	item_held = occupied[0]
	
	move_child(item_held, get_child_count())
	emit_signal("item_swapped")

#---------------------------------------------------------#
func is_on_grid(location: Vector2) -> bool:
	return true if get_global_rect().has_point(location) else false

func items_in_zone() -> int:
	var count: int = 0
	for cell: Item in item_list:
		if cell == item_held:
			continue
		if cell.get_global_rect().intersects(item_held.get_global_rect()):
			count += 1
	
	return count

# checks if the area we're placing the item at isvalid (not outside the grid or on top another item)
func area_is_clear(zone: Rect2, execlude: Array) -> bool:
	# check if it's on top of another item
	for cell: Item in item_list:
		if cell not in execlude:
			if cell.get_global_rect().intersects(zone):
				return false
	
	return is_inside_rect(zone)

func is_inside_rect(zone: Rect2) -> bool:
	# then checks if it's fully inside the grid
	if not is_on_grid(zone.position + Vector2(1, 1)) or not is_on_grid(zone.end - Vector2(1,1)):
		return false
	return true

func location_is_clear(pos: Vector2) -> bool:
	for cell: Item in item_list:
		if cell != item_held:
			if cell.get_global_rect().has_point(pos):
				return false
	return true

#------------------------DEBUGGING-------------------------#
#NOTE: remove this shit later
@onready var quantit: LineEdit = $"CanvasLayer/debug pannel/VBoxContainer/quantity"
func _on_debug_button_pressed() -> void:
	#var itemSize: Vector2i = Vector2i(int($"CanvasLayer/debug pannel/VBoxContainer/HBoxContainer/width".text), int($"CanvasLayer/debug pannel/VBoxContainer/HBoxContainer/height".text))
	var item_id: String = itemList.get_item_text(itemList.get_selected_id())
	var qt: int = 1 if quantit.text == "" else int(quantit.text)
	add_item(item_id, qt)

func _on_change_grid_size_pressed() -> void:
	var width: int = int($"CanvasLayer/debug pannel/VBoxContainer2/HBoxContainer/Gwidth".text)
	var height: int = int($"CanvasLayer/debug pannel/VBoxContainer2/HBoxContainer/Gheight".text)
	
	grid_height = height
	grid_width = width
	custom_minimum_size = Vector2i(cell_size * grid_height, cell_size * grid_width)

@onready var itemList: OptionButton = $"CanvasLayer/debug pannel/VBoxContainer/OptionButton"
func _prep_itemList() -> void:
	for ids in ItemsDB.ITEMS.keys():
		itemList.add_item(ids)
	
	itemList.add_item("null")

func _on_focus_grid_moved() -> void:
	print("penis")

func _on_item_rotated() -> void:
	print("rotated")

func _on_item_swapped() -> void:
	print("swapped")
