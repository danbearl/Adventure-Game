class Thing
	attr_accessor( :a, :b, :c, :d )
	def initialize( a, b, c, d )
		@a = a
		@b = b
		@c = c
		@d = d
	end
end #class Thing

class Thing2 < Thing
	def initialize( a, b, d )
		super( a, b, true, d)
	end
end #class Thing2

thing1 = Thing.new(1, 2, false, 4)
thing2 = Thing2.new(1, 2, 4)

puts(thing1.c)
puts(thing2.c)