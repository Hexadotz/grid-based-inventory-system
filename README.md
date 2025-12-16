# Grid-based/tetris-like inventory system in godot


A  comprehensive grid-based inventory management system inspired by survival horror games such as Resident Evil, Gloomwood, and Sir, You Are Being Hunted. This repository provides a framework with essential features necessary for any inventory system, designed to be extended and customized according to your project’s needs.

![Animation](https://github.com/user-attachments/assets/1ab14a73-39c2-4702-973f-5c6a98e406b0)

## Features
<table border="0">
   <tr>
	  <th>Stacking</th>
	  <th>Swapping</th>
	  <th>Rotation</th>
	  <th>Saving and loading items</th>
   </tr>
   <tr>
	  <td><img src="https://github.com/user-attachments/assets/88428f59-2a19-48b0-8b6b-a91209d990be" height="256" width="256"></td>
	  <td><img src="https://github.com/user-attachments/assets/ff992301-7644-4eed-adea-e917434104e2" height="256" width="256"></td>
	  <td><img src="https://github.com/user-attachments/assets/98799ff7-9463-483d-a1a2-1518975325d2" height="256" width="256"></td>
	  <td><img src="https://github.com/user-attachments/assets/f616e5a0-baa3-45ec-b359-01e6235a3787" height="256" width="526"></td>
   </tr>
</table>

You can watch a tutorial video on [YouTube](https://www.youtube.com/watch?v=0qNqyxlL9Mc) to see how to use this inventory system. Here’s a quick rundown of the setup process:<br>
UPDATE: there is now a document explaining how to use this thing

1. **Add the `item_db.gd` Script to Autoload**:
   - Navigate to your project’s autoload settings.
   - Add the `items_manager.gd` script as a singleton.
   - **Important**: Name the singleton exactly as `ItemsManager` to avoid errors.

2. **Configure the `item_db.gd` Script**:
   - Create a resource of type `ItemDB`
   - Fill the `ITEMS` variable with the items you need. A template is provided in the script to illustrate the required structure for item definitions as well as some examples.

3. **Add Items to the Inventory**:
   - Use the `add_item(item_id)` method provided by the inventory system.
   - Call this method to add items from the `ITEMS` dictionary to the inventory.

## Credits
Some of the images used for the demo are from [PNGEgg](https://www.pngegg.com/)
Special thanks to Piducod for finding some of the bug and reporting it

## Notes
I'l probablly come back to this to update it more and make the code cleaner as well as add any features requested

No credits is necessary you can use this however you like but i'd apreciate it if you do, if you made a game with this i'd be really happy to know about
