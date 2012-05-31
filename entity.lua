class "Entity" {
	x = 0;
	y = 0;
	angle = 0;
	width = 0;
	height = 0;
	image = nil	;
}

function Entity:draw() 
	love.graphics.draw(self.image, self.x, self.y, self.angle, 1,1, self.width / 2, self.height / 2)
end

function Entity:rotate(rad)
	self.angle = self.angle + rad
end
