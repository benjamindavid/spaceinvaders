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

local player = nil
local gfx <const> = playdate.graphics
local score = 0
local changeDirection = nil
local enemySpeed = nil
local enemyDirection = 'right'
local lastEnemyXDirection = 'right'
local remainingEnemies = 0
local lives = nil


-- Player

local function createPlayer()
	if player then
		player:remove()
		player = nil
	end
	
	player = Player()
	player:add()
	
	function player:update()	
		Player.update(self)
		
		if lives < 1 then
			player:remove()
		end
	end
	
	function player:fire()
		if lives < 1 then
			return
		end
		
		Player.fire(self)
	end
	
	function player:onFireHitsEnemy()
		remainingEnemies -= 1
		score += 1
		enemySpeed += 0.1
	end
	
	function player:onBombUpdate(s)
		if lives < 1 then
			s:remove()
		end
	end
end


-- Enemies 

local function createEnemy(enemyIndex, x, y)
	local s = Enemy(x, y)
	
	function s:changeDirection(newDirection)
		changeDirection = newDirection
	end
	
	function s:fire()
		-- Define bomb down
		local bombSprite = BombDown()
		local imgWidth, imgHeight = s:getSize()
		
		-- Set bomb initial position to the same position as the enemy
		local px, py, pw, ph = s:getPosition()
		local bombX = px
		local bombY = py
		bombSprite:moveTo(bombX, bombY)
		
		function bombSprite:onHitPlayer()
			bombSprite:remove()
			lives -= 1
		end
		
		function bombSprite:onHitBunkerPart(collision)
			bombSprite:remove()
			local bunkerPart = collision.other
			bunkerPart:remove()
		end
		
		function bombSprite:update()
			BombDown.update(self)

			if lives < 1 then
				bombSprite:remove()
			end
		end
		
		bombSprite:add()
	end
	
	function s:update()
		Enemy.update(self)
		s.enemyDirection = enemyDirection
		s.lastEnemyXDirection = lastEnemyXDirection
		s.enemySpeed = enemySpeed
		
		if lives < 1 then
			s:remove()
			remainingEnemies -= 1
			return
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
	enemySpeed = 0.5
	
	createPlayer()
	createEnemies()
	createBunkers()
end


-- Update

function playdate.update()	
	-- (A) button
	if playdate.buttonIsPressed(playdate.kButtonA) then
		if lives < 1 then
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
	gfx.drawText("Enemies: " .. remainingEnemies, 100, 5)
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