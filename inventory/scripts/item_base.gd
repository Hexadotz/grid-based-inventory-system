class_name Item extends Control

#NOTE to self: this is retarded
@onready var grid_map = get_parent()

@export var actionList: MenuButton 
@export var grid_space: ColorRect 
@export var textIcon: TextureRect
@export var countLabel: Label
@export var shadow: ColorRect 

var cur_size: Vector2 = Vector2.ZERO
var stackable: bool = false
var item_id: String = ""
var quantity: int = 1

const VALID_SPOT: Color = Color(0.45, 1, 0, 0.3) # The color for valid placement of items
const OCCUPIED_SPOT: Color = Color(1, 0, 0, 0.3) # the color of occupied areas
const SWITCH_SPOT: Color = Color(1, 0.68, 0, 0.3) # thr color when the area is occupied by other items
#----------------------------------------------------------#
func _ready() -> void:
	countLabel.visible = false

func _process(_delta: float) -> void:
	var zone: Rect2 = Rect2(grid_map.hover_rect.global_position, size)
	if grid_map.is_inside_rect(zone):
		shadow.global_position = grid_map.hover_rect.global_position
	
	if stackable:
		countLabel.text = "X" + str(quantity)
	shadow.visible = grid_map.item_held == self

func prep_item(itemId: String = "") -> void:
	var item_property: Dictionary = ItemsDB.get_item(itemId)
	cur_size = item_property.grid_size * grid_map.cell_size
	
	item_id = itemId
	
	textIcon.texture = load(item_property.icon)
	textIcon.size = cur_size
	size = cur_size
	
	shadow.size = cur_size
	grid_space.size = cur_size
	actionList.size = cur_size
	
	stackable = item_property.stackble
	
	var actionPopUp: PopupMenu = actionList.get_popup()
	actionPopUp.add_item("Use", 0)
	actionPopUp.add_item("Drop", 1)
	
	if stackable:
		actionPopUp.add_item("Split", 2)
		countLabel.visible = true
		countLabel.text = "X" + str(quantity)
	
	actionPopUp.id_pressed.connect(_on_menu_pressed)

# rotates the object by fliping the extents (width and height)
func rotate() -> void:
	# flips the size of the item so it "rotates"
	cur_size = Vector2(cur_size.y, cur_size.x)
	
	shadow.size = cur_size
	textIcon.size = cur_size
	grid_space.size = cur_size
	
	# rotation the actual image because there have been a lot of problems with rotationg the textureRect node
	var image_res: Image = textIcon.texture.get_image()
	image_res.rotate_90(CLOCKWISE)
	textIcon.texture = ImageTexture.create_from_image(image_res)
	
	size = cur_size
	grid_map.emit_signal("item_rotated")

func split() -> void:
	if quantity / 2 >= 1:
		var item_instance: Item = grid_map.itemBase.instantiate()
		grid_map.add_child(item_instance)
		item_instance.prep_item(item_id)
		grid_map.item_list.append(item_instance)
		grid_map.item_held = item_instance
		
		item_instance.quantity = quantity / 2 + (quantity % 2)
		quantity /= 2

#-------------------------------------------------#
func _on_menu_pressed(id: int) -> void:
	match id:
		0:
			print("Using")
		1:
			remove()
		2:
			split()

# change this function to whatever you need it to be e.g drop an item to the world then delete it
func remove() -> void:
	grid_map.item_list.erase(self)
	queue_free()
