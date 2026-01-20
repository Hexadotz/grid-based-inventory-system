#Grid-Based Inventory system by Hexadotz
@tool
class_name Inventory extends TextureRect

#NOTE: #if GridBase is a child of a container you need to use this to reference the container
#that control GridBBases's transform not doing so will cause the hover rect to be offseted
@export var onload: bool = false ##Loads the items from the save file
@export var Save_file_path: String = "res://saved_data.dat"##The path the inventory data will be saved to
@export var data: ItemDB ##The data resource of all the items in your game

@export_subgroup("Grid")
@export var cell_size: int = 32 ##The size of each individual cell
@export_range(1, 100, 1) var grid_height: int = 8 ##How many cells on the y axis
@export_range(1, 100, 1) var grid_width: int = 8 ##How many cells on the x axis
@export var hover_texture: Texture2D 

var hover_rect: TextureRect # the rect used to deterimn the mouse position and where the item will be placed

var item_held: Item = null # the item we're currently holding
var offset: Vector2 = Vector2.ZERO # used to keep offset from the center of the item to the mouse instead of snapping it
var mouse_pos: Vector2 = Vector2.ZERO 
var item_last_position: Vector2i = Vector2i.ZERO

var SAVED_ITEMS: Array[Dictionary] = []
var inventories: Array[Node] = []

@warning_ignore("unused_signal")
signal focus_grid_moved() ##Emitted when the mosue moves inside the inventory
@warning_ignore("unused_signal")
signal item_rotated() ##Emitted when the item is rotated
@warning_ignore("unused_signal")
signal item_swapped() ##Emitted when two items swap each other's places
#--------------------------------------------------#
func _enter_tree() -> void:
	add_to_group("grid_inventory")

func _ready() -> void:
	stretch_mode = TextureRect.STRETCH_TILE
	custom_minimum_size = Vector2i(cell_size * grid_height, cell_size * grid_width)
	
	# create the hover rect at scene startup to make the inventory more compact
	var hover_child: TextureRect = TextureRect.new()
	hover_child.texture = hover_texture
	hover_child.size = Vector2i(cell_size, cell_size)
	add_child(hover_child)
	hover_rect = hover_child
	
	if onload:
		load_items(Save_file_path)
	
	inventories = get_tree().get_nodes_in_group("grid_inventory")

func _process(_delta: float) -> void:
	custom_minimum_size = Vector2i(cell_size * grid_height, cell_size * grid_width)
	
	# don't bother with the logic and functionality if we aren't actually
	if not Engine.is_editor_hint():
		mouse_pos = get_global_mouse_position()
		_hover_mouse()
		
		if Input.is_action_just_pressed("mouse1"):
			if item_held == null:
				_grab()
			else:
				_release()
		
		if item_held != null:
			item_held.global_position = mouse_pos - item_held.size / 2

func _hover_mouse() -> void:
	if get_global_rect().has_point(mouse_pos):
		var resault_position: Vector2 = Vector2.ZERO
		var prev_position: Vector2 = hover_rect.position # we save the previous position to compare it with the new one later
		var snapper: Vector2 = Vector2.ZERO
		
		if null == item_held:
			snapper = ((mouse_pos - global_position) - (Vector2(cell_size, cell_size) / 2))
		else:
			snapper = (item_held.global_position - global_position)
		
		# snaps the hover rectangle to the grid that is closest to the mouse
		resault_position = snapper.snapped(Vector2(cell_size, cell_size))
		# prevent the hover rect from leaving the inventory space
		hover_rect.position = resault_position.clamp(Vector2.ZERO, size)
		
		#NOTE: remove this if you don't want to keep tracking if the mouse if moving inside the inventory
		if resault_position != prev_position:
			emit_signal("focus_grid_moved")

##Returns the item resource from the given id, returns the error item if not found
func get_item(item_id: String) -> ItemData:
	for item in data.items:
		if item.name == item_id:
			return item
	
	var error_item: ItemData = ItemData.new()
	error_item.name = "error"
	error_item.icon = load("uid://b1s5lq76hs3e0")
	printerr("item: ", item_id, " is not found!")
	return error_item

#---------------------item handeling----------------------#
##Adds and item using it's id, returns true if the item been added otherwise false
func add_item(itemId: String = "", quantity: int = 1) -> bool:
	# spawn the item in an empty place
	var rect: Rect2i = get_global_rect()
	#NOTE: var item_data: Dictionary = ItemsDB.get_item(itemId)
	var item_data: ItemData = get_item(itemId)
	# loop through evrey cell in the inventory
	for line in range(rect.position.y, rect.end.y, cell_size):
		for column in range(rect.position.x, rect.end.x, cell_size):
			
			var place_point: Vector2i = Vector2i(column, line) # the location we're going to place the item at
			var area: Rect2 = Rect2(Vector2i(place_point), Vector2i(item_data.grid_size * cell_size)) # construct a bounding box from the item id to use
			
			# if the item we're adding is stackable and is already in the inventory just add to the quantity
			if item_data.stackable:
				for itm: Item in get_items():
					if itm.item_data.name == itemId:
						if itm.quantity < item_data.max_quantity:
							itm.quantity += quantity
							return true
				
			if area_is_clear(area, [item_held]):
				var item_instance: Item = Item.new()
				add_child(item_instance)
				var qty = quantity if item_data.stackable else 1
				item_instance.prep_item(item_data, qty)
				item_instance.global_position = place_point
				
				return true # gtfo once done
	
	printerr("Could not place item, inventory full")
	return false # in case of a fuck up or the inventory is full

func _clear_inventory() -> void:
	for child in get_children():
		if child == hover_rect:
			continue
		child.queue_free()

