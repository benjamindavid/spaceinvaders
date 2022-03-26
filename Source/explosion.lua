class('Explosion').extends(playdate.graphics.sprite)

function Explosion:init(x, y)
	Explosion.super.init(self)
	
	local img = playdate.graphics.image.new('images/explosion')
	self:setImage(img)
	self:moveTo(x, y)
	self:add()
	
	self.isExplosion = true
	self.animationFrame = 0
end


function Explosion:update()
	self.animationFrame += 1
	
	if self.animationFrame > 1 then
		self:remove()
	end
end

