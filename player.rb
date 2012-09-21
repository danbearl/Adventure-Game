class Player
	attr_accessor( :name, :inventory, :weapon, :armor, :health, :attack, :defense, :maxHealth, :hunger, :seen)
	
	def initialize( aName, someItems, weapon, armor, health, attack, defense )
		@name = aName
		@inventory = someItems
		@capacity = 30
		@health = health
		@attack = attack
		@defense = defense
		@maxHealth = health
		@weapon = weapon
		@armor = armor
		@hunger = 100
		@seen = [] #An array that holds the ID of all things that can be seen by the player
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

	def hit( attackValue )
		if attackValue > @defense + @armor.defense
			puts("You are hit for #{attackValue - @defense} points of damage!")
			damage(attackValue - (@defense + @armor.defense))
		elsif
			puts("The attack misses!")
		end
	end
	
	def damage(dmg)
		@health = @health - dmg
		if @health < 1
			puts("You are dead!")
			$quit = true
		end
	end
	
	def heal(dmg)
		@health += dmg
		if @health > @maxHealth then @health = @maxHealth end
		puts("You are healed for #{dmg} points!")
	end
	
	def show_inventory
			puts("\nYou are carrying:")
			for i in $player.inventory
				puts(i.name)
			end #for
			puts("Weapon: #{$player.weapon.name}\n")
			puts("Armor: #{$player.armor.name}\n")
			puts("Inventory space left: #{$player.space_available}")
	end
	
	def attack(target)
		puts("You attack the #{target.name}")
		hitStrength = 2*(rand(@attack + @weapon.attack)+1) 
		target.hit(hitStrength)
	end
end #End of Player
