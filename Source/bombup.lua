class('BombUp').extends(playdate.graphics.sprite)

function BombUp:init()
	BombUp.super.init(self)
	
	local img = playdate.graphics.image.new('images/bomb-up')
	self:setImage(img)
	self:setCollideRect(0, 0, self:getSize())
	
	self.isBombUp = true
	self.animationFrame = 0
end


-- Collision response
function BombUp:collisionResponse(other)
	if other.isBunkerPart or other.isEnemy then
		return playdate.graphics.sprite.kCollisionTypeBounce
	else
		return playdate.graphics.sprite.kCollisionTypeOverlap
	end
end


-- Sprite update
function BombUp:update()
	local newY = self.y - 8
	local imgWidth, imgHeight = self:getSize()
	
	if newY < -imgHeight then
		-- Remove the bomb if it moves out of the viewport
		self:remove()
		self:onRemove()
	else
		-- Move the bomb
		local actualX, actualY, collisions, length = self:moveWithCollisions(self.x, newY)
		for i = 1, length do
			local collision = collisions[i]
			
			-- If the bomb collides with an enemy, remove the enemy and the bomb
			if collision.other.isEnemy == true then
				self:onHitEnemy(collision)
			end
			
			-- If the bomb collides with a bunker part, damage the bunker part or remove it
			if collision.other.isBunkerPart == true then
				self:onHitBunkerPart(collision)
			end
			
			-- If the bomb up collides with the bomb down, remove the two bombs
			if collision.other.isBombDown then
				collision.other:remove()
				self:remove()
				self:onRemove()
			end
		end
	end
end	