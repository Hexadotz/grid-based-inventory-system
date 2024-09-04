# Grid-based/tetris-like inventory system in godot


A  comprehensive grid-based inventory management system inspired by survival horror games such as Resident Evil, Gloomwood, and Sir, You Are Being Hunted. This repository provides a framework with essential features necessary for any inventory system, designed to be extended and customized according to your project’s needs.

(![](https://github.com/user-attachments/assets/64090b57-93a9-45ec-a827-fa28d816f567)
)

## Features

- Manage items in a grid layout
- item swapping
- item stacking

You can watch a tutorial video on [YouTube](https://www.youtube.com/watch?v=0qNqyxlL9Mc) to see how to use this inventory system. Here’s a quick rundown of the setup process:

1. **Add the `item_db.gd` Script to Autoload**:
   - Navigate to your project’s autoload settings.
   - Add the `item_db.gd` script as a singleton.
   - **Important**: Name the singleton exactly as `ItemsDB` to avoid errors.

2. **Configure the `item_db.gd` Script**:
   - Open the `item_db.gd` script.
   - Populate the `ITEMS` variable with the items you need. A template is provided in the script to illustrate the required structure for item definitions.

3. **Add Items to the Inventory**:
   - Use the `add_item(item_id)` method provided by the inventory system.
   - Call this method to add items from the `ITEMS` dictionary to the inventory.

## Notes
I'l probablly come back to this to update it more and make the code cleaner as well as adda ny features requested

No credits needed you can use this however you like, if you made a game with this i'd be really happy to know about
