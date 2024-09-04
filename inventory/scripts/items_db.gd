extends Node

var ITEMS: Dictionary = {
	"con_medkit":{
		"icon": "res://assets/UI/Inventory/test/icon_cons_medkit.png",
		"grid_size": Vector2i(4, 3),
		"stackble": true
	},
	
	"wep_AK47":{ 
		"icon": "res://assets/UI/Inventory/test/icon_wep_AK47.png",
		"grid_size": Vector2i(6, 2),
		"stackble": false
	},
	
	"wep_revolver":{ 
		"icon": "res://assets/UI/Inventory/test/icon_wep_python.png",
		"grid_size": Vector2i(3, 3),
		"stackble": false
	},
	
	"amm_boolet":{ 
		"icon": "res://assets/UI/Inventory/test/icon_ammo_boolets.png",
		"grid_size": Vector2i(1, 1),
		"stackble": true
	},
	
	"maxwell":{ 
		"icon": "res://assets/UI/Inventory/maxwell.png",
		"grid_size": Vector2i(5, 3),
		"stackble": false
	},
	
	"test2":{ 
		"icon": "res://assets/UI/Inventory/test/test.jpg",
		"grid_size": Vector2i(4, 3),
		"stackble": false
	},
	
	"wep_grenade":{ 
		"icon": "res://assets/UI/Inventory/test/nade.png",
		"grid_size": Vector2i(3, 3),
		"stackble": false
	},
	
	#-------------------------------------------------------------------#
	# template for addition of items
	"item_name":{ 
		"icon": "",
		"grid_size": Vector2i(1, 1),
		"stackble": false
	},
	
	
	"debug_boarder":{ 
		"icon": "res://assets/UI/Inventory/gird_boarder.png",
		"grid_size": Vector2i(3, 4),
		"stackble": false
	},
	# in case an item dosen't exist an error is placed instead
	"error": {
		"icon": "res://assets/UI/Inventory/gird_cell_error.png",
		"grid_size": Vector2i(1, 1),
		"stackble": false
	}
}

func get_item(item_id: String) -> Dictionary:
	return ITEMS[item_id] if item_id in ITEMS else ITEMS["error"]
