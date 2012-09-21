#TODO: create method that sets limit on line length and inserts line breaks into text 
#	at the nearest word to prevent wrapping words around the screen
#TODO: modify display to show the player's stats
#TODO: figure out how to apply status effects to player
#TODO: create help method to display to user valid commands
#TODO: Look for redundant code within the game and find ways to minimize duplication of code
#	through the use of methods and objects.
#TODO: Clean up code by creating naming conventions for standard variables
#TODO: Where possible, move methods into the objects to minimize the need for global variables
#TODO: Write better comments throughout the program so that it is easy to understand what is going on
#TODO: Create a log that keeps track of everything that happens
#TODO: Figure out how to wipe the console with each room change OR figure out how to 
#	create my own GUI
#TODO: Add subclass of Item for readable material such as books, scrolls and wall carvings.
#	The readable subclass should have a flag to determine whether or not it has been read yet,
#	A description and contents. A new 'read' command will then need to be added to the parse function

require("./thing.rb")
require("./rules.rb")
require("./player.rb")
require("./creature.rb")
require("./item.rb")
require("./room.rb")
require("./map.rb")
require("./population.rb")
require("./methodslib.rb")

ADVENTURE_VERSION = "0.4a"
#for use in correct article/noun agreement
$vowels = ['a','e','i','o','u','A','E','I','O','U']
#An array of recognized directions
$directions = ["go", "north", "n", "northeast", "ne", "east", "e", "southeast", "se", "south", "s", "southwest", "sw", "west", "w", "northwest", "nw", "up","u","down","d"]

#build items ( aName, aDescription, weight, size, durability, attack, defense, capacity, openable, open, locked, contents, static, light)
#TODO: All of these need to fixed to reflect new item subcategory framework
puts("Building game items")

#Items ( aName, aDescription, weight, size, durability, static)
$item3 = Item.new("Rock", "A small, smooth stone", 1, 1, 10, false)
$item10 = Item.new("Boulder","An enormous stone", 30, 30, 100, false)
$item11 = Item.new("Bone", "An old, dry bone dropped by a skeleton", 1, 1, 1, false)

#Weapons (aName, aDescription, weight, size, durability, static, attack)
$item4 = Weapon.new("Staff", "Your trusty walking stick, worn smooth from years of use", 3, 2, 5, false, 1)
$item14 = Weapon.new("Sword", "A fine steel blade", 3, 2, 10, false, 5)

#Armor (aName, aDescription, weight, size, durability, static, defense)
$item13 = Armor.new("Clothes", "Your traveling clothes. A little worse for wear and in need of a good cleaning, but very light and comfortable.", 1, 1, 1, false, 1)
$item15 = Armor.new("Chainmail", "A suit made from and intricate mesh of interlocking metal rings to protect you from attacks", 5, 5, 5, false, 10)

#Light Sources (aName, aDescription, weight, size, durability, static, isLit, fuel, fuelType)
$item6 = Light.new("Torch", "An unlit torch", 1, 1, 1, false, false, 10, "rags", "A torch that flickers gently")

#Treasure (aName, aDescription, size, weight, durability, static, value)
$item1 = Treasure.new("Cup", "A golden cup encrusted in jewels", 1, 1, 5, false, 100)
$item2 = Treasure.new("Gem", "A brilliant green gem, finely cut", 1, 1, 10, false, 100)
$item9 = Treasure.new("Coin", "A small gold coin", 1, 1, 5, false, 50)
$item16 = Treasure.new("Cup", "A golden cup encrusted in jewels", 1, 1, 5, false, 100)

#Food (aName, aDescription, size, weight, durability, static, quantity, consumedName, consumedDescription)
$item12 = Food.new("Apple", "A delicious looking red apple", 1, 1, 1, false, 50, "Applecore", "The chewed-on remains of your apple.")

#Fuels (aName, aDescription, size, weight, durability, static, quantity)
$item17 = Fuel.new("Rags", "Oily rags... these look like they might burn really well.", 1, 1, 1, false, 10)

#Keys (aName, aDescription)
$item19 = Key.new("BronzeKey", "A small bronze key.")

#Texts ( aName, aDescription, weight, size, durability, static, contents )
$item20 = Text.new("Inscription", 
					"Intricately carved text has been carved into the wall just below the ten sigils.", 
					1, 1, 1, true, 
					"In order to pass forward, you must appease the spirits of each house.")
$item21 = Text.new("Etchings",
					"Faint etchings that have faded with time and are barely legible.",
					1, 1, 1, true,
					"They key to open the door forward can be purchased with a gem.")

#Doors (aName, aDescription, isOpen, isLocked, key)
$item18 = Door.new("Door", "A heavy stone door set into the wall.", false, true, $item19)

#Containers: (aName, aDescription, weight, size, durability, static, capacity, contents, isOpen, isLocked, closeable, key)
$item5 = Container.new("Fountain", "A small fountain bubbles quietly in the center of the room", 100, 10, 100, true, 10, [$item9], true, false, false, '')
$item7 = Container.new("Bag", "A large cloth sack, good for carrying things.", 2, 5, 10, false, 10, [], false, false, true, '')

#build the rooms ( aName, aDescription, n, ne, e, se, s, sw, w, nw, u, d, aLight, someItems )
puts("Building Rooms")
room0 = Room.new("Graveyard", 
				"This is where dead monsters go!", 
				-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
				false,
				[])
room1 = Room.new("Dungeon Entrance", 
				"You are in the entryway to the labynth. The tunnel to the south that leads to the surface has collapsed, but the passageway continues to the north. \nThere is a fountain here.", 
				2,-1,-1,-1,-1,-1,-1,-1,-1,-1,
				true,
				[$item1, $item5, $item12, $item14, $item15, $item16])
