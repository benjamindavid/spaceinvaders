class('BombDown').extends(playdate.graphics.sprite)

function BombDown:init()
	BombDown.super.init(self)
	
	local img = playdate.graphics.image.new('images/bomb-down')
	self:setImage(img)
	self:setCollideRect(0, 0, self:getSize())
	
	self.isBombDown = true
	self.animationFrame = 0
end

-- Collision response
function BombDown:collisionResponse(other)
	if other.isBunkerPart then
		return playdate.graphics.sprite.kCollisionTypeFreeze
	else
		return playdate.graphics.sprite.kCollisionTypeOverlap
	end
end


function BombDown:explodes(x, y)
	local img = playdate.graphics.image.new('images/bomb-down-explodes')
	local imgWidth, imgHeight = img:getSize()
	local s = playdate.graphics.sprite.new(img)
	s.frame = 1
	s:moveTo(x, y)
	
	function s:update()
		if s.frame > 3 then
			s:remove()
		end
		s.frame += 1
	end
	
	s:add()
end

-- Sprite update
function BombDown:update()
	local newY = self.y + 4
	
	if newY > playdate.display.getHeight() then
		-- Remove the bomb if it moves out of the viewport
		self:explodes(self.x, self.y)
		self:remove()
	else
		-- Move the bomb
		local actualX, actualY, collisions, length = self:moveWithCollisions(self.x, newY)
		for i = 1, length do
			local collision = collisions[i]
			
			-- If the bomb collides with the player, remove the bomb, reset the player and remove a life
			if collision.other.isPlayer == true then
				self:onHitPlayer()
			end
			
			-- If the bomb collides with a bunker part, damage the bunker part or remove it
			if collision.other.isBunkerPart == true then
				self:onHitBunkerPart(collision)
			end
		end
	end
end	