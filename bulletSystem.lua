BulletSystem = class("BulletSystem")

function BulletSystem:initialize()
   self.bullets = {}
end

function BulletSystem:update(dt)
   for i,v in ipairs(self.bullets) do
      if(v:update(dt)) then
         table.remove(self.bullets, i)
      end
   end
end

function BulletSystem:draw()
   for i,v in ipairs(self.bullets) do
      v:draw()
   end
end

function BulletSystem:addBullet(owner, x, y, angle)
   table.insert(self.bullets, TankBullet:new(owner, x, y, angle))
end

tank_bullet = love.graphics.newImage("res/tank/bullet.png")
TankBullet = class("TankBullet", Entity)

function TankBullet:initialize(owner, x, y, angle)   
   self.x = x 
   self.y = y
   self.scaleX = 0.5
   self.scaleY = 0.5
   self.offsetX = 16
   self.offsetY = 8
   self.angle = angle
   self.image = tank_bullet     
   self.speed = 1000
   self.lifetime = 10
   self.time = 0
   self.owner = owner  
end

function TankBullet:update(dt)
   
   self.x = self.x + math.cos(self.angle) * self.speed * dt
   self.y = self.y + math.sin(self.angle) * self.speed * dt
   
   self.time = self.time + dt
   if self.time > self.lifetime then
      return true
   else
      return false
   end
end
