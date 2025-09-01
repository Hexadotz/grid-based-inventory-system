class_name Item extends TextureRect

@onready var grid_map: Inventory = get_parent()

var actionList: MenuButton 
var grid_space: ColorRect 
var countLabel: Label
var shadow: ColorRect 

var cur_size: Vector2 = Vector2.ZERO
var is_rotated: bool = false
var stackable: bool = false
var itemData: ItemData
var quantity: int = 1

var last_position: Vector2 = Vector2.ZERO
var ass = []

const VALID_SPOT: Color = Color(0.45, 1, 0, 0.3) # The color for valid placement of items
const OCCUPIED_SPOT: Color = Color(1, 0, 0, 0.3) # the color of occupied areas
const SWITCH_SPOT: Color = Color(1, 0.68, 0, 0.3) # thr color when the area is occupied by other items

signal item_picked(item_ref: Item)
signal item_placed(item_ref: Item)
#----------------------------------------------------------#
func _ready() -> void:
	_prepare_item()
	countLabel.visible = false
	shadow.visible = false
	ass = grid_map.inventories
	
	item_picked.connect(_on_item_picked)
	item_placed.connect(_on_item_placed)
	
	# making sure the signal isn't connected to stop godot from bitching
	if not ItemManager.is_connected("item_used", Callable(ItemManager, "_on_item_used")):
		ItemManager.connect("item_used", Callable(ItemManager, "_on_item_used"))

func _prepare_item() -> void:
	set_expand_mode(TextureRect.EXPAND_IGNORE_SIZE)
	z_index = 1
	
	var menubtn_inst: MenuButton = MenuButton.new()
	add_child(menubtn_inst)
	actionList = menubtn_inst
	
	var lbl_inst: Label = Label.new()
	add_child(lbl_inst)
	countLabel = lbl_inst
	countLabel.z_index = 2
	
	var colorRect_inst: ColorRect = ColorRect.new()
	add_child(colorRect_inst)
	grid_space = colorRect_inst
	grid_space.show_behind_parent = true
	grid_space.color = Color(1.0, 1.0, 1.0, 0.263)
	
	var shadowRect_inst: ColorRect = ColorRect.new()
	add_child(shadowRect_inst)
	shadow = shadowRect_inst
	shadow.top_level = true
	shadow.show_behind_parent = true

func get_current_inventory(mouse_pos: Vector2) -> Inventory:
	for inv: Inventory in ass:
		if inv.get_global_rect().has_point(mouse_pos):
			return inv
	return

func _process(_delta: float) -> void:
	var zone: Rect2 = Rect2(grid_map.hover_rect.global_position, size)
	
	var cur_inv: Inventory = get_current_inventory(grid_map.mouse_pos)
	if cur_inv != null:
		#if cur_inv.area_is_clear(zone, [self]):
		shadow.global_position = cur_inv.hover_rect.global_position
	
	if stackable:
		countLabel.text = "X" + str(quantity)
	
	if shadow.visible == true:
		# change the color depending on the placement: 
			#	orange means it will swap the place with the item hovering over it
			#	red means it cannont be placed because it's either outside of the zone or overlapping with multiple items
			#	green means it's a valid spot
		if grid_map._is_a_valid_spot(zone):
			shadow.color = VALID_SPOT
		else:
			if not grid_map.area_is_clear(zone, [self]):
				shadow.color = OCCUPIED_SPOT 
			# the shadow color will be orange if there is only one item in the zone otherwise it will be red 
			#shadow.color = SWITCH_SPOT if grid_map.items_in_zone() == 1 else OCCUPIED_SPOT 
		
		if Input.is_action_just_pressed("rotate"):
			rotate()

func prep_item(item_data: ItemData) -> void:
	#var item_property: Dictionary = ItemsDB.get_item(itemId) # get the item id from teh autoload and use it's data to configure teh item
	cur_size = item_data.grid_size * grid_map.cell_size
	
	itemData = item_data
	
	texture = item_data.icon #NOTE: you may get an error here if you don't give the item an image in the items_db.gd autoload
	size = cur_size
	
	shadow.size = cur_size
	grid_space.size = cur_size
	actionList.size = cur_size
	
	stackable = item_data.stackable
	
	var actionPopUp: PopupMenu = actionList.get_popup()
	actionPopUp.add_item("Use", 0)
	
	# if the item can be stacked, then show the amount label (Item_count) and put the number there
	if stackable:
		actionPopUp.add_item("Split", 1)
		countLabel.visible = true
		countLabel.text = "X" + str(quantity)
	
	actionPopUp.add_item("Drop", 2)
	actionPopUp.id_pressed.connect(_on_menu_pressed)

# rotates the object by fliping the extents (width and height)
func rotate() -> void:
	# flips the size of the item so it "rotates"
	cur_size = Vector2(cur_size.y, cur_size.x)
	
	# change the sizes of all the items
	size = cur_size
	shadow.size = cur_size
	grid_space.size = cur_size
	
	grid_map.offset = -(cur_size / 2) # prevent long items from going far from the mouse by making it in the center
	
	# rotation the actual image because there have been a lot of problems with rotationg the textureRect node
	var image_res: Image = texture.get_image()
	image_res.rotate_90(CLOCKWISE)
	texture = ImageTexture.create_from_image(image_res)
	
	size = cur_size
	is_rotated = not is_rotated # change the rotation state so we can save it
	grid_map.emit_signal("item_rotated") # emits the signal after all of this is done

func _on_item_picked() -> void:
	print("picked up")
	shadow.visible = true

func _on_item_placed() -> void:
	print("placed down")
	grid_map = get_parent()
	shadow.visible = false

#-------------------------------------------------#
func _on_menu_pressed(id: int) -> void:
	match id:
		0:
			use()
		1:
			split()
		2:
			remove()

func use() -> void:
	# This item will call the Item manager's item used signal then from there custom functionalties is added
	ItemManager.emit_signal("item_used", itemData, quantity)

func split() -> void:
	if quantity / 2 >= 1:
		var item_instance: Item = grid_map.itemBase.instantiate()
		grid_map.add_child(item_instance)
		item_instance.prep_item(itemData)
		grid_map.item_held = item_instance
		
		# configuring the quantity of the item currently held and then the one that was splited from
		item_instance.quantity = quantity / 2 + (quantity % 2)
		quantity /= 2


# change this function to whatever you need it to be e.g drop an item to the world then delete it
func remove() -> void:
	ItemManager.disconnect("item_used", Callable(ItemManager, "_on_item_used"))
	queue_free()
