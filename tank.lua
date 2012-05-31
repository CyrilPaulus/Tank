
--Load ressources
tank_base = love.graphics.newImage("res/tank/tank_base.png")
tank_smoke = love.graphics.newImage("res/tank/smoke.png")
tank_turret = love.graphics.newImage("res/tank/tank_turret.png")
tank_muzzleflash = love.graphics.newImage("res/tank/muzzleflash.png")

--Class definition
Tank = class("Tank", Entity)

function Tank:initialize(x, y)
   Entity.initialize(self)
   
   --Overloard entity
   self.x = x
   self.y = y
   self.offsetX = 64
   self.offsetY = 32
   self.image = tank_base;
   self.width = 128;
   self.height = 64;
   
   --New stuff
   self.speed = 0
   self.maxSpeed = 100
   self.rearSpeed = 50
   self.acceleration = 10
   self.deceleration = 60
   self.angularSpeed = math.pi / 4
   
   self.forward = false
   self.backward = false
   self.left = false
   self.right = false
   
   self.lastPosX = 0
   self.lastPosY = 0
   
   self.turret = TankTurret:new()
   self.turret:setParent(self)
      
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
   Entity.update(self)
   
   self.particleLeft:start()	
   self.particleRight:start()	
   self.particleLeft:setDirection(self.angle - math.pi)
   self.particleRight:setDirection(self.angle - math.pi)
   
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
      self:rotate(self.angularSpeed * -dt)
   end
   
   if(self.right) then
      self:rotate(self.angularSpeed * dt)
   end
   
   self.turret:update(dt)
   
   x,y = rot(-58, -10, self.angle)
   self.particleLeft:setPosition(self.x + x, self.y + y)	
   self.particleLeft:update(dt)
   
   x,y = rot(-58, 10, self.angle)
   self.particleRight:setPosition(self.x + x, self.y + y)
   self.particleRight:update(dt)
   
   self.x = self.x + math.cos(self.angle) * self.speed * dt
   self.y = self.y + math.sin(self.angle) * self.speed * dt
   
   self.idle_src:setPosition(self.x, self.y, 0)
   
   if( (self.lastPosX - self.x)^ 2 + (self.lastPosY - self.y)^ 2 > 64) then
      self.lastPosX = self.x
      self.lastPosY = self.y
      globalDecals:addTrack(self.x, self.y, self.angle)
   end
end

function Tank:draw()
   Entity.draw(self)	
   self.turret:draw()
   love.graphics.draw(self.particleLeft)
   love.graphics.draw(self.particleRight)   
end

function Tank:rotate(rad)
   Entity.rotate(self, rad)
   self.turret:rotate(rad)
end

function Tank:lookAt(x, y) 
   self.turret:lookAt(x, y)
end

TankTurret = class("TankTurret", Entity)

function TankTurret:initialize()
   
   Entity.initialize(self)   
   self.width = 128
   self.height = 64
   self.offsetX = 39
   self.offsetY = 31.5
   self.image = tank_turret;
   
   self.fireDelay = 1.5
   self.firecounter = 0
   self.fire = true
   self.cannon = true
   self.cannonX = 0
   self.cannonY = 0
   self.drawMuzzle = false
   self.muzzleTime = 0
   self.maxMuzzleTime = 0.1   
   self.bullets = {}
   self.cannon_src = love.audio.newSource("res/tank/cannon_shot.ogg")
   self.cannon_src:setDistance(400,800)
end

function TankTurret:lookAt(x, y) 
   self.angle = math.atan2(x - self.x, -(y - self.y)) - math.pi / 2
end				 

function TankTurret:update(dt)
   Entity.update(self, dt)
   
   if(self.drawMuzzle) then
      self.muzzleTime = self.muzzleTime + dt
      if(self.muzzleTime > self.maxMuzzleTime) then
         self.drawMuzzle = false
         self.muzzleTime = 0
      end
   end
   self.firecounter = self.firecounter + dt
   
   if(self.fire and self.firecounter > self.fireDelay) then
      self.drawMuzzle = true

      if (self.cannon) then
         self.cannonX, self.cannonY = rot(90, 6, self.angle)
      else
         self.cannonX, self.cannonY = rot(90, -6, self.angle)
      end
      
      self.cannon_src:setPosition(self.x + self.cannonX, self.y + self.cannonY, 0)

      if(not self.cannon_src:isStopped()) then
         self.cannon_src:stop()
      end

      self.cannon_src:play()
      self.cannon = not self.cannon
      --FIRE BULLET HERE
      bulletSystem:addBullet(self, self.x + self.cannonX, self.y + self.cannonY, self.angle)
      self.firecounter = 0
   end
   
   self.fire = false
end

function TankTurret:draw()
   Entity.draw(self)  
   if(self.drawMuzzle) then
      love.graphics.draw(tank_muzzleflash, self.x + self.cannonX, self.y + self.cannonY, self.angle, 1, 1, 15, 6)
   end
   
   for i,v in ipairs(self.bullets) do
      v:draw()
   end	
end

function TankTurret:fireMain() 
   self.fire = true
end




