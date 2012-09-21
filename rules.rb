class Rules

	def initialize
		@flag1 = false #Secret door in room1
		@flag2 = false #Player in dark room
		@flag3 = true #Player needs food
		@flag4 = true #light sources consume fuel while lit
		@flag5 = true #The player can see
		@darkCount = 0 #Number of turns a player has spent in the dark
	end
	def self.rules() {	0 => :room0, 
						1 => :room1, 
						2 => :room2,
						3 => :room3,
						4 => :room4,
						5 => :room5,
						6 => :room6,
						7 => :room7,
						8 => :room8,
						9 => :room9,
						10 => :room10,
						11 => :room11,
						12 => :room12,
						13 => :room13,
						14 => :room14,
						15 => :room15,
						16 => :room16,
						17 => :room17,
						18 => :room18} end
						
	def universal
		#First Universal Rule: If a player spends more than 5 rounds in the dark, they 
		#will have a fatal mishap
		if !$map.rooms[$currentRoom].light
			light = false
			for i in $map.rooms[$currentRoom].items #If no ambient light, check room items
				if i.class == Light then
					if i.isLit then light = true end
				end
			end
			for i in $player.inventory #Also check inventory
				if i.class == Light then
					if i.isLit then light = true end
				end
				@flag2 = false
				count = 0
			end
			
			#if flag2 is not already true and there is no light in the room, make it so
			if !@flag2 and !light
				@flag2 = true
			elsif @flag2 #if flag2 is already true, increment @darkCount
				@darkCount += 1
				puts("It is not wise to stumble around in the dark")
			end
			
			if @darkCount > 5
				puts("You trip in the darkness and break your neck! You are dead!")
				$quit = true
			end 
		end
		
		#If player is in a room with light, change flag2 back to false
		if $map.rooms[$currentRoom].light and @flag2 then 
			@flag2 = false 
			@darkCount = 0
		end
		#END OF FIRST UNIVERSAL RULE
		
		#Second Universal Rule: As long as flag3 is true, the player's hunger will decrease by 1
		#each turn. The player will die when hunger == 0.
		if @flag3 then
			$player.hunger -= 1
			if $player.hunger == 50 then puts("You are starting to feel hungry.") end
			if $player.hunger == 25 then puts("You are starting to feel very hungry.") end
			if $player.hunger == 10 then puts("You are starving to death.") end
			if $player.hunger <= 0 then
				puts("You die from starvation.")
				$quit = true
				return
			end
		end #END OF SECOND UNIVERSAL RULE
		
		#Third Universal Rule: As long as flag4 is true, light sources will consume fuel
		if @flag4 then
			#search for lit lights in the player's inventory, and decrement each one's fuel by one
			for i in $player.inventory
				if i.class == Light then
					if i.isLit then i.burn(1) end
				end
			end
			
			#search for lit lights in all rooms, and decrement them by 1
			for i in $map.rooms
				for j in i.items
					if j.class == Light then
						if j.isLit then j.burn(1) end
					end
				end
			end
		end #END OF THIRD UNIVERSAL RULE
		
		#Fourth Universal Rule: Keep track of all items and creatures that a player can see.
		if @flag5 then
			#First, start with an empty array
			$player.seen = []
			#Second, add the ids of all items in the room
			for i in $map.rooms[$currentRoom].items
				$player.seen << i.id
			end
			#Third, add the ids of all items in inventory
			for i in $player.inventory
				$player.seen << i.id
			end
			#Fourth, add the ids of all creatures in the room
			for i in $population.creatures
				if i.location == $currentRoom then
					$player.seen << i.id
				end
			end
		end #END OF FOURTH UNIVERSAL RULE
	end
	
	def room1
		#If the gem is placed into the fountain, a secret door opens in room1
		if $item5.contents.include?($item2)
			if !@flag1
				puts("A secret door opens to the west!")
				@flag1 = true
			end
			$map.rooms[$currentRoom].west = 5
		end
		
		#If the gem is removed from the fountain, the secret door closes
		if !$item5.contents.include?($item2) and @flag1
			puts("The secret door closes!")
			$map.rooms[$currentRoom].west = -1
			@flag1 = false
		end
	end
	
	def room2
		#if the door ($item18) is closed, then there is no exit to the north.
		#If the door is open, then there is an exit to the north.
		if $item18.isOpen then
			$map.rooms[$currentRoom].north = 6
		end
		if !$item18.isOpen then
			$map.rooms[$currentRoom].north = -1
		end
	
	end
	
	def room3
	
	end
	
	def room4
	
	end
	
	def room5
	
	end
	
	def room6
		#if the door ($item18) is closed, then there is no exit to the south.
		#If the door is open, then there is an exit to the south.
		if $item18.isOpen then
			$map.rooms[$currentRoom].south = 2
		end
		if !$item18.isOpen then
			$map.rooms[$currentRoom].south = -1
		end
	end
	
	def room7
	
	end

	def room8
	
	end	
	
	def room9
	
	end
	
	def room10
	
	end
	
	def room11
	
	end
	
	def room12
	
	end
	
	def room13
	
	end

	def room14
	
	end
	
	def room15
	
	end

	def room16
	
	end

	def room17
	
	end

	def room18
	
	end

	def check(arg)
		universal
		send self.class.rules[arg]
	end
end #Rules
