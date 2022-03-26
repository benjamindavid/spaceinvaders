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


-- called every frame, handles new input and does simple physics simulation
function Player:update()
	print("player update")
end

function Player:fire()
	
	-- if feet on ground
	if onGround then
		
		if playdate.buttonIsPressed("A") and abs(self.velocity.x) > SPEED_OF_RUNNING then -- super jump
			self.velocity.y = -SUPERJUMP_VELOCITY
		else -- regular jump
			self.velocity.y = -JUMP_VELOCITY
		end
		
		jumpTimer:reset()
		jumpTimer:start()		
		
		skidding = false
		
		SoundManager:playSound(SoundManager.kSoundJump)
	end
	
end