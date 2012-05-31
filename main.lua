
   require "class"
   require "utils"
   require "decal"
   require "tank"

function love.load()


   love.audio.setDistanceModel('exponent')
   love.audio.setPosition(400, 300, 0)
   
   background = love.graphics.newImage("res/world/grass.jpg")
   globalDecals = Decal:new(1024)
   tank = {}
   for j=32,568,64 do
      for i=64,736,128 do
	 table.insert(tank, Tank:new(i, j))
      end
   end
   
   
end

function love.update(dt)
   for i,v in ipairs(tank) do
      v:readInput(love.keyboard.isDown("up"),
		     love.keyboard.isDown("down"),
		     love.keyboard.isDown("left"),
		     love.keyboard.isDown("right"),
		     love.mouse.isDown("l"),
		     love.mouse.isDown("r"))
      v:lookAt(love.mouse.getX(), love.mouse.getY())
      v:update(dt)
   end
end

function love.draw()
   love.graphics.draw(background, 0, 0)
   globalDecals:draw()
   for i,v in ipairs(tank) do
      v:draw()
   end
end
