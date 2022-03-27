class('Player').extends(playdate.graphics.sprite)

function Player:init()
	Player.super.init(self)
	
	local playerImage = playdate.graphics.image.new('images/player')
	self:setImage(playerImage)
	self:moveTo(100, 224)
	self:setCollideRect(0, 0, self:getSize())
	
	self.isPlayer = true
	self.playerSpeed = 4
	self.isFiring = false
end

function Player:fire()	
	if self.isFiring then
		return
	end
	
	self.isFiring = true
	local selfPlayer = self
	
	-- Define the bomb up
	local s = BombUp()
	
	-- Set bomb initial position to the same position as the player
	local px, py, pw, ph = self:getPosition()
	local bombX = px
	local bombY = py
	s:moveTo(bombX, bombY)
	
	function s:onRemove()
		selfPlayer.isFiring = false
	end
	
	function s:onHitEnemy(collision)
		-- Destroy enemy
		local invader = collision.other
		Explosion(invader.x, invader.y)
		invader:remove()
		
		-- Destroy bomb
		s:remove()
		
		-- Update vars
		selfPlayer.isFiring = false
		
		selfPlayer:onFireHitsEnemy()
	end	
	
	function s:onHitBunkerPart(collision)
		selfPlayer.isFiring = false
		s:remove()
		local bunkerPart = collision.other
		bunkerPart:remove()
	end
	
	function s:update()
		BombUp.update(self)
		
		selfPlayer:onBombUpdate(s)
	end
	
	s:add()
end

function Player:update()	
	local px, py, pw, ph = self:getPosition()
	local playerWidth, playerHeight = self:getSize()
	
	-- (A) button
	if playdate.buttonIsPressed(playdate.kButtonA) then
		self:fire()
	end
	
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