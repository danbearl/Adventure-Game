#TODO: create method that sets limit on line length and inserts line breaks into text 
#at the nearest word to prevent wrapping words around the screen
#TODO: Migrate class definitions to external files to clean up code
#TODO: Combat!!
require("./thing.rb")
require("./rules.rb")
require("./player.rb")
require("./creature.rb")
require("./item.rb")
require("./room.rb")
require("./map.rb")
require("./population.rb")

#methods within the main scope: go, examine, pickup, drop, insert, remove, look, parse
def go(inputArr)
	if inputArr.include?("north") or inputArr.include?("n") 
		if $map.rooms[$currentRoom].north == -1
			return false
		else 
			$currentRoom = $map.rooms[$currentRoom].north
			return true
		end
	elsif inputArr.include?("northeast") or inputArr.include?("ne") 
		if $map.rooms[$currentRoom].northeast == -1
			return false
		else 
			$currentRoom = $map.rooms[$currentRoom].northeast
			return true
		end
	elsif inputArr.include?("east") or inputArr.include?("e") 
		if $map.rooms[$currentRoom].east == -1
			return false
		else 
			$currentRoom = $map.rooms[$currentRoom].east
			return true
		end
	elsif inputArr.include?("southeast") or inputArr.include?("se") 
		if $map.rooms[$currentRoom].southeast == -1
			return false
		else 
			$currentRoom = $map.rooms[$currentRoom].southeast
			return true
		end
	elsif inputArr.include?("south") or inputArr.include?("s") 
		if $map.rooms[$currentRoom].south == -1
			return false
		else 
			$currentRoom = $map.rooms[$currentRoom].south
			return true
		end
	elsif inputArr.include?("southwest") or inputArr.include?("sw") 
		if $map.rooms[$currentRoom].southwest == -1
			return false
		else 
			$currentRoom = $map.rooms[$currentRoom].southwest
			return true
		end
	elsif inputArr.include?("west") or inputArr.include?("w") 
		if $map.rooms[$currentRoom].west == -1
			return false
		else 
			$currentRoom = $map.rooms[$currentRoom].west
			return true
		end
	elsif inputArr.include?("northwest") or inputArr.include?("nw") 
		if $map.rooms[$currentRoom].northwest == -1
			return false
		else 
			$currentRoom = $map.rooms[$currentRoom].northwest
			return true
		end
	elsif inputArr.include?("up") or inputArr.include?("u") 
		if $map.rooms[$currentRoom].up == -1
			return false
		else 
			$currentRoom = $map.rooms[$currentRoom].up
			return true
		end
	elsif inputArr.include?("down") or inputArr.include?("d") 
		if $map.rooms[$currentRoom].down == -1
			return false
		else 
			$currentRoom = $map.rooms[$currentRoom].down
			return true
		end
	else
		return false
	end
end #end of go()

def examine(itemName)
	countRoom = 0
	countInventory = 0
	if $map.rooms[$currentRoom].items.length < 1 and $player.inventory.length < 1
		puts("There are no items here.")
		return
	end
	if itemName == nil
		puts("You must specify something to examine.")
		return
	end
	#Is the item named in this room?
	for i in $map.rooms[$currentRoom].items

		if i.name.downcase() == itemName
			puts(i.description)
			countRoom += 1
		end #if
	end #for
	
	#Is the item named in the player's inventory?
	for i in $player.inventory
		if i.name.downcase() == itemName
			puts(i.description)
			countInventory += 1
		end
	end
	
	if countRoom == 0 and countInventory == 0
		puts("I don't see a #{itemName} here.")
	end #if
end #End of examine()

