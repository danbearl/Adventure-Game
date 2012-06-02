class Room < Thing
	attr_accessor( :north, :northeast, :east, :southeast, :south, :southwest, :west, :northwest, :up, :down )
	attr_accessor( :light, :items )
	
	#initialize room object. aName & aDescription are strings. Directions are string value
	#showing the target room for that direction. A value of -1 indicates no exit in 
	#that direction. aLight is boolean indicating whether the room has natural lighting
	def initialize( aName, aDescription, n, ne, e, se, s, sw, w, nw, u, d, aLight, someItems )
		super( aName, aDescription )
		@north = n
		@northeast = ne
		@east = e
		@southeast = se
		@south = s
		@southwest = sw
		@west = w
		@northwest = nw
		@up = u
		@down = d
		@light = aLight
		@items = someItems
	end
	
	def description
		#First, determine if there is enough light to see
		#Is the player carrying any light emitting objects?
		#Start with playerLight false, then cycle through each item. If even on item is
		#a light source, change to true
		playerLight = false
		for i in $player.inventory
			if i.light == true then playerLight = true end
		end #for
		
		#are there any items laying on the ground that are sources of light?
		itemLight = false
		for i in $map.rooms[$currentRoom].items
			if i.light == true then itemLight = true end
		end #for
		
		if @light == false and playerLight == false and itemLight == false
			return "It is too dark here for you to see anything."
		end #if
		
		#build outputString by removing any control characters from the end of @description
		@outputString = @description.chomp 
		#add items, if any
		#build an array of all non-static items
		nonStaticItems = []
		for i in @items
			if !i.static
				nonStaticItems << i
			end #if
		end #for
		if nonStaticItems.length > 0
			@outputString = @outputString + "\n\nItems here: "
			for i in nonStaticItems
				@outputString = @outputString + i.name
				if i != nonStaticItems.last
					@outputString = @outputString + ", "
				end #if
			end #for
			@outputString = @outputString
		end #if
		for i in $population.creatures
			if i.location == $currentRoom
				@outputString = @outputString +"\nThere is a #{i.name} here."
			end
		end
		#and add exits.
		@outputString =  @outputString + "\n\nObvious Exits: "
		if @north != -1
			@outputString = @outputString + "North"
		end
		
		#if preceding direction is true, offset with comma
		if @northeast != -1 and @north != -1
			@outputString = @outputString + ", Northeast"
		elsif @northeast != -1 #if preceding direction is not true, do not add comma
			@outputString = @outputString + "Northeast"
		end
		
		if @north != -1 or @northeast != -1 and @east != -1
			@outputString = @outputString + ", East"
		elsif @east != -1
			@outputString = @outputString + "East"
		end
		
		if @north != -1 or @northeast != -1 or @east != -1 and @southeast != -1
			@outputString = @outputString + ", Southeast"
		elsif @southeast != -1
			@outputString = "Southeast"
		end
		
		if @north != -1 or @northeast != -1 or @east != -1 or @southeast != -1 and @south != -1
			@outputString = @outputString + ", South"
		elsif @south != -1
			@outputString = @outputString + "South"
		end
		#
		if @north != -1 or @northeast != -1 or @east != -1 or @southeast != -1 or @south != -1 and @southwest != -1
			@outputString = @outputString + ", Southwest"
		elsif @southwest != -1
			@outputString = @outputString + "Southwest"
		end
		
		if @north != -1 or @northeast!= -1 or @east!= -1 or @southeast!= -1 or @south!= -1 or @southwest!= -1 and @west!= -1
			@outputString = @outputString + ", West"
		elsif @west!= -1
			@outputString = @outputString + "West"
		end
		
		if @north!= -1 or @northeast!= -1 or @east!= -1 or @southeast!= -1 or @south!= -1 or @southwest!= -1 or @west!= -1 and @northwest!= -1
			@outputString = @outputString + ", Northwest"
		elsif @northwest!= -1
			@outputString = @outputString + "Northwest"
		end

		if @north!= -1 or @northeast!= -1 or @east!= -1 or @southeast!= -1 or @south!= -1 or @southwest!= -1 or @west!= -1 or @northwest!= -1 and @up != -1
			@outputString = @outputString + ", Up"
		elsif @up!= -1
			@outputString = @outputString + "Up"
		end

		if @north!= -1 or @northeast!= -1 or @east!= -1 or @southeast!= -1 or @south!= -1 or @southwest!= -1 or @west!= -1 or @northwest!= -1 or @up != -1 and @down != -1
			@outputString = @outputString + ", Down"
		elsif @down != -1
			@outputString = @outputString + "Down"
		end
					
		if @north==-1 and @northeast==-1 and @east==-1 and @southeast==-1 and @south==-1 and @southwest==-1 and @west==-1 and @northwest==-1 and @up==-1 and @down==-1
			@outputString = @outputString + "None"
		end
		
		return @outputString
	end #End of Room.description
end #End of Room
