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
end

-- called every frame, handles new input and does simple physics simulation
function Enemy:update()	
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
end
