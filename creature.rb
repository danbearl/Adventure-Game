class Creature < Thing
	attr_accessor( :health, :attack, :defense, :loot, :static, :hostile, :location)
	
	#Health, attack & defense are all ints; loot is an array of items; static & hostile are boolean
	#location is an int that corresponds with the index location in $maps.rooms that corresponds to the
	#room in which the creature is
	def initialize(aName, aDescription, health, attack, defense, loot, static, hostile, location)
		super(aName, aDescription)
		
		@health = health
		@attack = attack
		@defense = defense
		@loot = loot
		@static = static
		@hostile = hostile
		@location = location
		
	end
	
	#Act is run for each creature at each pass to determine its actions
	def act
		#If the creature is hostile and the player is in the same room, it will attack the player
		if hostile and $currentRoom == location
			attack
		#The Second thing a creature can do is move. If it is not static, it has a 50%
		#chance of moving to another adjacent room		
		elsif !@static
			if ((rand(100)+1)>50)
				move
			end
		end
	end
	
	#The creature's attack method
	def attack
		puts("#{@name} attacks you!")
		hitStrength = 2* (rand(@attack))
		$player.hit(hitStrength)
	end
	
	def hit( attackValue )
		if !@hostile then @hostile = true end
		if attackValue > @defense
			puts("The attack hits for #{attackValue - @defense} points of damage!")
			damage(attackValue - @defense)
		elsif
			puts("The attack misses!")
		end
	end
	
	
	def damage(dmg)
		@health = @health - dmg
		if @health < 1
			puts("You kill the #{name}!")
			
			#dump all of the creature's loot into the room
			if @loot.length > 0
				for i in @loot
					puts("The #{name} drops a #{i.name}!")
					$map.rooms[@location].items << i
				end
			end
			@location = 0
		end
	end
	
	#The creature's move method!
	def move
		exits = []
		#Determine which exits are available. Build an array of possible exits
		if $map.rooms[@location].north.to_i > -1 then exits << "north" end
		if $map.rooms[@location].northeast.to_i > -1 then exits << "northeast" end
		if $map.rooms[@location].east.to_i > -1 then exits << "east" end
		if $map.rooms[@location].southeast.to_i > -1 then exits << "southeast" end
		if $map.rooms[@location].south.to_i > -1 then exits << "south" end
		if $map.rooms[@location].southwest.to_i > -1 then exits << "southwest" end
		if $map.rooms[@location].west.to_i > -1 then exits << "west" end
		if $map.rooms[@location].northwest.to_i > -1 then exits << "northwest" end
		if $map.rooms[@location].up.to_i > -1 then exits << "up" end
		if $map.rooms[@location].down.to_i > -1 then exits << "down" end
		
		#Randomly choose one exit
		if exits.length > 0 then moved = true end
		r = rand(exits.length)
		
		#If the creature started in the same room as the player, tell the player about the move
		if @location == $currentRoom then
			puts("#{@name} leaves to the #{exits[r]}.")
		end
		#Set the creature's location to the chose exit's target location
		case( exits[r] )
			when "north" then @location = $map.rooms[@location].north
			when "northeast" then @location = $map.rooms[@location].northeast
			when "east" then @location = $map.rooms[@location].east
			when "southeast" then @location = $map.rooms[@location].southeast
			when "south" then @location = $map.rooms[@location].south
			when "southwest" then @location = $map.rooms[@location].southwest
			when "west" then @location = $map.rooms[@location].west
			when "northwest" then @location = $map.rooms[@location].northwest
			when "up" then @location = $map.rooms[@location].up
			when "down" then @location = $map.rooms[@location].down
		end
		#If the creature arrives in the same room as the player, tell the player
		if @location == $currentRoom then
			puts("#{@name} arrives.")
		end	
	end
end #Creature
