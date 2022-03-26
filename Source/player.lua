class('Player').extends(playdate.graphics.sprite)

function Player:init()
	Player.super.init(self)
	print("player init")
	
	local playerImage = playdate.graphics.image.new('images/player')
	self:setImage(playerImage)
	self.isPlayer = true
	self:moveTo(100, 224)
	self:setCollideRect(0, 0, self:getSize())
end
