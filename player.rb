class Player
	attr_accessor( :name, :inventory, :health, :attack, :defense)
	
	def initialize( aName, someItems, health, attack, defense )
		@name = aName
		@inventory = someItems
		@capacity = 30
		@health = health
		@attack = attack
		@defense = defense
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
