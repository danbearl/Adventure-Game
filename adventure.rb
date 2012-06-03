#TODO: create method that sets limit on line length and inserts line breaks into text 
#	at the nearest word to prevent wrapping words around the screen
#TODO: modify display to show the player's stats
#TODO: figure out how to apply status effects to player
#TODO: make walking around in the dark dangerous
#TODO: create help method to display to user valid commands

require("./thing.rb")
require("./rules.rb")
require("./player.rb")
require("./creature.rb")
require("./item.rb")
require("./room.rb")
require("./map.rb")
require("./population.rb")
require("./methodslib.rb")

ADVENTURE_VERSION = "0.3a"
#for use in correctly rendering text
$vowels = ['a','e','i','o','u','A','E','I','O','U']
#An array of recognized directions
$directions = ["go", "north", "n", "northeast", "ne", "east", "e", "southeast", "se", "south", "s", "southwest", "sw", "west", "w", "northwest", "nw", "up","u","down","d"]

#build items ( aName, aDescription, weight, size, durability, attack, defense, capacity, contents, static, light)
puts("Building game items")
$item1 = Item.new("Cup", "A golden cup encrusted in jewels", 1, 1, 5, 0, 0, 0, [], false, false)
$item2 = Item.new("Gem", "A brilliant green gem, finely cut", 1, 1, 10, 0, 0, 0, [], false, false)
$item3 = Item.new("Rock", "A small, smooth stone", 1, 1, 10, 0, 0, 0, [], false, false)
$item4 = Item.new("Staff", "Your trusty walking stick, worn smooth from years of use", 3, 2, 5, 1, 0, 0, [], false, false)
$item9 = Item.new("Coin", "A small gold coin", 1, 1, 5, 0, 0, 0, [], false, false)
$item5 = Item.new("Fountain", "A small fountain bubbles quietly in the center of the room", 100, 10, 100, 0, 0, 3, [$item9], true, false)
$item6 = Item.new("Torch", "A torch that flickers gently", 1, 1, 1, 0, 0, 0, [], false, true)
$item7 = Item.new("Bag", "A large cloth sack, good for carrying things.", 2, 5, 10, 0, 0, 10, [], false, false)
$item10 = Item.new("Boulder","An enormous stone", 30, 30, 100, 0, 0, 0, [], false, false)
$item11 = Item.new("Bone", "An old, dry bone dropped by a skeleton", 1, 1, 1, 0, 0, 0, [], false, false)
$item12 = Item.new("Apple", "A delicious looking red apple", 1, 1, 1, 0, 0, 0, [], false, false)
$item13 = Item.new("Clothes", "Your traveling clothes. A little worse for wear and in need of a good cleaning, but very light and comfortable.", 1, 1, 1, 0, 1, 0, [], false, false)
$item14 = Item.new("Sword", "A fine steel blade", 3, 2, 10, 5, 0, 0, [], false, false)
$item15 = Item.new("Chainmail", "A suit made from and intricate mesh of interlocking metal rings to protect you from attacks", 5, 5, 5, 0, 10, 0, [], false, false)

#build the rooms ( aName, aDescription, n, ne, e, se, s, sw, w, nw, u, d, aLight, someItems )
puts("Building Rooms")
room0 = Room.new("Graveyard", "This is where dead monsters go!", -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, false, [])
room1 = Room.new("Dungeon Entrance", "You are in the entryway to the labynth. The tunnel to the south that leads to the surface has collapsed, but the passageway continues to the north. \nThere is a fountain here.", 2,-1,-1,-1,-1,-1,-1,-1,-1,-1,true,[$item5, $item12, $item14, $item15])
room2 = Room.new("Intersection", "The tunnel is collapsed to the north, but is intersected by another tunnel that runs east and west.", -1,-1,3,-1,1,-1,4,-1,-1,-1,true,[$item2, $item3])
room3 = Room.new("Musky Room", "This small side chamber smells of mildew and rot.",-1,-1,-1,-1,-1,-1,2,-1,-1,-1,true,[$item6])
room4 = Room.new("Dark Room", "This room has very poor lighting, but you can make out some faint etchings on the wall.", -1,-1,2,-1,-1,-1,-1,-1,-1,-1, false, [$item7])
room5 = Room.new("Secret Room", "This is a secret room!", -1, -1, 1, -1, -1, -1, -1, -1, -1, -1, true, [])

#build the map
puts("Building Map")
$map = Map.new([room0, room1, room2, room3, room4, room5])

#generate creatures (aName, aDescription, health, attack, defense, loot, static, hostile, location)
puts("Generating creatures")
creature0 = Creature.new("Rhino", "A peaceful rhinocerous wanders the halls of the dungeon.", 10, 10, 10, [], false, false, 2)
creature1 = Creature.new("Skeleton", "A shambling animated pile of bones that can be up to no good!", 1, 50, 1, [$item11], false, true, 3)
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
Welcome, #{$player.name}, to Dan's Adventure Game!
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