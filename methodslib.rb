#methods within the main scope: go, examine, pickup, drop, insert, remove, look, lock, unlock,
#light, extinguish, refuel, eat, parse, help
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
		puts("I don't see a#{if $vowels.include?(itemName[0]) then 'n' end} #{itemName} here.")
	end #if
end #End of examine()

def pickup(arguments)
	#user should input command as 'get {item name}'
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

	def move(item)
		if item.static 	#If the item is static, do not allow the player to get it
#			puts("You cannot move the #{item.name}")
			return
		end
		if item.size > $player.space_available 	#If the player does not have enough space left, then tell the user	
			puts("You don't have enough space in your inventory for the #{item.name}")
			return
		end
		$player.inventory << item #Put in inventory
		$map.rooms[$currentRoom].items.delete(item) #Remove from room
		puts("You pick up a#{if $vowels.include?(item.name[0]) then 'n' end} #{item.name}")
		return #item.name
	end #move
	
	if arguments[1] == "all" then

		$map.rooms[$currentRoom].items.reverse_each do |i|
			move(i)
		end
		return
	end
	
	
	#Iterate over all of the objects in the room until the program finds one that has a name matching
	#the user's input and then move that item into the player's inventory
	$map.rooms[$currentRoom].items.reverse_each do |i|
		if count >= 1 then break end
		if i.name.downcase == arguments[1]
			move(i)
			count += 1
		end 
	end #for
	
	if count < 1
		puts("I don't see a#{if $vowels.include?(arguments[1][0]) then 'n' end} #{arguments[1]} here.")
	end #if
end #End of pickup

def drop(arguments)
	#user should input command as 'drop {item name}'
	count = 0
	#allow player to drop all
	if arguments[1] == "all" then
		for i in $player.inventory
			$map.rooms[$currentRoom].items << i
			puts("You drop a #{i.name}.")
		end
		$player.inventory = []
		return
	end
	
	#If the player's inventory is less than one, they don't have anything to drop
	if $player.inventory.length < 1
		puts("You aren't carrying anything!")
	end #if
	
	#If there is no second argument, then the player has not specified anything to drop.
	if arguments.length < 2
		puts("You must specify something to drop")
	end #if
	
	#if the user did not specify a quantity, assume 1
	if arguments[2] == nil
		arguments[2] = 1
	end #if
	
	for i in $player.inventory
		if i.name.downcase() == arguments[1]
			#add the item to the room and then remove from inventory
			$map.rooms[$currentRoom].items << i
			$player.inventory.delete(i)
			puts("You drop a#{if $vowels.include?(i.name[0]) then 'n' end} #{i.name}.")
			count += 1
			break
		end #end
	end #for
	
	if count < 1
		puts("You aren't carrying a#{if $vowels.include?(arguments[1][0]) then 'n' end} #{arguments[1]}.")
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
	
	#make sure user isn't trying to put an item inside itself
	if arguments[1] == arguments[targetIndex] then
		puts("You can't put an item inside itself!")
		return
	end
	
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
		puts("You are not carrying a#{if $vowels.include?(arguments[1][0]) then 'n' end} #{arguments[1]}.")
		return
	elsif !contRoom and !contInv
		puts("There is no #{arguments[targetIndex]} here.")
		return
	end #if

	#is the object actually a container? If not, then say so and return
	if contRoom then
		if $map.rooms[$currentRoom].items[contIndex].class != Container then
			puts("That is not a container.")
			return
		end
	elsif contInv then
		if $player.inventory[contIndex].class != Container then
			puts("That is not a container.")
			return
		end
	end

	#if the container is closed, tell the user they must open it first
	if contInv 
		if !$player.inventory[contIndex].isOpen then
			puts("You must open the #{arguments[targetIndex]} before you can put anything in it.")
			return
		end
	end	
	if contRoom
		if !$map.rooms[$currentRoom].items[contIndex].isOpen then
			puts("You must open the #{arguments[targetIndex]} before you can put anything in it.")
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
	
	#is the object actually a container? If not, then say so and return
	if contRoom then
		if $map.rooms[$currentRoom].items[contIndex].class != Container then
			puts("That is not a container.")
			return
		end
	elsif contInv then
		if $player.inventory[contIndex].class != Container then
			puts("That is not a container.")
			return
		end
	end

	#if the container is closed, tell the user they must open it first
	if contInv 
		if !$player.inventory[contIndex].isOpen then
			puts("You must open the #{arguments[targetIndex]} before you can take anything out of it.")
			return
		end
	end	
	if contRoom
		if !$map.rooms[$currentRoom].items[contIndex].isOpen then
			puts("You must open the #{arguments[targetIndex]} before you can take anything out of it.")
			return			
		end
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
			puts("There is a#{if $vowels.include?(i.name[0]) then 'n' end} #{i.name} here.")
		end
	end