func _grab() -> void:
	# if we have an item already picked up, don't bother
	if item_held != null:
		return
	
	if not location_is_clear(mouse_pos) and get_global_rect().has_point(mouse_pos):
		for cell: Item in get_items():
			if cell.get_global_rect().has_point(mouse_pos):
				item_held = cell
				offset = cell.global_position - mouse_pos
				move_child(item_held, get_child_count()) # display the item on top of the other items
				item_last_position = cell.global_position
				item_held.item_picked.emit()
				return
				

func _release() -> void:
	if item_held == null:
		return
	
	var area: Rect2 = Rect2(hover_rect.global_position , item_held.get_global_rect().size)
	# for stackable item, go throught every item in the inventory if the item we're releasing it on 
	# is the same type as the one currently holding and is stackable then add it to the quantity
	for itm in get_items():
		if itm != item_held and itm.stackable:
			if itm.get_global_rect().intersects(area) and itm.item_data.name == item_held.item_data.name:
				itm.quantity += item_held.quantity
				# remove the item from the grid after adding its quantity
				item_held.queue_free()
				
				item_held.item_placed.emit()
				item_held = null
				return
	
	# if the placement is invalid
	if not _is_a_valid_spot(area):
		item_held.global_position = item_last_position
		item_last_position = Vector2i.ZERO
		
		item_held.item_placed.emit()
		item_held = null
		return
	
	for inv in inventories:
		if inv.get_global_rect().has_point(mouse_pos):
			area = Rect2(inv.hover_rect.global_position , item_held.get_global_rect().size)
			if inv.area_is_clear(area, [item_held]):
				item_held.reparent(inv)
				item_held.global_position = inv.hover_rect.global_position
				offset = Vector2.ZERO
				item_held.item_placed.emit()
				item_held = null
				
			#NOTE: update it to support multiple inventories
			#else:
			#	_swap()

#func _no_item_held() -> bool:
	#for inv: Inventory in inventories:
		#if inv.item_held != null:
			#return false
	#return true

func _is_a_valid_spot(area: Rect2) -> bool:
	for inv: Inventory in inventories:
		if inv.get_global_rect().has_point(mouse_pos) or inv.is_inside_rect(area):
			return true
	return false

func _swap() -> void:
	var occupied: Array = []
	for cell: Item in get_items():
		if cell == item_held:
			continue
		if cell.get_global_rect().intersects(item_held.get_global_rect()):
			occupied.append(cell)
	
	var zone: Rect2 = Rect2(occupied[0].global_position, item_held.size)
	if occupied.size() != 1 or not area_is_clear(zone, [item_held, occupied[0]]):
		item_held.global_position = item_last_position
		item_last_position = Vector2i.ZERO
		
		item_held.item_placed.emit()
		item_held = null
		return
	
	item_held.global_position = hover_rect.global_position
	item_held = occupied[0]
	
	move_child(item_held, get_child_count())
	emit_signal("item_swapped")

#-------------------------------SAVING/LOADING---------------------------------------#
func save_items(file_path: String) -> void:
	SAVED_ITEMS.clear()
	
	for item: Item in get_items():
		#NOTE: 
		var save_data: Dictionary = {
			"name": item.item_data.name,
			"pos": item.position,
			"qty": item.quantity,
			"rotated": item.is_rotated
		}
		SAVED_ITEMS.append(save_data)
	
	print(SAVED_ITEMS)
	
	# save to the file after that's done
	if SAVED_ITEMS.is_empty():
		printerr("Nothing to save!")
		return
	
	var FILE: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	FILE.store_var(SAVED_ITEMS)
	print_rich("[color=green]Items saved![/color]")
	FILE.close()

func load_items(file_path: String) -> void:
	# clear out previous items
	_clear_inventory()
	
	# get the items from the file
	if not FileAccess.file_exists(file_path):
		printerr("No file found!")
	
	var FILE: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	SAVED_ITEMS = FILE.get_var()
	FILE.close()
	
	for item in SAVED_ITEMS:
		var item_instance: Item = Item.new()
		add_child(item_instance)
		
		var item_data: ItemData = get_item(item["name"])
		item_instance.prep_item(item_data)
		
		item_instance.position = item["pos"]
		item_instance.quantity = item["qty"]
		
		if item["rotated"]:
			item_instance.rotate()

	
#---------------------------------------------------------#
##Returns the amount of items that are on top of the current held item
func items_in_zone() -> int:
	var count: int = 0
	for cell: Item in get_items():
		if cell == item_held:
			continue
		if cell.get_global_rect().intersects(item_held.get_global_rect()):
			count += 1
	
	return count

#Checks if the area we're placing the item at isvalid (not outside the grid or on top another item)
func area_is_clear(zone: Rect2, execlude: Array) -> bool:
	# check if it's on top of another item
	for cell: Item in get_items():
		if cell not in execlude:
			if cell.get_global_rect().intersects(zone):
				return false
	
	return is_inside_rect(zone)

##Checks if the given zone if fully inside
func is_inside_rect(zone: Rect2) -> bool:
	# if the top left and the bottom right corners are inside the zone, then it's valid otherwise it's not valid
	if not get_global_rect().has_point(zone.position) or not get_global_rect().has_point(zone.end - Vector2(1,1)):
		return false
	return true

##Checks if the position given is clear or not
func location_is_clear(pos: Vector2) -> bool:
	for cell: Item in get_items():
		if cell != item_held:
			if cell.get_global_rect().has_point(pos):
				return false
	return true

##Returns a list of all the items that are in the inventory, NOTE: the reason why we use the slice is because we don't want the
##hover rect to be counted as an item
func get_items() -> Array:
	return get_children().slice(1, get_children().size())
