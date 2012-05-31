


tank_base = love.graphics.newImage("res/tank/tank_base.png")
tank_smoke = love.graphics.newImage("res/tank/smoke.png")

class "Tank" {
	x = 0;
	y = 0;
	angle = 0;
	width = 128;
	height = 64;
	
	image = tank_base;
	
	speed = 0;
	maxSpeed = 100;
	maxRearSpeed = 50;
	acceleration = 10;
	deceleration = 60;
	rotSpeed = 20;
	
	turret = nil;
	particleLeft = nil;
	particleRight = nil;
	
	forward = false;
	backward = false;
	left = false;
	right = false;
	
	idle_src = nil;
	
	lastPosX = 0;
	lastPosY = 0;
}

function Tank:__init(x, y)
	self.x = x
	self.y = y
  self.turret = TankTurret:new(self)
   
  self.particleLeft = love.graphics.newParticleSystem(tank_smoke, 128)
  self.particleLeft:setEmissionRate(2)
  self.particleLeft:setLifetime              (1)
  self.particleLeft:setParticleLife          (4)		
  self.particleLeft:setSpread                (2)
  self.particleLeft:setSpeed                 (10, 30)	
  self.particleLeft:setSizeVariation         (1)
  self.particleLeft:setSizes(0.5, 0.8)
  self.particleLeft:setColors(50,50,50,255,180,180,180,255)
	self.particleLeft:stop()
   
  self.particleRight = love.graphics.newParticleSystem(tank_smoke, 128)
  self.particleRight:setEmissionRate(2)
  self.particleRight:setLifetime              (1)
  self.particleRight:setParticleLife          (4)		
  self.particleRight:setSpread                (2)
  self.particleRight:setSpeed                 (10, 30)	
  self.particleRight:setSizeVariation         (1)
  self.particleRight:setSizes(0.5, 0.8)
  self.particleRight:setColors(50,50,50,255,180,180,180,255)
  self.particleRight:stop()
  
  self.idle_src = love.audio.newSource("res/tank/idle_loop.ogg")
  self.idle_src:setLooping(true)
  self.idle_src:setDistance(400,800)
  self.idle_src:play() 
end

function Tank:readInput(f, b, l, r, ml, mr)
   self.forward = f
   self.backward = b
   self.left = l
   self.right = r
   if (ml) then
      self.turret:fireMain()
   end
   
end

function Tank:update(dt)

   self.particleLeft:start()	
   self.particleRight:start()	

   self.particleLeft:setDirection(math.rad(self.angle - 180))
   self.particleRight:setDirection(math.rad(self.angle - 180))

   if(self.forward or self.backward) then
      self.particleLeft:setEmissionRate(10)
      self.particleRight:setEmissionRate(10)
      self.idle_src:setPitch(0.5 + math.abs(self.speed / self.maxSpeed))
   else
      self.particleLeft:setEmissionRate(2)
      self.particleRight:setEmissionRate(2)
      self.idle_src:setPitch(0.5)
   end

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
      if(math.abs(self.speed) < self.deceleration * dt) then	
	 self.speed = 0
      elseif (self.speed > 0) then
	 self.speed = self.speed - self.deceleration * dt
      elseif (self.speed < 0) then
	 self.speed = self.speed + self.deceleration * dt
      end
   end
   
   
   if(self.left) then
      self:rotate(self.rotSpeed * -dt)
   end
   
   if(self.right) then
      self:rotate(self.rotSpeed * dt)
   end
   
   self.turret:update(dt)
   
   x,y = rot(-58, -10, math.rad(self.angle))
   self.particleLeft:setPosition(self.x + x, self.y + y)	
   self.particleLeft:update(dt)
   
   x,y = rot(-58, 10, math.rad(self.angle))
   self.particleRight:setPosition(self.x + x, self.y + y)
   self.particleRight:update(dt)
   
   self.x = self.x + math.cos(math.rad(self.angle)) * self.speed * dt
   self.y = self.y + math.sin(math.rad(self.angle)) * self.speed * dt

   self.idle_src:setPosition(self.x, self.y, 0)

   if( (self.lastPosX - self.x)^ 2 + (self.lastPosY - self.y)^ 2 > 64) then
      self.lastPosX = self.x
      self.lastPosY = self.y
      globalDecals:addTrack(self.x, self.y, self.angle)
   end
