Entity = class("Entity")

function Entity:initialize()
	self.x = 0
	self.y = 0
	self.angle = 0
	self.width = 0
	self.height = 0
	self.image = nil
	self.parent = nil
	self.hasParent = false
	self.offsetX = 0
	self.offsetY = 0
	self.parentOffsetX = 0
	self.parentOffsetY = 0
end

function Entity:draw() 
	love.graphics.draw(self.image, self.x, self.y, self.angle, 1,1, self.offsetX, self.offsetY)
end

function Entity:rotate(rad)
	self.angle = self.angle + rad
end

function Entity:setParent(parent, offsetX, offsetY)
	self.parent = parent
	if(parent ~= nil) then
		self.hasParent = true
		self.parentOffsetX = offsetX or 0
		self.parentOffsetY = offsetY or 0
	else
		self.hasParent = false
	end
end

function Entity:update(dt)
	if (self.hasParent) then
		local offsetX, offsetY = rot(self.parentOffsetX, self.parentOffsetY, self.parent.angle)
		self.x = self.parent.x + offsetX
		self.y = self.parent.y + offsetY
	end
end
