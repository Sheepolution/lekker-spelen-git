MovingWall = SolidTile:extend("MovingWall")

function MovingWall:new(...)
	MovingWall.super.new(self, ...)
	self:setImage("tiles")
	self.gravity = 0
	self.solid = 2
	self.visible = true

	self.tiles = {}

	self.appearTime = step.new(0.1)
	self.appearing = true

	self:addIgnoreOverlap(SolidTile)
	self.canDie = false
end


function MovingWall:done()
	MovingWall.super.done(self)
	self.width, self.height = self.mapObject.width, self.mapObject.height
	self.columns = self.width/32
	self.rows = self.height/32

	self:clearHitboxes()
	self.hitbox = self:addHitbox("solid", self.width, self.height)

	self.longestType = self.columns > self.rows and "columns" or "rows"
	self.longest = math.max(self.columns, self.rows)
	self.tiles = {}
	for i=1,self.longest do
		self.tiles[i] = true
	end
end


function MovingWall:update(dt)
	MovingWall.super.update(self, dt)

	if self.appearTime(dt) then
		if self.appearing then
			if not _.all(self.tiles, function (e) return e == true end) then
				for i=1,self.longest do
					if not self.tiles[i] then
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
			else
				self.hitbox.auto = true
			end
		else
			if _.any(self.tiles, function (e) return e == true end) then
				for i=math.floor(self.longest/2),1,-1 do
					if self.tiles[i] then
						self.tiles[i] = false
						break
					end
				end
				for i=math.ceil(self.longest/2),self.longest do
					if self.tiles[i] then
						self.tiles[i] = false
						break
					end
				end
				self.hitbox.auto = false
			end
		end
	end
end


function MovingWall:draw()
	for i=0,self.rows-1 do
		for j=0,self.columns-1 do
			if self.tiles[(self.longestType == "columns" and j or i)+1] then
				self.offset.x = 32 * j
				self.offset.y = 32 * i
				MovingWall.super.draw(self)
			end
		end
	end
end


function MovingWall:onTrigger()
	self.appearing = false
end


function MovingWall:onOff()
	self.appearing = true
end