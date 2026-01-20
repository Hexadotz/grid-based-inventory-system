class_name ItemDB extends Resource

# yeah this is litteraly it, it could be better to make a single autoload and have it 
# describe the items instead of making a lot of resources but no, godot is shit
@export var items: Array[ItemData] = [] ##The list of all the inventory items that will be in your game, you only need one ItemDB resource for your entier game