def pickup(arguments)
	#user should input command as 'get ({quantity}) {item name}'
	count = 0
	#First check to see if there are any items to get
	if $map.rooms[$currentRoom].items.length < 1
		puts("There are no items here.")
		return
	end #if
	#Make sure user actually specified something to pick up
	if arguments.length < 2
		puts("You must specify something to pickup")
		return
	end #if
	
	#if the user did not specify a quantity, assume 1
	if arguments[2] == nil
		arguments[2] = 1
	end #if
	
	#Iterate over all of the objects in the room until the program finds one that has a name matching
	#the user's input and then move that item into the player's inventory
	for i in $map.rooms[$currentRoom].items
		if i.name.downcase() == arguments[1]
			if i.static == true 	#If the item is static, do not allow the player to get it
				puts("You cannot move the #{i.name}")
				count = 1
				break
			end
			if i.size > $player.space_available 	#If the player does not have enough space left yet, then tell the user	
				puts("You don't have enough space in your inventory!")
				count = 1
				break
			end
			$player.inventory << i #Put in inventory
			$map.rooms[$currentRoom].items.delete(i) #Remove from room
			puts("You pick up a #{i.name}")
			count += 1
		end #end
	end #for
	
	if count < 1
		puts("I don't see any #{arguments[1]} here.")
	end #if
end #End of pickup

def drop(arguments)
	#user should input command as 'drop ({quantity}) {item name}'
	count = 0
	
	if $player.inventory.length < 1
		puts("You aren't carrying anything!")
	end #if
	
	if arguments.length < 2
		puts("You must specify something to drop")
	end #if
	
	#if the user did not specify a quantity, assume 1
	if arguments[2] == nil
		arguments[2] = 1
	end #if
	
	for i in $player.inventory
		if i.name.downcase() == arguments[1]
			if count > arguments[2]
				break
			end #end
			
			#add the item to the room and then remove from inventory
			$map.rooms[$currentRoom].items << i
			$player.inventory.delete(i)
			puts("You drop up a #{i.name}")
			count += 1
		end #end
	end #for
	
	if count < 1
		puts("You aren't carrying any #{arguments[1]}.")
	end #if
end #End of drop()

#places an object inside another object, if possible
#valid syntax for the user is put {object} (in) {container}
def insert (arguments)
	count = 0
	objIndex = -1
	contIndex = -1
	objInv = false
	contRoom = false
	contInv = false
	
	#Did the user include 'in'?
	if arguments[2] == "in"
		targetIndex = 3
	else
		targetIndex = 2	
	end #if
	
	#Is the player carrying the item to be put?
	for i in $player.inventory
		if i.name.downcase() == arguments[1] then 
			objInv = true
			objIndex = count
			break
		end #if
		count += 1
	end #for

	count = 0
	#Is the container present? Check player first, and then check the room, but only if
	#container is not in the player's inventory
	for i in $player.inventory
		if i.name.downcase() == arguments[targetIndex] then 
			contInv = true
			contIndex = count
			break
		end #if
		count += 1
	end #for
	count = 0
	if contIndex == -1
		for i in $map.rooms[$currentRoom].items
			if i.name.downcase() == arguments[targetIndex] then 
				contRoom = true
				contIndex = count
				break
			end #if
			count += 1
		end #for
	end #if

	#If the object or container are not present, return with appropriate message
	if !objInv
		puts("You are not carrying a #{arguments[1]}.")
		return
	elsif !contRoom and !contInv
		puts("There is no #{arguments[targetIndex]} here.")
		return
	end #if

	#if target is not a container let the player know
	if contInv
		if $player.inventory[contIndex].capacity < 1
			puts("The #{arguments[targetIndex]} is not a container!")
			return
		end
	elsif contRoom
		if $map.rooms[$currentRoom].items[contIndex].capacity < 1
			puts("The #{arguments[targetIndex]} is not a container!")
			return
		end
	end
	
	#if target does not have enough space, let the player know
	if contInv
		if $player.inventory[objIndex].size > $player.inventory[contIndex].space_available
			puts("It won't fit!")
			return
		end
	elsif contRoom
		if $player.inventory[objIndex].size > $map.rooms[$currentRoom].items[contIndex].space_available
			puts("It won't fit!")
			return
		end
	end
	
	#move the object into the container, starting with the player's inventory first
	if objInv and contInv
		$player.inventory[contIndex].contents << $player.inventory[objIndex]
		$player.inventory.delete($player.inventory[objIndex])
	elsif objInv and contRoom
		$map.rooms[$currentRoom].items[contIndex].contents << $player.inventory[objIndex]
		$player.inventory.delete($player.inventory[objIndex])
	elsif objRoom and contInv
		$player.inventory[contIndex] << $map.rooms[$currentRoom].items[objIndex]
		$map.rooms[$curentRoom].items.delete($map.rooms[$currentRoom].items[objIndex])
	elsif objRoom and contRoom
		$map.rooms[$currentRoom].items[contIndex].contents << $map.rooms[$currentRoom].items[objIndex]
		$map.rooms[$currentRoom].items.delete($map.rooms[$currentRoom].items[objIndex])
	end #if
	puts("You put the #{arguments[1]} in the #{arguments[targetIndex]}.")