room2 = Room.new("Intersection", 
				"The tunnel is collapsed to the north, but is intersected by another tunnel that runs east and west. A heavy stone door is set into the north wall.", 
				-1,-1,3,-1,1,-1,4,-1,-1,-1,
				true,
				[$item2, $item3, $item18])
room3 = Room.new("Musky Room", 
				"This small side chamber smells of mildew and rot.",
				-1,-1,-1,-1,-1,-1,2,-1,-1,-1,
				true,
				[$item6, $item17])
room4 = Room.new("Dark Room", 
				"This room has very poor lighting, but you can make out some faint etchings on the wall.", 
				-1,-1,2,-1,-1,-1,-1,-1,-1,-1, 
				false, 
				[$item7])
room5 = Room.new("Secret Room", 
				"This small room appears to have not been visited in quite a long time. A thick layer of dust covers the floor.", 
				-1,-1,1,-1,-1,-1,-1,-1,-1,-1, 
				true, 
				[$item19])
room6 = Room.new("Entrance to the Hall of Houses.", 
				"A long wallway stretches to the east and west for as long as you can see. The hallway is lined with doors, each with a different image carved on it. On the north facing wall, you see a carving of the sigils of the ten houses arranged in a ring around the a carving of the sun with an inscription below it.There is a heavy stone door to the south.", 
				-1,-1,7,-1,5,-1,12,-1,-1,-1, 
				true, 
				[$item18, $item20])
room7 = Room.new("Hall of Houses, East Wing",
				"House Antil",
				-1,-1,8,-1,-1,-1,6,-1,-1,-1,
				true,
				[])
room8 = Room.new("Hall of Houses, East Wing",
				"House Waleed",
				-1,-1,9,-1,-1,-1,7,-1,-1,-1,
				true,
				[])
room9 = Room.new("Hall of Houses, East Wing",
				"House Ontari",
				-1,-1,10,-1,-1,-1,8,-1,-1,-1,
				true,
				[])
room10 = Room.new("Hall of Houses, East Wing",
				"House Levaron",
				-1,-1,11,-1,-1,-1,9,-1,-1,-1,
				true,
				[])
room11 = Room.new("Hall of Houses, East Wing",
				"House Bantillo",
				-1,-1,-1,-1,-1,-1,10,-1,-1,-1,
				true,
				[])
room12 = Room.new("Hall of Houses, West Wing",
				"House Tarin",
				-1,-1,6,-1,-1,-1,13,-1,-1,-1,
				true,
				[])
room13 = Room.new("Hall of Houses, West Wing",
				"House Larentis",
				-1,-1,12,-1,-1,-1,14,-1,-1,-1,
				true,
				[])
room14 = Room.new("Hall of Houses, West Wing",
				"House Charin",
				-1,-1,13,-1,-1,-1,15,-1,-1,-1,
				true,
				[])
room15 = Room.new("Hall of Houses, West Wing",
				"House Marleen",
				-1,-1,14,-1,-1,-1,16,-1,-1,-1,
				true,
				[])
room16 = Room.new("Hall of Houses, West Wing",
				"House Santarii",
				-1,-1,15,-1,-1,-1,-1,-1,-1,-1,
				true,
				[])
room17 = Room.new("Crypt Exit",
				"You can see sunlight pouring in from a hole in the ceiling. A ladder leads up and out to freedom.",
				-1,-1,-1,-1,-1,-1,-1,-1,18,-1,
				true,
				[])
room18 = Room.new("You win!",
				"Congratulations! You managed to escape the Crypt of Houses.",
				-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
				true,
				[])

#build the map
puts("Building Map")
$map = Map.new([room0, room1, room2, room3, room4, room5, room6, room7, room8, room9, room10, room11, room12, room13, room14, room15, room16, room17, room18])

#generate creatures (aName, aDescription, health, attack, defense, loot, static, hostile, location)
puts("Generating creatures")
creature0 = Creature.new("Rhino", "A peaceful rhinocerous wanders the halls of the dungeon.", 10, 10, 10, [], false, false, 0)
creature1 = Creature.new("Skeleton", "A shambling animated pile of bones that can be up to no good!", 1, 50, 1, [$item11], false, true, 0)
#populate dungeon
puts("Populating map")
$population = Population.new([creature0, creature1])
#initialize rules
rules = Rules.new

#initialize
puts("Initializing global variables")
$quit = false
$currentRoom = 1

#create player
puts("Generating player avatar")
puts("What is your name?")
playerName = gets()
while playerName.chomp().length < 1
	puts("You must enter a name to continue")
	playerName = gets()
end
#player arguments( aName, someItems, weapon, armor, health, attack, defense )
$player = Player.new(playerName.chomp(), [], $item4, $item13, 100, 10, 10)

welcomeText = <<EODOC
Welcome, #{$player.name}, to Dan's Adventure Game! v#{ADVENTURE_VERSION}
This game is his personal exercise to learn to program in Ruby!
Enjoy!
EODOC

puts(welcomeText)

#main logic
while !$quit
	look
	rules.check($currentRoom)
	puts("What would you like to do?")
	input = gets().chomp()
	if input.downcase() == "quit"
		$quit = true
	else
		while !parse(input)
			#check for triggered events
			rules.check($currentRoom)
			#creatures take actions
			for i in $population.creatures
				i.act
			end
			if $quit == true
				input = "quit"
			else
				puts("What would you like to do?")
				input = gets().chomp()
			end
		end
	end
end