
   require "class"
   require "utils"
   require "tank"

function love.load()


   love.audio.setDistanceModel('exponent')
   love.audio.setPosition(400, 300, 0)
   
   background = love.graphics.newImage("res/world/grass.jpg")
   
   tank = Tank:new(400, 300)
   
end

function love.update(dt)
   tank:readInput(love.keyboard.isDown("up"),
		  love.keyboard.isDown("down"),
		  love.keyboard.isDown("left"),
		  love.keyboard.isDown("right"),
		  love.mouse.isDown("l"),
		  love.mouse.isDown("r"))
   tank:lookAt(love.mouse.getX(), love.mouse.getY())
   tank:update(dt)
end

function love.draw()
   love.graphics.draw(background, 0, 0)
   tank:draw()
end