end

def attack(inputArgs)

	potentialTargets = []
	count = 0
	#search for creatures in the room and build an array of them
	for i in $population.creatures
		if i.location == $currentRoom then potentialTargets << i end
	end
	
	if potentialTargets.length < 1 then
		puts("There are no creatures here!")
		return
	end
	target = nil
	for i in potentialTargets
		if i.name.downcase() == inputArgs[1]
			target = i
			count += 1
		end
	end
	if count == 0
		puts("There is no #{inputArgs[1]} here.")
		return
	end
	$player.attack(target)
	return
end #Attack

def wield(arguments)
	count = 0
	#first make sure the player is carrying what they want to equip
	for i in $player.inventory
		if i.name.downcase() == arguments[1] then
			#is it a weapon?
			if i.class != Weapon then
				puts("That is not a weapon!")
			else
				$player.inventory << $player.weapon #copy currently wielded weapon to inventory
				$player.weapon = i #set weapon to be i
				$player.inventory.delete(i) #remove i from inventory
				puts("You wield the #{i.name}.")
			end
			count += 1 #track that something was moved
			break
		end
	end
	
	if count == 0 then
		puts("You are not carrying a#{if $vowels.include?(arguments[1][0]) then 'n' end} #{arguments[1]}")
		return
	end
end #wield

def wear(arguments)
	count = 0
	#first make sure the player is carrying what they want to wear
	for i in $player.inventory
		if i.name.downcase() == arguments[1] then
			#is it armor?
			if i.class != Armor then
				puts("You can't wear that!")
			else
				$player.inventory << $player.armor #copy currently wielded weapon to inventory
				$player.armor = i #set weapon to be i
				$player.inventory.delete(i) #remove i from inventory
				puts("You wear the #{i.name}.")
			end
			count += 1 #track that something was moved
			break
		end
	end
	
	if count == 0 then
		puts("You are not carrying a#{if $vowels.include?(arguments[1][0]) then 'n' end} #{arguments[1]}")
		return
	end
end #wear()

def open(arguments)
	present = false
	#how many arguments did the player supply?
	if arguments.length < 2 then
		puts("Please specify what you would like to open.")
		return
	elsif arguments.length > 2 then
		puts("I can't make any sense of what you're saying.")
		return
	end
	#is the item in the player's inventory?
	for i in $player.inventory
		if i.name.downcase() == arguments[1]
			#is it a door or a container?
			if i.class != Container and i.class != Door then
				puts("You cannot open that.")
				return
			else
				i.open
			end
			present = true
		end
	end
	
	#is the item in the room?
	for i in $map.rooms[$currentRoom].items
		if i.name.downcase() == arguments[1]
			#is it a door or a container?
			if i.class != Container and i.class != Door then
				puts("You cannot open that.")
				return
			else
				i.open
			end
			present = true
		end
	end
	
	if !present then
		puts("There is no #{arguments[1]} here.")
	end
end #open()