end #insert()

#The following function allows the player to remove an item from a container into
#the player's inventory. Syntax is remove {item} (from) {item}
def remove(arguments)
	count = 0
	objIndex = -1
	contIndex = -1
	objInv = false
	contRoom = false
	contInv = false
	
	#first determine that the correct number of arguments have been passed.
	if arguments.length == 1 
		puts("Remove what from what?")
		return
	end #if
	
	if arguments.length == 2
		puts("Remove #{arguments[1]} from what")
		return
	end
	
	#determine if user included "from"
	if arguments[2] == "from"
		targetIndex = 3
	else
		targetIndex = 2
	end

	#now determine if the container is present, starting with the user's inventory
	for i in $player.inventory
		if i.name.downcase() == arguments[targetIndex] then 
			contInv = true
			contIndex = count
			break
		end #if
		count += 1
	end #for
	count = 0
	if contIndex == -1
		for i in $map.rooms[$currentRoom].items
			if i.name.downcase() == arguments[targetIndex] then 
				contRoom = true
				contIndex = count
				break
			end #if
			count += 1
		end #for
	end #if

	#if container is not present, tell user
	if !contInv and !contRoom
		puts("There is no #{arguments[targetIndex]} here.")
		return
	end
	
	#Determine if the item is in the container
	count = 0
	if contInv
		for i in $player.inventory[contIndex].contents
			if i.name.downcase() == arguments[1]
				objIndex = count
				break
			end
			count += 1
		end
	elsif contRoom
		for i in $map.rooms[$currentRoom].items[contIndex].contents
			if i.name.downcase() == arguments[1]
				objIndex = count
				break
			end
			count += 1
		end
	end
	
	#if item was not found in container, let the player know
	if objIndex == -1
		puts("There is no #{arguments[1]} in the #{arguments[targetIndex]}.")
		return
	end

	#move the item from the container to the player's inventory
	if contInv
		$player.inventory << $player.inventory[contIndex].contents[objIndex]
		$player.inventory[contIndex].contents.delete($player.inventory[contIndex].contents[objIndex])
	elsif contRoom
		$player.inventory << $map.rooms[$currentRoom].items[contIndex].contents[objIndex]
		$map.rooms[$currentRoom].items[contIndex].contents.delete($map.rooms[$currentRoom].items[contIndex].contents[objIndex])
	end
	puts("You remove the #{arguments[1]} from the #{arguments[targetIndex]}")
end #remove()

def look
	puts($map.rooms[$currentRoom].description)
	for i in $population.creatures
		if i.location == $currentLocation
			puts("There is a #{i.name} here.")
		end
	end
end

def parse(input)
	#if quit, set $quit to true and return true
	if input.downcase() == "quit"
		$quit = true
		return true
	end
	#convert input into an array of words, all in lower case
	inputArr = input.downcase().split
	
	#make sure length is not zero
	if inputArr.length < 1
		puts("Please enter a command\n")
		return
	end
	#check for directional keywords (I know this is ugly)
	input = case 
		when $directions.include?(inputArr[0])
			if go(inputArr)
				puts("\n")
				return true
			else
				puts("You cannot go that way.\n")
				return false
			end
		#describe the room again if asked to
		when inputArr.include?("look")
			look
			return false
		when inputArr.include?("examine")
			examine(inputArr[1])
			return false
		when inputArr.include?("get")
			pickup(inputArr)
			return false
		when inputArr.include?("drop")
			drop(inputArr)
			return false
		when inputArr.include?("put")
			insert(inputArr)
			return false
		when inputArr.include?("remove")
			remove(inputArr)
			return false
		when inputArr.include?("inventory"), inputArr.include?("i")
			puts("\nYou are carrying:")
			for i in $player.inventory
				puts(i.name)
			end #for
			puts("Inventory space left: #{$player.space_available}")
			return false
		else puts("I don't understand you.\n")
			return false
	end
