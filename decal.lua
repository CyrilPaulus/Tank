
Decal = class("Decal")

tank_track = love.graphics.newImage("res/tank/tracks.png")

function Decal:initialize(buffer_size)
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
      love.graphics.draw(tank_track, v[1] -58 * math.cos(v[3]), v[2] - 58 *  math.sin(v[3]),v[3], 1, 1, 4, 32)
   end	
end