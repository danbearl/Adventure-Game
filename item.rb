class Item < Thing
	attr_accessor( :weight, :size, :durability, :static )
	
	#Name & Description are obvious. Durability will come into play
	#later. Static is boolean. True means it is part of the background and cannot be
	#picked up or moved, and is also not listed with non-static items under the room
	#description. Light is boolean and indicates whether the item is a source of light
	def initialize( aName, aDescription, weight, size, durability, static)
		super( aName, aDescription )
		
		@weight = weight
		@size = size
		@durability = durability
		@static = static
		@currentDurability = @durability
		@broken = false

	end
	
	#Function to damage items
	def damage( damage )
		@currentDurability -= damage
		outputString = "#{@name} takes #{damage} points of damage!"
		if @currentDurability < 1
			@broken = true
			outputString = outputString + "#{@name} is breaks!"
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
	
	def description
		outputString = @description + "\n\n"
		return outputString
	end #description()
	

end #End of Item

class Container < Item
	attr_accessor( :contents, :capacity, :isOpen, :isLocked )
	
	#aName - string, the name of the container
	#aDescription - string, the container's description
	#weight - INT, the weight of the container
	#size - INT, the container's size
	#durability - INT, the container's durability
	#static - boolean, whether or not the container can be moved
	#capacity - INT, the amount of space that the container has inside it. Refers to the 
	#	maximum cumulative size of all	contents
	#contents - array, the items inside the container
	#isOpen - boolean, whether or not the container is currently open
	#isLocked - boolean, whether or not the container is currently locked
	#closeable - boolean, whether or not the container can be closed.
	#key - string, name of the object that will unlock/lock the container
	
	def initialize (aName, aDescription, weight, size, durability, static, capacity, contents, isOpen, isLocked, closeable, key)
	
		super(aName, aDescription, weight, size, durability, static)
		
		@capacity = capacity
		@contents = contents
		@isOpen = isOpen
		@isLocked = isLocked
		@closeable = closeable
		@key = key
		
	end #initialize
	
	def description
		outputString = @description + "\n\n"
		
		#if the container is open and contains other items, list them
		if @contents.length > 0 and @isOpen
			outputString = outputString + "Items inside the #{@name}: "
			for i in @contents
				outputString = outputString + i.name
				if i != contents.last() then outputString = outputString + ", " end
			end #for 
			outputString = outputString + "\n\n"
		end #if
		return outputString
	end #description()
	
	def open
		if @isOpen then 
			puts("The #{@name} is already open.") 
			return
		end
		if @isLocked then 
			puts("The #{@name} is locked.")
			return
		else
			@isOpen = true 
			puts("You open the #{@name}.")
			return
		end
	end #open()
	
	def close
		if !@closeable then
			puts("The #{@name} cannot be closed.")
			return
		end
		if !@isOpen then
			puts("The #{@name} is already closed.")
		else
			@isOpen = false
			puts("You close the #{@name}.")
		end
	end #close()
	
	def lock(item)
		if item.name != @key.name then
			puts("That is not the appropriate key.")
			return
		elsif @isLocked then
			puts("The #{@name} is already locked.")
			return
		else
			puts("You lock the #{@name}.")
			@isLocked = true
		end
	end #lock
	
	def unlock(item)
		if item.name != @key.name then
			puts("That is not the appropriate key.")
			return
		elsif !@isLocked then
			puts("The #{@name} is already locked.")
			return
		else
			puts("You unlock the #{@name}.")
			@isLocked = false
		end
	end #unlock
	
	def space_available
		spaceTaken = 0
		#add up the size of all items inside
		for i in @contents
			spaceTaken = spaceTaken + i.size
		end #for
		return @capacity - spaceTaken
	end #space_available
end #class Container

class Weapon < Item
	attr_accessor( :attack )
	
	def initialize(aName, aDescription, weight, size, durability, static, attack)
		super(aName, aDescription, weight, size, durability, static)
		
		@attack = attack
	end #initialize
end #class Weapon

class Armor < Item
	attr_accessor( :defense )
	
	def initialize(aName, aDescription, weight, size, durability, static, defense)
		super(aName, aDescription, weight, size, durability, static)
		
		@defense = defense

	end #initialize
end #class Weapon

