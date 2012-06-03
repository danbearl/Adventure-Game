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
		puts("I don't see a#{if $vowels.include?(itemName[0]) then 'n' end} #{itemName} here.")
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

	def move(item)
		if item.static 	#If the item is static, do not allow the player to get it
			puts("You cannot move the #{item.name}")
			return
		end
		if item.size > $player.space_available 	#If the player does not have enough space left yet, then tell the user	
			puts("You don't have enough space in your inventory for the #{item.name}")
			return
		end
		$player.inventory << item #Put in inventory
		$map.rooms[$currentRoom].items.delete(item) #Remove from room
		puts("You pick up a#{if $vowels.include?(item.name[0]) then 'n' end} #{item.name}")
		return #item.name
	end #move
	
	if arguments[1] == "all" then
		items = []
		$map.rooms[$currentRoom].items.reverse_each do |i|
			move(i)
		end
#		a = 0
#		while a < items.length
#			for i in $map.rooms[$currentRoom].items
#				if i.name == items[a]
#					$map.rooms[$currentRoom].items.delete(i)
#				end
#			end
#			a += 1
#		end
		
		return
	end
	
	#if the user did not specify a quantity, assume 1
	if arguments[2] == nil
		arguments[2] = 1
	end #if
	
	#Iterate over all of the objects in the room until the program finds one that has a name matching
	#the user's input and then move that item into the player's inventory
	$map.rooms[$currentRoom].items.reverse_each do |i|
		if i.name.downcase == arguments[1]
			move(i)
			count += 1
		end 
#		for i in $map.rooms[$currentRoom].items
#			if i.name == movedName then
#				$map.rooms[$currentRoom].items.delete(i)
#				break
#			end
#		end
	end #for
	
	if count < 1
		puts("I don't see a#{if $vowels.include?(arguments[1][0]) then 'n' end} #{arguments[1]} here.")
	end #if
end #End of pickup

def drop(arguments)
	#user should input command as 'drop ({quantity}) {item name}'
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
			puts("You drop a#{if $vowels.include?(i.name[0]) then 'n' end} #{i.name}.")
			count += 1
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
			if i.attack < 1 then
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
		puts("You are not carrying a#{if $vowels.include?(arguments[1]) then 'n' end} #{arguments[1]}")
		return
	end
end #wield

def wear(arguments)
	count = 0
	#first make sure the player is carrying what they want to wear
	for i in $player.inventory
		if i.name.downcase() == arguments[1] then
			#is it a weapon?
			if i.defense < 1 then
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
		puts("You are not carrying a#{if $vowels.include?(arguments[1]) then 'n' end} #{arguments[1]}")
		return
	end
end #wear()

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
	#check for directional keywords
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
			puts("Weapon: #{$player.weapon.name}\n")
			puts("Armor: #{$player.armor.name}\n")
			puts("Inventory space left: #{$player.space_available}")
			return false
		when inputArr.include?("attack")
			attack(inputArr)
			return false
		when inputArr.include?("wield")
			wield(inputArr)
			return false
		when inputArr.include?("wear")
			wear(inputArr)
			return false
		else puts("I don't understand you.\n")
			return false
	end
end #end of parse()