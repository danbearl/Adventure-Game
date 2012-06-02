#Population class will act as a container for all of the creatures in the game
class Population
	attr_accessor( :creatures )
	
	def initialize( someCreatures )
		@creatures = someCreatures
	end
end
