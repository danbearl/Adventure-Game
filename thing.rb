class Thing
	attr_accessor( :description, :name )
	attr_reader( :id )
	
	@@thingCount = 0
	
	def initialize( aName, aDescription )
		@name = aName
		@description = aDescription
		
		@@thingCount += 1
		@id = @@thingCount
	end
end #End of Thing