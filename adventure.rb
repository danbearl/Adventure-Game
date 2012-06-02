#TODO: create method that sets limit on line length and inserts line breaks into text 
#at the nearest word to prevent wrapping words around the screen
#TODO: Migrate class definitions to external files to clean up code
#TODO: Create a creatures class to populate the dungeon
class Rules

	def initialize
		@flag1 = false #Secret door in room0
	end
	def self.rules() {	0 => :room0, 
						1 => :room1, 
						2 => :room2,
						3 => :room3,
						4 => :room4} end
	def room0
		#If the gem is placed into the fountain, a secret door opens in room0
		if $map.rooms[$currentRoom].items[0].contents.include?($item2)
			if !@flag1
				puts("A secret door opens to the west!")
				@flag1 = true
			end
			$map.rooms[$currentRoom].west = 4
		end
		
		#If the gem is removed from the fountain, the secret door closes
		if !$map.rooms[$currentRoom].items[0].contents.include?($item2) and @flag1
			puts("The secret door closes!")
			$map.rooms[$currentRoom].west = -1
			@flag1 = false
		end
	end
	
	def room1
	
	end
	
	def room2
	
	end
	
	def room3
	
	end
	
	def room4
	
	end
	
	def check(arg)
		send self.class.rules[arg]
	end
end #Rules

class Player
	attr_accessor( :name, :inventory)
	
	def initialize( aName, someItems )
		@name = aName
		@inventory = someItems
		@capacity = 30
	end
	
	#a method to determine how much more the player can carry
	def space_available
		spaceTaken = 0
		#add up the size of all items inside player's inventory
		for i in @inventory
			spaceTaken = spaceTaken + i.size
		end #for
		#return the difference between what's carried and the max capacity
		return @capacity - spaceTaken
	end #space_available

end #End of Player

class Thing
	attr_accessor( :description, :name )
	
	@@thingCount = 0
	
	def initialize( aName, aDescription )
		@name = aName
		@description = aDescription
		
		@@thingCount += 1
		@id = @@thingCount
	end
end #End of Thing

class Creature < Thing
	attr_accessor( :health, :attack, :defense, :loot, :static, :hostile, :location)
	
	#Health, attack & defense are all ints; loot is an array of items; static & hostile are boolean
	#location is an int that corresponds with the index location in $maps.rooms that corresponds to the
	#room in which the creature is
	def initialize(aName, aDescription, health, attack, defense, loot, static, hostile, location)
		super(aName, aDescription)
		
		@health = health
		@attack = attack
		@defense = defense
		@loot = loot
		@static = static
		@hostile = hostile
		@location = location
		
	end
	
	#Act is run for each creature at each pass to determine its actions
	def act
		#If the creature is hostile and the player is in the same room, it will attack the player
		if hostile and $currentRoom == location
			attack
		#The Second thing a creature can do is move. If it is not static, it has a 50%
		#chance of moving to another adjacent room		
		elsif !@static
			if ((rand(100)+1)>50)
				move
			end
		end
	end
	
	#The creature's attack method
	def attack
		puts("#{@name} attacks you!")
	end
	
	#The creature's move method!
	def move
		exits = []
		#Determine which exits are available. Build an array of possible exits
		if $map.rooms[@location].north.to_i > -1 then exits << "north" end
		if $map.rooms[@location].northeast.to_i > -1 then exits << "northeast" end
		if $map.rooms[@location].east.to_i > -1 then exits << "east" end
		if $map.rooms[@location].southeast.to_i > -1 then exits << "southeast" end
		if $map.rooms[@location].south.to_i > -1 then exits << "south" end
		if $map.rooms[@location].southwest.to_i > -1 then exits << "southwest" end
		if $map.rooms[@location].west.to_i > -1 then exits << "west" end
		if $map.rooms[@location].northwest.to_i > -1 then exits << "northwest" end
		if $map.rooms[@location].up.to_i > -1 then exits << "up" end
		if $map.rooms[@location].down.to_i > -1 then exits << "down" end
		
		#Randomly choose one exit
		if exits.length > 0 then moved = true end
		r = rand(exits.length)
		
		#If the creature started in the same room as the player, tell the player about the move
		if @location == $currentRoom then
			puts("#{@name} leaves to the #{exits[r]}.")
		end
		#Set the creature's location to the chose exit's target location
		case( exits[r] )
			when "north" then @location = $map.rooms[@location].north
			when "northeast" then @location = $map.rooms[@location].northeast
			when "east" then @location = $map.rooms[@location].east
			when "southeast" then @location = $map.rooms[@location].southeast
			when "south" then @location = $map.rooms[@location].south
			when "southwest" then @location = $map.rooms[@location].southwest
			when "west" then @location = $map.rooms[@location].west
			when "northwest" then @location = $map.rooms[@location].northwest
			when "up" then @location = $map.rooms[@location].up
			when "down" then @location = $map.rooms[@location].down
		end
		#If the creature arrives in the same room as the player, tell the player
		if @location == $currentRoom then
			puts("#{@name} arrives.")
		end	
	end
