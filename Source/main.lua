import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import 'CoreLibs/frameTimer'
import 'CoreLibs/easing'
import 'player'

local player = Player()

local gfx <const> = playdate.graphics
local score = 0
local changeDirection = nil
local playerSprite = nil
local playerSpeed = 4
local enemySpeed = 0.1
local enemyDirection = 'right'
local lastEnemyXDirection = 'right'
local isFiring = false
local remainingEnemies = 0
local isExploding = false
local lives = 1

local stepTimer = playdate.frameTimer.new(2)
stepTimer.repeats = true

local playerImage = gfx.image.new('images/player')

local function createExplosion(x, y)
	isExploding = true
	local img = gfx.image.new('images/explosion')
	local imgWidth, imgHeight = img:getSize()
	local s = gfx.sprite.new(img)
	s.frame = 1
	
	function s:update()
		s.frame += 1
		if s.frame > 1 then
			isExploding = false
			s:remove()
		end
	end
	
	s:moveTo(x, y)
	s:add()
end


local function destroyEnemy(invader)
	createExplosion(invader.x, invader.y)
	invader:remove()
	remainingEnemies -= 1
end

local function hitBunkerPart(bunkerPartSprite)
	bunkerPartSprite:remove()
end


local function playerFire()
	if isFiring then
		return
	end
	
	isFiring = true
	
	local img = gfx.image.new('images/bomb-up')
	local imgWidth, imgHeight = img:getSize()
	local s = gfx.sprite.new(img)
	
	-- Set collide rect
	s:setCollideRect(0, 0, s:getSize())
	
	-- Set bomb initial position to the same position as the player
	local px, py, pw, ph = playerSprite:getPosition()
	local bombX = px
	local bombY = py
	s:moveTo(bombX, bombY)

	-- Collision response
	function s:collisionResponse(other)
		if other.isBunkerPart then
			return gfx.sprite.kCollisionTypeBounce
		else
			return gfx.sprite.kCollisionTypeOverlap
		end
	end
	
	-- Sprite update
	function s:update()
		local newY = s.y - 8
		
		if newY < -imgHeight then
			-- Remove the bomb if it moves out of the viewport
			s:remove()
			isFiring = false
		else
			-- Move the bomb
			local actualX, actualY, collisions, length = s:moveWithCollisions(s.x, newY)
			for i = 1, length do
				local collision = collisions[i]
				
				-- If the bomb collides with an enemy, remove the enemy and the bomb
				if collision.other.isEnemy == true then
					destroyEnemy(collision.other)
					s:remove()
					isFiring = false
					score += 1
					enemySpeed += 0.1
				end
				
				-- If the bomb collides with a bunker part, damage the bunker part or remove it
				if collision.other.isBunkerPart == true then
					isFiring = false
					s:remove()
					hitBunkerPart(collision.other)
				end
			end
		end
	end	
	
	-- Add the sprite
	s:add()
end

local function bombExplodes(x, y)
	-- print("bomb explodes")
	local img = gfx.image.new('images/bomb-down-explodes')
	local imgWidth, imgHeight = img:getSize()
	local s = gfx.sprite.new(img)
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

local function enemyFire(enemySprite)
	local img = gfx.image.new('images/bomb-down')
	local imgWidth, imgHeight = img:getSize()
	local s = gfx.sprite.new(img)
	
	-- Set collide rect
	s:setCollideRect(0, 0, s:getSize())
	
	-- Set bomb initial position to the same position as the enemy
	local px, py, pw, ph = enemySprite:getPosition()
	local bombX = px
	local bombY = py
	s:moveTo(bombX, bombY)
	
	-- Collision response
	function s:collisionResponse(other)
		if other.isBunkerPart then
			return gfx.sprite.kCollisionTypeFreeze
		else
			return gfx.sprite.kCollisionTypeOverlap
		end
	end
	
	-- Sprite update
	function s:update()
		local newY = s.y + 4
		
		-- print("newY, -imgHeight", newY, -imgHeight)
		
		if newY > playdate.display.getHeight() then
			-- print("remove")
			-- Remove the bomb if it moves out of the viewport
			bombExplodes(s.x, s.y)
			s:remove()
			
		else
			-- Move the bomb
			local actualX, actualY, collisions, length = s:moveWithCollisions(s.x, newY)
			for i = 1, length do
				local collision = collisions[i]
				
				-- If the bomb collides with the player, remove the bomb, reset the player and remove a life
				if collision.other.isPlayer == true then
					-- destroyEnemy(collision.other)
					s:remove()
					lives -= 1
				end
				
				-- If the bomb collides with a bunker part, damage the bunker part or remove it
				if collision.other.isBunkerPart == true then
					s:remove()
					hitBunkerPart(collision.other)
				end
			end
		end
	end	
	
	-- Add the sprite
	s:add()
end

