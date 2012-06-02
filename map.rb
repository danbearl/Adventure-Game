class Map < Thing
	attr_accessor( :rooms )
	
	def initialize( someRooms )
		@rooms = someRooms
	end
end #end of Map