end #Creature
class Item < Thing
	attr_accessor( :weight, :size, :durability, :capacity, :contents, :static, :light)
	
	#Name & Description are obvious. Weight, size, capacity, and durability will come into play
	#later. Static is boolean. True means it is part of the background and cannot be
	#picked up or moved, and is also not listed with non-static items under the room
	#description. Light is boolean and indicates whether the item is a source of light
	def initialize( aName, aDescription, weight, size, durability, capacity, contents, static, light)
		super( aName, aDescription )
		
		@weight = weight
		@size = size
		@durability = durability
		@capacity = capacity
		@contents = contents
		@static = static
		@light = light
		@currentDurability
		@broken = false
	end
	
	#Function to damage items
	def damage( damage )
		@currentDurability -= damage
		outputString = "#{@name} takes #{damage} points of damage!"
		if @currentDurability < 1
			@broken = true
			outputString = outputString + "#{@name} is broken!"
		end
		return outputString
	end #damage()
	
	#Function to repair items
	def repair(num)
		outputString = ""
		if @currentDurability >= @durability
			return "#{@name} is not damaged!"
		end
		@currentDurability = @currentDurability + num
		if @currentDurability > @durability
			@currentDurability = @durability
		end
		return "#{@name} is repaired by #{num} points"
	end #repair()
	
	def space_available
		spaceTaken = 0
		#add up the size of all items inside
		for i in @contents
			spaceTaken = spaceTaken + i.size
		end #for
		return @capacity - spaceTaken
	end #space_available
	
	def description
		outputString = @description + "\n\n"
		
		#if the item contains other items, list them
		if @contents.length > 0
			outputString = outputString + "Items inside the #{@name}: "
			for i in @contents
				outputString = outputString + i.name
				if i != contents.last() then outputString = outputString + ", " end
			end #for 
			outputString = outputString + "\n\n"
		end #if
		return outputString
	end #description()
end #End of Item

