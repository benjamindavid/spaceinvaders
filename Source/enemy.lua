class('Enemy').extends(playdate.graphics.sprite)

function Enemy:init(x, y)
	Enemy.super.init(self)
	-- print("enemy init")
	
	local enemyImage = playdate.graphics.image.new('images/invader')
	self:setImage(enemyImage)
	self:moveTo(x, y)
	self:setCollideRect(0, 0, self:getSize())
	
	self.isEnemy = true
	self.animationFrame = 0
	self.frame = 0
	self.enemySpeed = nil
	self.enemyDirection = nil
	self.lastEnemyXDirection = nil
end

-- called every frame, handles new input and does simple physics simulation
function Enemy:update()	
	-- Animate enemy
	if self.animationFrame < 24 then
		local newImage = playdate.graphics.image.new('images/invader/1')
		self:setImage(newImage)
	else
		local newImage = playdate.graphics.image.new('images/invader/2')
		self:setImage(newImage)
	end
	
	if self.animationFrame > 48 then
		self.animationFrame = 0
	end
	
	self.animationFrame += 1
	
	-- Misc
	local imgWidth, imgHeight = self:getSize()	
	
	if self.frame > 48 then
		self.frame = 0
	end

	if self.frame == math.random(300) then
		self.fire()
	end
	
	if self.enemyDirection == 'right' then
		local newX = self.x + self.enemySpeed
		local maxX = playdate.display.getWidth() - (imgWidth / 2)
		
		if newX > maxX then
			self:changeDirection('down')
		end
		
		self:moveTo(newX, self.y)
	elseif self.enemyDirection == 'left' then
		local newX = self.x - self.enemySpeed
		local minX = 0 + (imgWidth / 2)
		
		if newX < minX then
			self:changeDirection('down')
		end
		
		self:moveTo(newX, self.y)
	elseif self.enemyDirection == 'down' then
		local newY = self.y + 5
		
		if self.lastEnemyXDirection == 'right' then
			self:changeDirection('left')
		else
			self:changeDirection('right')
		end
		
		self:moveTo(self.x, newY)
	end
	
	self.frame += 1
end
