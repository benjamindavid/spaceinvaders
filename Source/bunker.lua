class('Bunker').extends(playdate.graphics.sprite)

function Bunker:init(x, y)
	Bunker.super.init(self)
	self.removeParts = false
	self:createBunker(x, y)
end

function Bunker:createBunkerPart(x, y)
	local img = playdate.graphics.image.new('images/bunker-1')
	local imgWidth, imgHeight = img:getSize()
	local s = playdate.graphics.sprite.new(img)
	s.isBunkerPart = true
	local bunkerSelf = self
	s:moveTo(x, y)
	s:setCollideRect(0, 0, s:getSize())
	function s:update()
		if bunkerSelf.removeParts then
			s:remove()
		end
		
		bunkerSelf:update()
	end
	s:add()
end

function Bunker:createBunker(x, y)
	for colsIndex=1,15 do
		for rowsIndex=1,6 do
			self:createBunkerPart(4*colsIndex + x, 4*rowsIndex + y)
		end
	end
end

function Bunker:remove()
	self.removeParts = true
	Bunker.super.remove(self)
end

-- function Bunker:removeBunker()
-- 	print('remove bunker')
-- 	self.removeParts = true
-- 	self:remove()
-- end