class Room < Thing
	attr_accessor( :north, :northeast, :east, :southeast, :south, :southwest, :west, :northwest, :up, :down )
	attr_accessor( :light, :items )
	
	#initialize room object. aName & aDescription are strings. Directions are string value
	#showing the target room for that direction. A value of -1 indicates no exit in 
	#that direction. aLight is boolean indicating whether the room has natural lighting
	def initialize( aName, aDescription, n, ne, e, se, s, sw, w, nw, u, d, aLight, someItems )
		super( aName, aDescription )
		@north = n
		@northeast = ne
		@east = e
		@southeast = se
		@south = s
		@southwest = sw
		@west = w
		@northwest = nw
		@up = u
		@down = d
		@light = aLight
		@items = someItems
	end
	
	def description
		#First, determine if there is enough light to see
		#Is the player carrying any light emitting objects?
		#Start with playerLight false, then cycle through each item. If even on item is
		#a light source, change to true
		playerLight = false
		for i in $player.inventory
			if i.light == true then playerLight = true end
		end #for
		
		#are there any items laying on the ground that are sources of light?
		itemLight = false
		for i in $map.rooms[$currentRoom].items
			if i.light == true then itemLight = true end
		end #for
		
		if @light == false and playerLight == false and itemLight == false
			return "It is too dark here for you to see anything."
		end #if
		
		#build outputString by removing any control characters from the end of @description
		@outputString = @description.chomp 
		#add items, if any
		#build an array of all non-static items
		nonStaticItems = []
		for i in @items
			if !i.static
				nonStaticItems << i
			end #if
		end #for
		if nonStaticItems.length > 0
			@outputString = @outputString + "\n\nItems here: "
			for i in nonStaticItems
				@outputString = @outputString + i.name
				if i != nonStaticItems.last
					@outputString = @outputString + ", "
				end #if
			end #for
			@outputString = @outputString
		end #if
		#and add exits.
		@outputString =  @outputString + "\n\nObvious Exits: "
		if @north != -1
			@outputString = @outputString + "North"
		end
		
		#if preceding direction is true, offset with comma
		if @northeast != -1 and @north != -1
			@outputString = @outputString + ", Northeast"
		elsif @northeast != -1 #if preceding direction is not true, do not add comma
			@outputString = @outputString + "Northeast"
		end
		
		if @north != -1 or @northeast != -1 and @east != -1
			@outputString = @outputString + ", East"
		elsif @east != -1
			@outputString = @outputString + "East"
		end
		
		if @north != -1 or @northeast != -1 or @east != -1 and @southeast != -1
			@outputString = @outputString + ", Southeast"
		elsif @southeast != -1
			@outputString = "Southeast"
		end
		
		if @north != -1 or @northeast != -1 or @east != -1 or @southeast != -1 and @south != -1
			@outputString = @outputString + ", South"
		elsif @south != -1
			@outputString = @outputString + "South"
		end
		#
		if @north != -1 or @northeast != -1 or @east != -1 or @southeast != -1 or @south != -1 and @southwest != -1
			@outputString = @outputString + ", Southwest"
		elsif @southwest != -1
			@outputString = @outputString + "Southwest"
		end
		
		if @north != -1 or @northeast!= -1 or @east!= -1 or @southeast!= -1 or @south!= -1 or @southwest!= -1 and @west!= -1
			@outputString = @outputString + ", West"
		elsif @west!= -1
			@outputString = @outputString + "West"
		end
		
		if @north!= -1 or @northeast!= -1 or @east!= -1 or @southeast!= -1 or @south!= -1 or @southwest!= -1 or @west!= -1 and @northwest!= -1
			@outputString = @outputString + ", Northwest"
		elsif @northwest!= -1
			@outputString = @outputString + "Northwest"
		end

		if @north!= -1 or @northeast!= -1 or @east!= -1 or @southeast!= -1 or @south!= -1 or @southwest!= -1 or @west!= -1 or @northwest!= -1 and @up != -1
			@outputString = @outputString + ", Up"
		elsif @up!= -1
			@outputString = @outputString + "Up"
		end

		if @north!= -1 or @northeast!= -1 or @east!= -1 or @southeast!= -1 or @south!= -1 or @southwest!= -1 or @west!= -1 or @northwest!= -1 or @up != -1 and @down != -1
			@outputString = @outputString + ", Down"
		elsif @down != -1
			@outputString = @outputString + "Down"
		end
					
		if @north==-1 and @northeast==-1 and @east==-1 and @southeast==-1 and @south==-1 and @southwest==-1 and @west==-1 and @northwest==-1 and @up==-1 and @down==-1
			@outputString = @outputString + "None"
		end
		
		return @outputString
	end #End of Room.description
end #End of Room

class Map < Thing
	attr_accessor( :rooms )
	
	def initialize( someRooms )
		@rooms = someRooms
	end