def close(arguments)
	present = false
	#how many arguments did the player supply?
	if arguments.length < 2 then
		puts("Please specify what you would like to close.")
		return
	elsif arguments.length > 2 then
		puts("I can't make any sense of what you're saying.")
		return
	end
	
	#is the item in the player's inventory?
	for i in $player.inventory
		if i.name.downcase() == arguments[1]
			#is it a door or a container?
			if i.class != Container and i.class != Door then
				puts("You cannot close that.")
				return
			else
				i.close
			end
			present = true
		end
	end
	
	#is the item in the room?
	for i in $map.rooms[$currentRoom].items
		if i.name.downcase() == arguments[1]
			#is it a door or a container?
			if i.class != Container and i.class != Door then
				puts("You cannot close that.")
				return
			else
				i.close
			end
			present = true
		end
	end
	
	if !present then
		puts("There is no #{arguments[1]} here.")
	end
end #close()

def unlock(args)
	#This is the version of the unlock method that is called if the player uses the format
	# "unlock {target} with {key}
	#Are there enough arguments? Three is the minimum required
	if args.length < 3 then
		puts("You must specify both the item to be unlocked and the key to use.")
		return
	end
	
	#Did the player insert a "with" in the command? If so, index 3 is our key
	if args[2] == "with" then
		keyIndex = 3
	else
		keyIndex = 2
	end
	
	#Does the player actually have the key in his inventory?
	count = -1
	keyInvIndex = -1
	for i in $player.inventory
		count += 1
		if i.name.downcase() == args[keyIndex] then
			keyInvIndex = count
		end
	end
	
	if keyInvIndex == -1 then
		puts("You aren't carrying a#{if $vowels.include?(args[keyIndex][0]) then 'n' end} #{args[keyIndex]}.")
		return
	end
	
	#Is the item to be unlocked present? Check inventory first, and then check the room
	for i in $player.inventory
		if i.name.downcase() == args[1] then
			#is it a door or a container?
			if i.class != Container and i.class != Door then
				puts("You cannot unlock that.")
				return
			else
				i.unlock($player.inventory[keyInvIndex])
				return
			end
		end
	end
	
	for i in $map.rooms[$currentRoom].items
		if i.name.downcase() == args[1] then
			#is it a door or a container?
			if i.class != Container and i.class != Door then
				puts("You cannot unlock that.")
				return
			else
				i.unlock($player.inventory[keyInvIndex])
				return
			end
		end
	end
	
end #unlock

def lock(args)
	#This is the version of the lock method that is called if the player uses the format
	# "lock {target} with {key}
	#Are there enough arguments? Three is the minimum required
	if args.length < 3 then
		puts("You must specify both the item to be locked and the key to use.")
		return
	end
	
	#Did the player insert a "with" in the command? If so, index 3 is our key
	if args[2] == "with" then
		keyIndex = 3
	else
		keyIndex = 2
	end
	
	#Does the player actually have the key in his inventory?
	count = -1
	keyInvIndex = -1
	for i in $player.inventory
		count += 1
		if i.name.downcase() == args[keyIndex] then
			keyInvIndex = count
		end
	end
	
	if keyInvIndex == -1 then
		puts("You aren't carrying a#{if $vowels.include?(args[keyIndex][0]) then 'n' end} #{args[keyIndex]}.")
		return
	end
	
	#Is the item to be locked present? Check inventory first, and then check the room
	for i in $player.inventory
		if i.name.downcase() == args[1] then
			#is it a door or a container?
			if i.class != Container and i.class != Door then
				puts("You cannot lock that.")
				return
			elsif i.isOpen then
				puts("You must close that first.")
				return
			else
				i.lock($player.inventory[keyInvIndex])
				return
			end
		end
	end
	
	for i in $map.rooms[$currentRoom].items
		if i.name.downcase() == args[1] then
			#is it a door or a container?
			if i.class != Container and i.class != Door then
				puts("You cannot lock that.")
				return
			elsif i.isOpen then
				puts("You must close that first.")
				return
			else 
				i.lock($player.inventory[keyInvIndex])
				return
			end
		end
	end
end #lock

#def use(args)
#	#function to allow the use of an item on another item.
#	#First determine the class of the target object, then use a switch to determine
#	#how to handle the command
#	case args[1].class
#		when Key
#			#Obviously the player is trying to unlock something. Go to unlock.
#			unlock_use(args)
#			return false
#		when Fuel
#			#The player is trying to refuel something
#			refuel(args)
#			return false
#		else
#			puts("I'm no so sure you can use that in the way you want to.")
#			return false
#end #use()

