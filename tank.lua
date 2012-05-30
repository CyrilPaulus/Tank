Tank = class:new()


tank_base = love.graphics.newImage("res/tank/tank_base.png")
tank_smoke = love.graphics.newImage("res/tank/smoke.png")

function Tank:init(x, y)
	self.height = 64
	self.width = 128
	self.x = x
	self.y = y
	self.angle = 0
	self.image = tank_base
	self.speed = 0
	self.maxSpeed = 100
	self.maxRearSpeed = 50
	self.acceleration = 10
	self.deceleration = 60
	self.rotSpeed = 20
	self.turret = TankTurret:new(self)
	
	self.particleLeft = love.graphics.newParticleSystem(tank_smoke, 128)
	self.particleLeft:setEmissionRate(10)
	self.particleLeft:setLifetime              (1)
	self.particleLeft:setParticleLife          (4)		
	self.particleLeft:setSpread                (2)
	self.particleLeft:setSpeed                 (10, 30)	
	self.particleLeft:setSizeVariation         (1)
	self.particleLeft:setSizes(0.5, 0.8)
	self.particleLeft:setColors(50,50,50,255,180,180,180,255)
	self.particleLeft:stop()
	
	self.particleRight = love.graphics.newParticleSystem(tank_smoke, 128)
	self.particleRight:setEmissionRate(10)
	self.particleRight:setLifetime              (1)
	self.particleRight:setParticleLife          (4)		
	self.particleRight:setSpread                (2)
	self.particleRight:setSpeed                 (10, 30)	
	self.particleRight:setSizeVariation         (1)
	self.particleRight:setSizes(0.5, 0.8)
	self.particleRight:setColors(50,50,50,255,180,180,180,255)
	self.particleRight:stop()
	
	self.track = TankTrack:new(self)
	self.forward = false
	self.backward = false
	self.left = false
	self.right = false

end

function Tank:readInput(f, b, l, r)
	self.forward = f
	self.backward = b
	self.left = l
	self.right = r
end

function Tank:update(dt)
	
	self.particleLeft:setDirection(math.rad(self.angle - 180))
	self.particleRight:setDirection(math.rad(self.angle - 180))
	self.particleLeft:start()	
	self.particleRight:start()	
	if (self.forward) then
		if(self.speed < 0) then
			self.speed = math.min(self.speed + self.deceleration * dt, self.maxSpeed)
		else
			self.speed = math.min(self.speed + self.acceleration * dt, self.maxSpeed)
		end
	elseif (self.backward) then
		if(self.speed > 0) then
			self.speed = math.max(self.speed - self.deceleration * dt, -self.maxRearSpeed)
		else
			self.speed = math.max(self.speed - self.acceleration * dt, -self.maxRearSpeed)
		end
	else 
		self.particleLeft:pause()
		self.particleRight:pause()
		if(math.abs(self.speed) < self.deceleration * dt) then	
			self.speed = 0
		elseif (self.speed > 0) then
			self.speed = self.speed - self.deceleration * dt
		elseif (self.speed < 0) then
			self.speed = self.speed + self.deceleration * dt
		end
	end
	

	
	if(self.left) then
		self.particleLeft:start()	
		self.particleRight:start()	
		self:rotate(self.rotSpeed * -dt)
	end
	
	if(self.right) then
		self.particleLeft:start()	
		self.particleRight:start()	
		self:rotate(self.rotSpeed * dt)
	end
	
	self.turret:update(dt)
	
	x,y = rot(-58, -10, math.rad(self.angle))
	self.particleLeft:setPosition(self.x + x, self.y + y)	
	self.particleLeft:update(dt)
	
	x,y = rot(-58, 10, math.rad(self.angle))
	self.particleRight:setPosition(self.x + x, self.y + y)
	self.particleRight:update(dt)
	
	self.track:add()
	

	
	self.x = self.x + math.cos(math.rad(self.angle)) * self.speed * dt
	self.y = self.y + math.sin(math.rad(self.angle)) * self.speed * dt
end

