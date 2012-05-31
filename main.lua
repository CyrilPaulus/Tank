

function love.load()
   require "middleclass"
   require "utils"
   require "entity"
   require "decal"
   require "tank"
   require "bulletSystem"

   love.audio.setDistanceModel('exponent')
   love.audio.setPosition(400, 300, 0)
   
   background = love.graphics.newImage("res/world/grass.jpg")
   globalDecals = Decal:new(1024)
   bulletSystem = BulletSystem:new()
   entities = {}
   player = Tank:new(0,0)
   table.insert(entities, player)
end

function love.update(dt)
   player:readInput(love.keyboard.isDown("up"),
		    love.keyboard.isDown("down"),
		    love.keyboard.isDown("left"),
		    love.keyboard.isDown("right"),
		    love.mouse.isDown("l"),
		    love.mouse.isDown("r"))
   player:lookAt(love.mouse.getX(), love.mouse.getY())
   for i,v in ipairs(entities) do
      v:update(dt)
   end
   bulletSystem:update(dt)
end

function love.draw()
   love.graphics.draw(background, 0, 0)
   globalDecals:draw()
   for i,v in ipairs(entities) do
      v:draw()
   end
   bulletSystem:draw()
end
