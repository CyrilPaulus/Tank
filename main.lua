
function love.load()
	require "class"
	require "utils"
	require "tank"
	
   background = love.graphics.newImage("res/world/grass.jpg")
   
   tank = Tank:new(0,0)
   
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
