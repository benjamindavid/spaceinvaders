class('Player').extends(playdate.graphics.sprite)

function Player:init()
	Player.super.init(self)
	print("player init")
	
	local playerImage = playdate.graphics.image.new('images/player')
	self:setImage(playerImage)
	self:moveTo(100, 224)
	self:setCollideRect(0, 0, self:getSize())
	
	self.isPlayer = true
	self.playerSpeed = 4
end


function Player:update()
	print("-- player update")
	
	local px, py, pw, ph = self:getPosition()
	local playerWidth, playerHeight = self:getSize()
	
	-- Right button
	if playdate.buttonIsPressed(playdate.kButtonRight) then
		if px < playdate.display.getWidth() - playerWidth / 2 then
			self:moveBy(self.playerSpeed, 0)
		end
	end
	
	-- Left Button
	if playdate.buttonIsPressed(playdate.kButtonLeft) then
		if px > (playerWidth / 2) then
			self:moveBy(-self.playerSpeed, 0)
		end
	end
end