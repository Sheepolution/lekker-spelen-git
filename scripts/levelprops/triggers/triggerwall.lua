TriggerWall = Entity:extend("TriggerWall")

TriggerWall.SFX = SFX("sfx/wall")

function TriggerWall:new(...)
	TriggerWall.super.new(self, ...)
	self:setImage(Game.tileset, 3)
	self.anim:add("empty", 3)
	self.anim:add("top", 2)
	self.anim:add("base", 1)
	self.gravity = 0
	self.solid = 2
	self.visible = true
	self.z = ZMAP.TriggerWall

	self.immovable = {x = true, y = true}

	self.tiles = {}

	self.appearTime = step.new(0.05)
	self.appearing = true

	self:addIgnoreOverlap(SolidTile)
	self.canDie = false
end


function TriggerWall:done()
	TriggerWall.super.done(self)

	self.width, self.height = self.mapObject.width, self.mapObject.height
	self.columns = self.width/32
	self.rows = self.height/32

	self.longestType = self.columns > self.rows and "columns" or "rows"

	if self.longestType == "columns" then
		self.rows = self.rows + 1
		self.y = self.y - 32
	end

	self.longest = math.max(self.columns, self.rows)

	self:clearHitboxes()
	self.hitbox = self:addHitbox("solid", 0, (self.longestType == "columns" and 24 or 0), self.width, self.height + (self.longestType == "columns" and 16 or 0))
	self.hitbox.auto = not self.reverse

	self.tiles = {}
	for i=1,self.longest do
		self.tiles[i] = not self.reverse
	end

	self.appearing = not self.reverse
end


function TriggerWall:update(dt)
	TriggerWall.super.update(self, dt)

	if self.appearTime(dt) then
		if self.appearing then
			if not _.all(self.tiles, function (e) return e == true end) then
				for i=1,self.longest do
					if not self.tiles[i] then
						self.scene:playSFX(TriggerWall.SFX)
						self.tiles[i] = true
						break
					end
				end
				for i=self.longest,1,-1 do
					if not self.tiles[i] then
						self.tiles[i] = true
						break
					end
				end
			end
			self.hitbox.auto = true
		else
			if _.any(self.tiles, function (e) return e == true end) then
				for i=math.floor(self.longest/2),1,-1 do
					if self.tiles[i] then
						self.scene:playSFX(TriggerWall.SFX)
						self.tiles[i] = false
						if i <= self.longest/4 then
							self.hitbox.auto = false
						end
						break
					end
				end
				for i=math.ceil(self.longest/2),self.longest do
					if self.tiles[i] then
						self.tiles[i] = false
						break
					end
				end
			else
				self.hitbox.auto = false
			end
		end
	end
end


function TriggerWall:draw()
	for i=0,self.rows-1 do
		for j=0,self.columns-1 do
			if self.tiles[(self.longestType == "columns" and j or i)+1] then
				if self.longestType == "columns" then
					if i == 0 then
						self.anim:set("top")
					else
						self.anim:set("base")
					end
				else
					self.anim:set("base")
				end
				self.offset.x = 32 * j
				self.offset.y = 32 * i
				TriggerWall.super.draw(self)
			else
				if self.longestType == "rows" or i > 0 then
					self.offset.x = 32 * j
					self.offset.y = 32 * i
					self.anim:set("empty")
					TriggerWall.super.draw(self)
				end
			end
		end
	end
end


function TriggerWall:onTrigger()
	self.appearing = self.reverse
end


function TriggerWall:onOff()
	self.appearing = not self.reverse
end