def refuel(args)
	#This is the version of the refuel method that is called if the player uses the format
	# "refuel {target} with {fuel}
	#Are there enough arguments? Three is the minimum required
	if args.length < 3 then
		puts("You must specify both the item to be refueled and the fuel to use.")
		return
	end
	
	#Did the player insert a "with" in the command? If so, index 3 is our key
	if args[2] == "with" then
		fuelIndex = 3
	else
		fuelIndex = 2
	end
	
	#Does the player actually have the fuel in his inventory? If do, remember the index
	#that it occurs at so it can be referenced later
	count = -1
	for i in $player.inventory
		count += 1
		if i.name.downcase() == args[fuelIndex] then
			fuelIndexPlayer = count
			break
		end
	end
	
	if count == -1 then
		puts("You aren't carrying any #{args[fuelIndex]}.")
		return
	end
	
	#Is the item to be refueled present? Check inventory first, and then check the room
	for i in $player.inventory
		if i.name.downcase() == args[1] then
			#Is it actually something that can be refueled?
			if i.class != Light then
				puts("You can't refuel that.")
				return
			else
				i.refuel($player.inventory[fuelIndexPlayer])
				return
			end
		end
	end
	
	for i in $map.rooms[$currentRoom].items
		if i.name.downcase() == args[1] then
			#Is it actually something that can be refueled?
			if i.class != Light then
				puts("You can't refuel that.")
				return
			else
				i.refuel($player.inventory[fuelIndexPlayer])
				return
			end
		end
	end
	
	#If the program has gotten here, then the item to be refueled was not found.
	puts("There is no #{@args[1]} here.\n")
	return
end #refuel

def light(args)
	#Takes arguments in the form "light {target}"
	#Searches player inventory and room contents for item by name
	#If it finds the item, test to see if it is actually a light
	#If so, run the function as {target}.turnOn
	
	#Does the command have the correct number of arguments? 2 is the only acceptable number
	if args.length != 2 then
		puts("What are you trying to light?")
		return
	end
	
	#First look through the player's inventory
	for i in $player.inventory
		if i.name.downcase() == args[1] then
			if i.class != Light then
				puts("You cannot light that.")
				return
			end
			i.turnOn
			return
		end
	end
	
	#Next, look through the room's contents
	for i in $map.rooms[$currentRoom].items
		if i.name.downcase() == args[1] then
			if i.class != Light then
				puts("You cannot light that.")
				return
			end
			i.turnOn
			return
		end
	end
	
	#If the program gets to this point, it has not found the item to be lit.
	puts("There are no #{@args[1]} here.\n")
	return
end #light
	
def extinguish(args)
	#Takes arguments in the form "extinguish {target}"
	#Searches player inventory and room contents for item by name
	#If it finds the item, test to see if it is actually a light
	#If so, run the function as {target}.turnOff
	
	#Does the command have the correct number of arguments? 2 is the only acceptable number
	if args.length != 2 then
		puts("What are you trying to extinguish?")
		return
	end
	
	#First look through the player's inventory
	for i in $player.inventory
		if i.name.downcase() == args[1] then
			if i.class != Light then
				puts("You cannot extinguish that.")
				return
			end
			i.turnOff
			return
		end
	end
	
	#Next, look through the room's contents
	for i in $map.rooms[$currentRoom].items
		if i.name.downcase() == args[1] then
			if i.class != Light then
				puts("You cannot extinguish that.")
				return
			end
			i.turnOff
			return
		end
	end
	
	#If the program gets to this point, it has not found the item to be lit.
	puts("There are no #{@args[1]} here.\n")
	return
end #extinguish

def eat(args)
	#Eat command should be in the format "eat {food}"
	#First, make sure there are the appropriate number of arguments
	#Second, search inventory for specified food, and if it's present, then eat it
	#Third, search the room for specified food, and if it's present, then eat it
	
	if args.length != 2 then
		puts("Just tell me in one word what you want to eat.")
		return
	end
	
	for i in $player.inventory
		if i.name.downcase() == args[1] then
			if i.class == Food then
				i.consume
				return
			else
				puts("That is not food.")
				return
			end
		end
	end
	
	for i in $map.rooms[$currentRoom].items
		if i.name.downcase() == args[1] then
			if i.class == Food then
				i.consume
				return
			else
				puts("That is not food.")
				return
			end
		end
	end
	
	puts("There is no #{args[1]} here.")
	return