end #end of parse()

#An array of recognized directions
$directions = ["go", "north", "n", "northeast", "ne", "east", "e", "southeast", "se", "south", "s", "southwest", "sw", "west", "w", "northwest", "nw", "up","u","down","d"]

#build items ( aName, aDescription, weight, size, durability, capacity, contents, static, light)
puts("Building game items")
$item1 = Item.new("Cup", "A golden cup encrusted in jewels", 1, 1, 5, 0, [], false, false)
$item2 = Item.new("Gem", "A brilliant green gem, finely cut", 1, 1, 10, 0, [], false, false)
$item3 = Item.new("Rock", "A small, smooth stone", 1, 1, 10, 0, [], false, false)
$item4 = Item.new("Staff", "Your trusty walking stick, worn smooth from years of use", 3, 2, 5, 0, [], false, false)
$item9 = Item.new("Coin", "A small gold coin", 1, 1, 5, 0, [], false, false)
$item5 = Item.new("Fountain", "A small fountain bubbles quietly in the center of the room", 100, 10, 100, 3, [$item9], true, false)
$item6 = Item.new("Torch", "A torch that flickers gently", 1, 1, 1, 0, [], false, true)
$item7 = Item.new("Bag", "A large cloth sack, good for carrying things.", 2, 5, 10, 10, [], false, false)
$item10 = Item.new("Boulder","An enormous stone", 30, 30, 100, 0, [], false, false)


#build the rooms ( aName, aDescription, n, ne, e, se, s, sw, w, nw, u, d, aLight, someItems )
puts("Building Rooms")
room0 = Room.new("room0", "You are in the entryway to the labynth. The tunnel to the south that leads to the surface has collapsed, but the passageway continues to the north. \nThere is a fountain here.", 1,-1,-1,-1,-1,-1,-1,-1,-1,-1,true,[$item5, $item1, $item10])
room1 = Room.new("room1", "This is the second room.", -1,-1,2,-1,0,-1,3,-1,-1,-1,true,[$item2, $item3])
room2 = Room.new("room2", "This small side chamber smells of mildew and rot.",-1,-1,-1,-1,-1,-1,1,-1,-1,-1,true,[$item6])
room3 = Room.new("room3", "There is a scary monster in here!", -1,-1,1,-1,-1,-1,-1,-1,-1,-1, false, [$item7])
room4 = Room.new("room4", "This is a secret room!", -1, -1, 0, -1, -1, -1, -1, -1, -1, -1, true, [])

#build the map
puts("Building Map")
$map = Map.new([room0, room1, room2, room3, room4])

#generate creatures (aName, aDescription, health, attack, defense, loot, static, hostile, location)
puts("Generating creatures")
creature0 = Creature.new("Rhino", "A peaceful rhinocerous wanders the halls of the dungeon.", 10, 10, 10, [], false, false, 1)
creature1 = Creature.new("Skeleton", "A shambling animated pile of bones that can be up to no good!", 1, 1, 1, [], false, true, 2)
#populate dungeon
puts("Populating map")
$population = Population.new([creature0, creature1])
#initialize rules
rules = Rules.new

#initialize
puts("Initializing global variables")
$quit = false
$currentRoom = 0

#create player
puts("Generating player avatar")
puts("What is your name?")
playerName = gets()
while playerName.chomp().length < 1
	puts("You must enter a name to continue")
	playerName = gets()
end
$player = Player.new(playerName.chomp(), [$item4], 100, 10, 10)

welcomeText = <<EODOC
Welcome, #{$player.name}, to Dan's Adventure Game!
This game is his personal exercise to learn to program in Ruby!
Enjoy!
EODOC

puts(welcomeText)

#main logic
while !$quit
	look
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
			puts("What would you like to do?")
			input = gets().chomp()
		end
	end
end