function Tank:draw()
	self.track:draw()
	love.graphics.draw(tank_base, self.x, self.y, math.rad(self.angle), 1,1, self.width / 2, self.height / 2)	
	self.turret:draw()
	love.graphics.draw(self.particleLeft)
	love.graphics.draw(self.particleRight)
	
end

function Tank:rotate(deg)
	self.angle = math.fmod(self.angle + deg, 360)
	self.turret:rotate(deg)
end


TankTurret = class:new()

tank_turret = love.graphics.newImage("res/tank/tank_turret.png")

function TankTurret:init(parent)
	self.x = parent.x
	self.y = parent.y
	self.parent = parent
	self.height = 64
	self.width = 128
	self.angle = 0
	self.bullets = {}
	self.firedelay = 0.5
	self.firecounter = 0
	self.cannon = true
end

function TankTurret:update(dt)
	self.firecounter = self.firecounter + dt
	self.x = self.parent.x
	self.y = self.parent.y
	mouseX = love.mouse.getX()
	mouseY = love.mouse.getY()
	self.angle = math.deg(math.atan2(mouseX - self.x, -(mouseY - self.y))) - 90
	
	if(love.mouse.isDown("l") and self.firecounter > self.firedelay) then
		if (self.cannon) then
			x, y = rot(90, 6, math.rad(self.angle))
		else
			x, y = rot(90, -6, math.rad(self.angle))
		end
		self.cannon = not self.cannon
		table.insert(self.bullets, TankBullet:new(self, self.x + x, self.y + y))
		self.firecounter = 0
	end
	
	for i,v in ipairs(self.bullets) do
		if(v:update(dt)) then
			table.remove(self.bullets, i)
		end
	end
	
	
end

function TankTurret:draw()
	love.graphics.draw(tank_turret, self.x, self.y, math.rad(self.angle), 1,1, 39, 31.5)
	for i,v in ipairs(self.bullets) do
		v:draw()
	end	
	
	love.graphics.print( #self.bullets, 100, 100)
end

function TankTurret:rotate(deg)
	self.angle = math.fmod(self.angle + deg, 360)
end


TankTrack = class:new()

tank_track = love.graphics.newImage("res/tank/tracks.png")

function TankTrack:init(parent, buffer_size)
	self.parent = parent
	self.buffer_size = buffer_size or 1024
	self.current_index = 0
	self.last_post = {0, 0}
	self.buffer = {}
	self.height = 64
	self.width = 8
end

function TankTrack:add()
	if( (self.last_post[1] - self.parent.x)^ 2 + (self.last_post[2] - self.parent.y)^ 2 > 64) then
		self.last_post[1] = self.parent.x
		self.last_post[2] = self.parent.y
		self.buffer[self.current_index + 1] = {self.parent.x, self.parent.y, self.parent.angle}
		self.current_index = (self.current_index + 1) % self.buffer_size
	end
end

function TankTrack:draw()
	for i,v in ipairs(self.buffer) do 
		love.graphics.draw(tank_track, v[1] -58 * math.cos(math.rad(v[3])), v[2] - 58 *  math.sin(math.rad(v[3])), math.rad(v[3]), 1, 1, 4, 32)
	end	
end

TankBullet = class:new()

tank_bullet = love.graphics.newImage("res/tank/bullet.png")

function TankBullet:init(parent, x, y) 
	self.parent = parent
	self.angle = parent.angle
	self.x = x or parent.x + math.cos(math.rad(self.angle)) * 80
	self.y = y or parent.y + math.sin(math.rad(self.angle)) * 80
	
	self.speed = 250
	self.lifetime = 10
	self.time = 0
end

function TankBullet:update(dt)
	self.x = self.x + math.cos(math.rad(self.angle)) * self.speed * dt
	self.y = self.y + math.sin(math.rad(self.angle)) * self.speed * dt
	
	self.time = self.time + dt
	if self.time > self.lifetime then
		return true
	else
		return false
	end
end

function TankBullet:draw() 
	love.graphics.draw(tank_bullet, self.x, self.y, math.rad(self.angle), 0.5, 0.5, 16, 8)
end
