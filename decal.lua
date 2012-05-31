
class "Decal" {
	parent = nil;
	buffer_size = 1024;
	current_index = 0;
	buffer = {};
}

tank_track = love.graphics.newImage("res/tank/tracks.png")

function Decal:__init(buffer_size)
   self.parent = parent
   self.buffer_size = buffer_size or 1024
   self.current_index = 0
   self.buffer = {}
end

function Decal:addTrack(x, y, angle)
   self.buffer[self.current_index + 1] = {x, y, angle}
   self.current_index = (self.current_index + 1) % self.buffer_size
end

function Decal:draw()
   for i,v in ipairs(self.buffer) do 
      love.graphics.draw(tank_track, v[1] -58 * math.cos(math.rad(v[3])), v[2] - 58 *  math.sin(math.rad(v[3])), math.rad(v[3]), 1, 1, 4, 32)
   end	
end