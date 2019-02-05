Locator = Object:extend()

function Locator:findTarget(t, d, f)
	local target, distance = self.scene:findNearestEntityOfType(self, t, f)
	if not target then return end
	if not d or distance <= d then
		self:onFindingTarget(target, distance)
	end
end


function Locator:onFindingTarget()

end


function Locator:findTargets(t, d, f)
	local d = d or math.huge
	local targets = {}
	local ents = self.scene:findEntitiesOfType(t, f)
	if not ents then return end
	for i,v in ipairs(ents) do
		local dist = self:getDistance(v)
		 if dist < d then
			table.insert(targets, {target = v, distance = dist})
		end
	end
	self:onFindingTargets(targets)
end