class Light < Item
	attr_accessor( :isLit, :currentFuel )
	#isLit - boolean, whether or not the item is currently producing light
	#fuel - int, both the maximum and the starting amount of fuel that the light source has
	#fuelType - string, the name of the type of fuel required to refuel the item
	def initialize(aName, aDescription, weight, size, durability, static, isLit, fuel, fuelType, litDescription)
		
		super(aName, aDescription, weight, size, durability, static)
		
		@isLit = isLit
		@maxFuel = fuel
		@currentFuel = fuel
		@fuelType = fuelType
		@litDescription = litDescription
		
	end #initialize
	
	def description
		if @isLit then
			outputString = @litDescription + "\n\n"
		else
			outputString = @description + "\n\n"
		end
		
		#Describe in general terms how much fuel is left in the light
		outputString += "The #{@name} appears to be "
		if (Float(@currentFuel)/Float(@maxFuel)) >= 0.85 then
			outputString += "nearly full.\n"
		elsif (Float(@currentFuel)/Float(@maxFuel)) <= 0.84 and (Float(@currentFuel)/Float(@maxFuel)) >= 0.65 then
			outputString += "about three quarters full.\n"
		elsif (Float(@currentFuel)/Float(@maxFuel)) < 0.65 and (Float(@currentFuel)/Float(@maxFuel)) >= 0.45 then
			outputString += "about half full.\n"
		elsif (Float(@currentFuel)/Float(@maxFuel)) < 0.45 and (Float(@currentFuel)/Float(@maxFuel)) >= 0.25 then
			outputString += "about a quarter full.\n"
		elsif (Float(@currentFuel)/Float(@maxFuel)) < 0.25 and (Float(@currentFuel)/Float(@maxFuel)) > 0 then
			outputString += "almost empty.\n"
		else 
			outputString += "out of fuel.\n"
		end
		return outputString
	end #description()
	
	def turnOn
		#first determine whether or not the light is already lit.
		#second, determine if the light has enough fuel
		#if 1st is false and 2nd is true, isLit = true
		if @isLit then
			puts("The #{@name} is already lit.")
			return
		elsif @currentFuel <= 1 then
			puts("The #{@name} is out of fuel.")
			return
		else
			puts("You light the #{@name}.")
			@isLit = true
		end
	end #turnOn
	
	def turnOff
		#first determine wether or not the item is already lit
		#If so, turn it off.
		if !isLit then
			puts("The #{@name} is not lit.")
			return
		else 
			puts("You put out the #{@name}.")
			@isLit = false
		end
	end #turnOff
	
	def burn(arg)
		if @isLit then
			@currentFuel = @currentFuel - 1
			if @currentFuel < 0 then 
				@currentFuel = 0
				#if the light source is within view of the player, then print message about it burning out
				if $player.seen.include?(@id) then 
					puts("The #{@name} burns out.")
				end
				@isLit = false
			end
		end
	end #burn
	
	def refuel(source)
		#First, determine if the item requires fuel.
		#Second, determine if the source is compatible
		#Third, determine if the source has any fuel remaining
		#Fourth, replenish the light's fuel by the amount available in the source up to its maximum 
		#Fifth, reduce the source's fuel amount by the amount replenished
		if @currentFuel == @maxFuel then
			puts("The #{@name} is already completely refueled.")
			return
		elsif source.name.downcase() != @fuelType.downcase() then
			puts("That is not the correct type of fuel.")
			return
		elsif source.quantity < 1 then
			puts("The #{source.name} is depleted.")
			return
		end
		
		if (@maxFuel - @currentFuel) > source.quantity then
			ammountRestored = @maxFuel - @currentFuel
		else
			ammountRestored = source.quantity
		end

		@currentFuel += ammountRestored
		puts("You refuel the #{@name}.")
		source.deplete(ammountRestored)	
	end #refuel
end #class Light

class Fuel < Item
	attr_accessor( :quantity )
	#quantity - INT, the amount of fuel available from this source
	def initialize(aName, aDescription, size, weight, durability, static, quantity)
		super(aName, aDescription, size, weight, durability, static)
		
		@maxQuantity = quantity
		@quantity = quantity
		
	end #initialize
	
	def description
		outputString = @description + "\n\n"
		
		#Describe in general terms how much fuel is left
		outputString += "The #{@name} appears to be "
		if (Float(@quantity)/Float(@maxQuantity)) >= 0.85 then
			outputString += "nearly full.\n"
		elsif (Float(@quantity)/Float(@maxQuantity)) < 0.85 and (Float(@quantity)/Float(@maxQuantity)) >= 0.65 then
			outputString += "about three quarters full.\n"
		elsif (Float(@quantity)/Float(@maxQuantity)) < 0.65 and (Float(@quantity)/Float(@maxQuantity)) >= 0.45 then
			outputString += "about half full.\n"
		elsif (Float(@quantity)/Float(@maxQuantity)) < 0.45 and (Float(@quantity)/Float(@maxQuantity)) >= 0.25 then
			outputString += "about a quarter full.\n"
		elsif (Float(@quantity)/Float(@maxQuantity)) < 0.25 and (Float(@quantity)/Float(@maxQuantity)) > 0 then
			outputString += "almost empty.\n"
		else 
			outputString += "depleted.\n"
		end
		return outputString
	end #description
	
	def deplete(ammount)
		@quantity -= ammount
		if @quantity < 1 then
			puts("The #{@name} is depleted.")
		end
	end #deplete
end #class Fuel

class Treasure < Item
	attr_reader( :value )
	
	def initialize(aName, aDescription, size, weight, durability, static, value)
		super(aName, aDescription, size, weight, durability, static)
		
		@value = value
	end #initialize
end #class Treasure

class Food < Item
	attr_reader( :quantity )
	
	def initialize(aName, aDescription, size, weight, durability, static, quantity, consumedName, consumedDescription)
		super(aName, aDescription, size, weight, durability, static)
		
		@quantity = quantity
		@consumedName = consumedName
		@consumedDescription = consumedDescription
		@consumed = false
		
	end #initialize
	
	def consume
		if @consumed then
			puts("You've already eaten that.")
			return
		else
			puts("You eat the #{@name}.")
			@description = @consumedDescription
			@name = @consumedName
			$player.hunger += @quantity
			@quantity = 0
			@consumed = true
		end
	end #consume
end #class Food

#Doors are special containers that are always static, have no weight or size, contain nothing and are always closeable.
class Door < Container
	def initialize(aName, aDescription, isOpen, isLocked, key)
		super(aName, aDescription, 0, 0, 100, true, 0, [], isOpen, isLocked, true, key)
	end #initialize
end #class Door

class Key < Item
	def initialize(aName, aDescription)
		super(aName, aDescription, 1, 1, 1, false)
	end
end #class Key

class Text < Item
	attr_reader( :contents )
	
	def initialize( aName, aDescription, weight, size, durability, static, contents )
		super( aName, aDescription, weight, size, durability, static )
		
		@contents = contents
		@isRead = false
	end
	
	def read
		puts( contents )
		@isRead = true
	end
end #class Text