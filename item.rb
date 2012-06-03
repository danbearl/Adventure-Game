class Item < Thing
	attr_accessor( :weight, :size, :durability, :attack, :defense, :capacity, :contents, :static, :light)
	
	#Name & Description are obvious. Weight, size, capacity, and durability will come into play
	#later. Static is boolean. True means it is part of the background and cannot be
	#picked up or moved, and is also not listed with non-static items under the room
	#description. Light is boolean and indicates whether the item is a source of light
	def initialize( aName, aDescription, weight, size, durability, attack, defense, capacity, contents, static, light)
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
		@attack = attack
		@defense = defense
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