end #end of Map

#Population class will act as a container for all of the creatures in the game
class Population
	attr_accessor( :creatures )
	
	def initialize( someCreatures )
		@creatures = someCreatures
	end
end

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
	#check for directional keywords (I know this is ugly)
	#TODO: Convert this to a case switch to clean it up
	elsif (inputArr.include?("go") or inputArr.include?("north") or inputArr.include?("n") or inputArr.include?("northeast") or inputArr.include?("ne") or inputArr.include?("east") or inputArr.include?("e") or inputArr.include?("southeast") or inputArr.include?("se") or inputArr.include?("south") or inputArr.include?("s") or inputArr.include?("southwest") or inputArr.include?("sw") or inputArr.include?("west") or inputArr.include?("w") or inputArr.include?("northwest") or inputArr.include?("nw") or inputArr.include?("up") or inputArr.include?("u") or inputArr.include?("down") or inputArr.include?("d")) then
		if go(inputArr)
			puts("\n")
			return true
		else
			puts("You cannot go that way.\n")
			return false
		end
	#describe the room again if asked to
	elsif inputArr.include?("look")
		look
		return false
	elsif inputArr.include?("examine")
		examine(inputArr[1])
		return false
	elsif inputArr.include?("get")
		pickup(inputArr)
		return false
	elsif inputArr.include?("drop")
		drop(inputArr)
		return false
	elsif inputArr.include?("put")
		insert(inputArr)
		return false
	elsif inputArr.include?("remove")
		remove(inputArr)
		return false
	elsif inputArr.include?("inventory") or inputArr.include?("i")
		puts("\nYou are carrying:")
		for i in $player.inventory
			puts(i.name)
		end #for
		puts("Inventory space left: #{$player.space_available}")
		return false
	else
		puts("I don't understand you.\n")
		return false
	end
	return false
end #end of parse()

#build items ( aName, aDescription, weight, size, durability, capacity, contents, static, light)
puts("Building game items")
item1 = Item.new("Cup", "A golden cup encrusted in jewels", 1, 1, 5, 0, [], false, false)
$item2 = Item.new("Gem", "A brilliant green gem, finely cut", 1, 1, 10, 0, [], false, false)
item3 = Item.new("Rock", "A small, smooth stone", 1, 1, 10, 0, [], false, false)
item4 = Item.new("Staff", "Your trusty walking stick, worn smooth from years of use", 3, 2, 5, 0, [], false, false)
item9 = Item.new("Coin", "A small gold coin", 1, 1, 5, 0, [], false, false)
item5 = Item.new("Fountain", "A small fountain bubbles quietly in the center of the room", 100, 10, 100, 3, [item9], true, false)
item6 = Item.new("Torch", "A torch that flickers gently", 1, 1, 1, 0, [], false, true)
item7 = Item.new("Bag", "A large cloth sack, good for carrying things.", 2, 5, 10, 10, [], false, false)
item10 = Item.new("Boulder","An enormous stone", 30, 30, 100, 0, [], false, false)


#build the rooms ( aName, aDescription, n, ne, e, se, s, sw, w, nw, u, d, aLight, someItems )
puts("Building Rooms")
room0 = Room.new("room0", "You are in the entryway to the labynth. The tunnel to the south that leads to the surface has collapsed, but the passageway continues to the north. \nThere is a fountain here.", 1,-1,-1,-1,-1,-1,-1,-1,-1,-1,true,[item5, item1, item10])
room1 = Room.new("room1", "This is the second room.", -1,-1,2,-1,0,-1,3,-1,-1,-1,true,[$item2, item3])
room2 = Room.new("room2", "This small side chamber smells of mildew and rot.",-1,-1,-1,-1,-1,-1,1,-1,-1,-1,true,[item6])
room3 = Room.new("room3", "There is a scary monster in here!", -1,-1,1,-1,-1,-1,-1,-1,-1,-1, false, [item7])
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
$player = Player.new(playerName.chomp(), [item4])

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