local function createEnemy(enemyIndex, x, y)
	-- print("Create enemy", enemyIndex)
	local img = gfx.image.new('images/invader')
	local imgWidth, imgHeight = img:getSize()
	local s = gfx.sprite.new(img)
	s:moveTo(x, y)
	s:setCollideRect(0, 0, s:getSize())
	s.frame = 1
	
	function s:update()
		-- if stepTimer.frame ~= 1 then
		-- 	return
		-- end
		
		if lives < 1 then
			s:remove()
			remainingEnemies -= 1
			return
		end
		
		s.frame += 1
		
		if isExploding then
			return
		end
		
		if s.frame == math.random(300) then
			enemyFire(s)
		end
		
		if s.frame < 24 then
			local newImage = gfx.image.new('images/invader/1')
			s:setImage(newImage)
		else
			local newImage = gfx.image.new('images/invader/2')
			s:setImage(newImage)
		end
		
		if s.frame > 48 then
			s.frame = 0
		end
		
		if enemyDirection == 'right' then
			local newX = s.x + enemySpeed
			local maxX = playdate.display.getWidth() - (imgWidth / 2)
			
			if newX > maxX then
				changeDirection = 'down'
			end
			
			s:moveTo(newX, s.y)
		elseif enemyDirection == 'left' then
			local newX = s.x - enemySpeed
			local minX = 0 + (imgWidth / 2)
			
			if newX < minX then
				changeDirection = 'down'
			end
			
			s:moveTo(newX, s.y)
		elseif enemyDirection == 'down' then
			local newY = s.y + 5
			
			if lastEnemyXDirection == 'right' then
				changeDirection = 'left'
			else
				changeDirection = 'right'
			end
			
			s:moveTo(s.x, newY)
		end
	end
	
	s:add()
	s.isEnemy = true
	remainingEnemies += 1
end

local function createEnemies()
	local paddingTop = 10
	
	for ci=1,4 do
		for i=1,11 do
			createEnemy(i, i * 26, ci*28 + paddingTop)
		end
	end
end

local function createBunkerPart(x, y)
	local img = gfx.image.new('images/bunker-1')
	local imgWidth, imgHeight = img:getSize()
	local s = gfx.sprite.new(img)
	s.isBunkerPart = true
	s:moveTo(x, y)
	s:setCollideRect(0, 0, s:getSize())
	function s:update()
		if lives < 1 then
			s:remove()
		end
	end
	s:add()
end

local function createBunker(x, y)
	for colsIndex=1,15 do
		for rowsIndex=1,6 do
			createBunkerPart(4*colsIndex + x, 4*rowsIndex + y)
		end
	end
end

local function initialize()
	print("Let’s get started")
	score = 0
	lives = 1
	
	-- Player
	if playerSprite then
		playerSprite:remove()
	end
	
	playerSprite = gfx.sprite.new(playerImage)
	playerSprite.isPlayer = true
	playerSprite:moveTo(200, 224)
	playerSprite:setCollideRect(0, 0, playerSprite:getSize())	
	
	function playerSprite:update()
		if lives < 1 then
			playerSprite:remove()
		end
	end
	
	playerSprite:add()
	
	-- Enemies
	createEnemies()
	
	createBunker(20, 160)
	createBunker(120, 160)
	createBunker(220, 160)
	createBunker(320, 160)
end

initialize()

function playdate.update()
	local px, py, pw, ph = playerSprite:getPosition()
	local playerImgWidth, playerImgHeight = playerImage:getSize()
	
	if playdate.buttonIsPressed(playdate.kButtonA) then
		if lives > 0 then
			playerFire()
		else
			initialize()
		end
	end
	
	if playdate.buttonIsPressed(playdate.kButtonRight) then
		if px < playdate.display.getWidth() - playerImgWidth / 2 then
			playerSprite:moveBy(playerSpeed, 0)
		end
	end
	
	if playdate.buttonIsPressed(playdate.kButtonLeft) then
		if px > (playerImgWidth / 2) then
			playerSprite:moveBy(-playerSpeed, 0)
		end
	end

	if changeDirection then
		enemyDirection = changeDirection
		
		if enemyDirection ~= 'down' then
			lastEnemyXDirection = enemyDirection
		end
		
		changeDirection = nil
	end
	
	if remainingEnemies == 0 then
		createEnemies()
		enemySpeed = 1
	end
	
	playdate.frameTimer.updateTimers()
	gfx.sprite.update()
	
	gfx.drawText("Score: " .. score, 5, 5)
	gfx.drawText("Remaining: " .. remainingEnemies, 100, 5)
	gfx.drawText("Lives: " .. lives, 320, 5)
	
	-- gfx.setBackgroundColor(gfx.kColorBlack)
	-- gfx.setColor(gfx.kColorWhite)
	-- gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	
	
	
	if lives < 1 then
		gfx.fillRoundRect(100, 50, 200, 100, 5)
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		gfx.drawText("GAME OVER", 154, 80)
		gfx.drawText("Press A to restart", 124, 110)
		gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
	end
end