end

function Tank:draw()
   love.graphics.draw(tank_base, self.x, self.y, math.rad(self.angle), 1,1, self.width / 2, self.height / 2)	
   self.turret:draw()
   love.graphics.draw(self.particleLeft)
   love.graphics.draw(self.particleRight)
   
end

function Tank:rotate(deg)
   self.angle = math.fmod(self.angle + deg, 360)
   self.turret:rotate(deg)
end

function Tank:lookAt(x, y) 
   self.turret:lookAt(x, y)
end

tank_turret = love.graphics.newImage("res/tank/tank_turret.png")
tank_muzzleflash = love.graphics.newImage("res/tank/muzzleflash.png")

class "TankTurret" {
	x = 0;
	y = 0;
	angle = 0;
	parent = nil;
	
	width = 128;
	height = 64;
	
	bullets = nil;
	
	firedelay = 1.5;
	firecounter = 0;
	fire = true;
	cannon = true;
	cannonX = 0;
	cannonY = 0;
	drawMuzzle = false;
	muzzleTime = 0;
	maxMuzzleTime = 0.1;
	cannon_src = nil;
}
function TankTurret:__init(parent)
   self.x = parent.x
   self.y = parent.y
	 self.bullets = {}
   self.parent = parent   
   self.cannon_src = love.audio.newSource("res/tank/cannon_shot.ogg")
   self.cannon_src:setDistance(400,800)
end

function TankTurret:lookAt(x, y) 
   self.angle = math.deg(math.atan2(x - self.x, -(y - self.y))) - 90
end				 

function TankTurret:update(dt)
   if(self.drawMuzzle) then
      self.muzzleTime = self.muzzleTime + dt
      if(self.muzzleTime > self.maxMuzzleTime) then
	 self.drawMuzzle = false
	 self.muzzleTime = 0
      end
   end
   self.firecounter = self.firecounter + dt
   self.x = self.parent.x
   self.y = self.parent.y
   
   if(self.fire and self.firecounter > self.firedelay) then
      self.drawMuzzle = true
      if (self.cannon) then
	 self.cannonX, self.cannonY = rot(90, 6, math.rad(self.angle))
      else
	 self.cannonX, self.cannonY = rot(90, -6, math.rad(self.angle))
      end
      self.cannon_src:setPosition(self.x + self.cannonX, self.y + self.cannonY, 0)
      if(not self.cannon_src:isStopped()) then
	 self.cannon_src:stop()
      end
      self.cannon_src:play()
      self.cannon = not self.cannon
      table.insert(self.bullets, TankBullet:new(self, self.x + self.cannonX, self.y + self.cannonY))
      self.firecounter = 0
   end
   
   for i,v in ipairs(self.bullets) do
      if(v:update(dt)) then
	 table.remove(self.bullets, i)
      end
   end

   
   self.fire = false
end

function TankTurret:draw()
   love.graphics.draw(tank_turret, self.x, self.y, math.rad(self.angle), 1,1, 39, 31.5)
   if(self.drawMuzzle) then
      love.graphics.draw(tank_muzzleflash, self.x + self.cannonX, self.y + self.cannonY, math.rad(self.angle), 1, 1, 15, 6)
   end
   
   for i,v in ipairs(self.bullets) do
      v:draw()
   end	
end

function TankTurret:rotate(deg)
   self.angle = math.fmod(self.angle + deg, 360)
end

function TankTurret:fireMain() 
   self.fire = true
end





tank_bullet = love.graphics.newImage("res/tank/bullet.png")

class "TankBullet" {
	x = 0;
	y = 0;
	angle = 0;
	parent = nil;
	
	speed = 250;
	lifetime = 10;
	time = 0;
}

function TankBullet:__init(parent, x, y) 
   self.parent = parent
   self.angle = parent.angle
   self.x = x or parent.x + math.cos(math.rad(self.angle)) * 80
   self.y = y or parent.y + math.sin(math.rad(self.angle)) * 80 
end

function TankBullet:update(dt)
   self.x = self.x + math.cos(math.rad(self.angle)) * self.speed * dt
   self.y = self.y + math.sin(math.rad(self.angle)) * self.speed * dt
	 print(dt)
   
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


