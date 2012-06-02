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