end #eat

def read(args)
	#First, make sure there are enough arguments
	#Second, Search the player's inventory for the object to be read
	#Third, search the room for the object to be read
	#In each case, make sure the object, if it is present, is a Text
	if args.length < 2 then
		puts("Please specify what you would like to read.")
		return
	elsif args.length > 2 then
		puts("I don't understand you.")
		return
	end
	
	for i in $player.inventory
		if i.name.downcase() == args[1] then
			if i.class != Text then
				puts("You can't read that.")
				return
			else
				i.read
				return
			end
		end
	end
	
	for i in $map.rooms[$currentRoom].items
		if i.name == args[1] then
			if i.class != Text then
				puts("You can't read that.")
				return
			else
				i.read
				return
			end
		end
	end
	
	#If the program gets here, then it didn't fin the object
	puts("There is no #{args[1]} here.")
end #read

def help
helptext = <<EODOC
Acceptable commands (none are case sensitive):
North, N					Northeast, NE
East, E						Southeast, SE
South, S					Southwest, SW
West, W						Northwest, NW
Up, U						Down, D
Look, L						Examine {item}
Get {item}					Drop {item}
Put {item} in {container}			Remove {item} from {container}
Inventory, I					Attack {creature}
Wield {weapon}					Wear {armor}
Open {container}				Close {container}
Lock {container/door}				Unlock {container/door}
Light {light_source}				Extinguish {light_source}
Refuel {light_source} with {fuel}		Eat {food}
Quit						Help, ?
EODOC

puts(helptext)
end #help

def parse(input)
	#if quit, set $quit to true and return true
	if input.downcase() == "quit"
		$quit = true
		return true
	end
	#convert input into an array of words, all in lower case
	inputArgs = input.downcase().split
	
	#make sure length is not zero
	if inputArgs.length < 1
		puts("Please enter a command\n")
		return
	end
	#check for directional keywords
	input = case 
		when $directions.include?(inputArgs[0])
			if go(inputArgs)
				puts("\n")
				return true
			else
				puts("You cannot go that way.\n")
				return false
			end
		#describe the room again if asked to
		when inputArgs.include?("look"), inputArgs.include?("l")
			look
			return false
		when inputArgs.include?("examine")
			examine(inputArgs[1])
			return false
		when inputArgs.include?("get")
			pickup(inputArgs)
			return false
		when inputArgs.include?("drop")
			drop(inputArgs)
			return false
		when inputArgs.include?("put")
			insert(inputArgs)
			return false
		when inputArgs.include?("remove")
			remove(inputArgs)
			return false
		when inputArgs.include?("inventory"), inputArgs.include?("i")
			$player.show_inventory
			return false
		when inputArgs.include?("attack")
			attack(inputArgs)
			return false
		when inputArgs.include?("wield")
			wield(inputArgs)
			return false
		when inputArgs.include?("wear")
			wear(inputArgs)
			return false
		when inputArgs.include?("open")
			open(inputArgs)
			return false
		when inputArgs.include?("close")
			close(inputArgs)
			return false
		when inputArgs.include?("lock")
			lock(inputArgs)
			return false
		when inputArgs.include?("unlock")
			unlock(inputArgs)
			return false
		when inputArgs.include?("refuel")
			refuel(inputArgs)
			return false
		when inputArgs.include?("light")
			light(inputArgs)
			return false
		when inputArgs.include?("extinguish")
			extinguish(inputArgs)
			return false
		when inputArgs.include?("eat")
			eat(inputArgs)
			return false
		when inputArgs.include?("read")
			read(inputArgs)
			return false
		when inputArgs.include?("help"), inputArgs[0] == "?"
			help()
			return false
		else puts("I don't understand you.\n")
			return false
	end
end #end of parse()