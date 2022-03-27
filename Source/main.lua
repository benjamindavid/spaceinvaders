import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import 'CoreLibs/easing'
import 'player'
import 'enemy'
import 'bombup'
import 'bombdown'
import 'bunker'
import 'explosion'

local player = Player()
local gfx <const> = playdate.graphics
local score = 0
local changeDirection = nil
local playerSpeed = 4
local enemySpeed = 0.1
local enemyDirection = 'right'
local lastEnemyXDirection = 'right'
local isFiring = false
local remainingEnemies = 0
local isExploding = false
local lives = 1


-- Player

local function createPlayer()
	if player then
		player:remove()
	end
	
	player:addSprite()
	
	function player:update()	
		Player.update(self)
		
		if lives < 1 then
			player:remove()
		end
	end
end

local function playerFire()
	if isFiring then
		return
	end
	
	isFiring = true
	
	-- Define the bomb up
	local s = BombUp()
	
	-- Set bomb initial position to the same position as the player
	local px, py, pw, ph = player:getPosition()
	local bombX = px
	local bombY = py
	s:moveTo(bombX, bombY)
	
	function s:onRemove()
		isFiring = false
	end
	
	function s:onHitEnemy(collision)
		-- Destroy enemy
		local invader = collision.other
		Explosion(invader.x, invader.y)
		invader:remove()
		remainingEnemies -= 1
		
		-- Destroy bomb
		s:remove()
		
		-- Update vars
		isFiring = false
		score += 1
		enemySpeed += 0.1
	end	
	
	function s:onHitBunkerPart(collision)
		isFiring = false
		s:remove()
		local bunkerPart = collision.other
		bunkerPart:remove()
	end
	
	s:add()
end


-- Enemies 

local function enemyFire(enemySprite)
	-- Define bomb down
	local s = BombDown()
	local imgWidth, imgHeight = s:getSize()
	
	-- Set bomb initial position to the same position as the enemy
	local px, py, pw, ph = enemySprite:getPosition()
	local bombX = px
	local bombY = py
	s:moveTo(bombX, bombY)
	
	function s:onHitPlayer()
		s:remove()
		lives -= 1
	end
	
	function s:onHitBunkerPart(collision)
		s:remove()
		local bunkerPart = collision.other
		bunkerPart:remove()
	end
	
	s:add()
end

local function createEnemy(enemyIndex, x, y)
	-- print("Create enemy", enemyIndex)
	local s = Enemy(x, y)
	local imgWidth, imgHeight = s:getSize()	
	s.frame = 0
	
	function s:update()
		Enemy.update(self)
		
		if s.frame > 48 then
			s.frame = 0
		end
		
		if lives < 1 then
			s:remove()
			remainingEnemies -= 1
			return
		end
		
		if isExploding then
			return
		end
		
		if s.frame == math.random(300) then
			enemyFire(s)
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
		
		s.frame += 1
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


-- Bunkers

local function createBunkers()
	for i=0,3 do
		local s = Bunker(20 + i * 100, 160)
		
		function s:update()
			if lives < 1 then
				s:remove()
			end
		end
	end
end


-- Init

local function initialize()
	print("Let’s get started")
	
	score = 0
	lives = 1
	
	createPlayer()
	createEnemies()
	createBunkers()
end


-- Update

function playdate.update()	
	-- (A) button
	if playdate.buttonIsPressed(playdate.kButtonA) then
		if lives > 0 then
			playerFire()
		else
			initialize()
		end
	end


	-- Change direction
	if changeDirection then
		enemyDirection = changeDirection
		
		if enemyDirection ~= 'down' then
			lastEnemyXDirection = enemyDirection
		end
		
		changeDirection = nil
	end
	
	-- Reset the game when there are no more enemies
	if remainingEnemies == 0 then
		createEnemies()
		enemySpeed = 1
	end
	
	-- Update timers and sprites
	gfx.sprite.update()
	
	-- Display info
	gfx.drawText("Score: " .. score, 5, 5)
	gfx.drawText("Remaining: " .. remainingEnemies, 100, 5)
	gfx.drawText("Lives: " .. lives, 320, 5)
	
	if lives < 1 then
		gfx.fillRoundRect(100, 50, 200, 100, 5)
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		gfx.drawText("GAME OVER", 154, 80)
		gfx.drawText("Press A to restart", 124, 110)
		gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
	end
end


-- Init the game

initialize()