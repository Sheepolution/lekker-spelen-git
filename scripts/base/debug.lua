local Debug = {}

Debug.log = {}
Debug.info = {}
Debug.speed = 1

Debug.visible = false

Debug.windows = {
	output = {
		stream = false
	},
	entities = {
		filter = ""
	}
}

function Debug.load()


end

function Debug.update(dt)
	imgui.NewFrame()
	imgui.Begin("Output", nil, {"ShowBorders", "NoScrollBar"})
	local output = Debug.windows.output
	if imgui.SmallButton(output.stream and "Latest" or "Stream") then
		output.stream = not output.stream
	end
	imgui.SameLine()
	if imgui.SmallButton("Clear") then
		Debug.log = {}
	end
	if output.stream then
		imgui.BeginChild("Sub1")
		for i,v in ipairs(Debug.log) do
			imgui.Text(v)
		end
		imgui.SetScrollHere()
		imgui.EndChild()
	end
end


function Debug.draw()
	if not Debug.visible then return end
	imgui.End()
	-- local status

	-- Menu
	-- if imgui.BeginMainMenuBar() then
	--     if imgui.BeginMenu("File") then
	--         imgui.MenuItem("Test")
	--         imgui.EndMenu()
	--     end
	--     imgui.EndMainMenuBar()
	-- end

	local status

	imgui.Begin("Info")
		imgui.Text("FPS " .. love.timer.getFPS())
		imgui.Text("Drawcalls " .. Debug.info.drawcalls)
		imgui.Text("Entites " .. #Game.entities)
		status, Debug.speed = imgui.SliderFloat("", Debug.speed, 0, 5)
	imgui.End()

	if imgui.Begin("Entities") then
		local ent = Debug.windows.entities
		status, ent.filter = imgui.InputText("Filter", ent.filter, 100)
		imgui.BeginChild("Entities")
		for i, e in ipairs(Game.entities) do
			local cname = lume.find(_G, getmetatable(e))
			local name = string.format("%s (%d, %d)###%d", cname, e.x, e.y, i)
			if name:find(ent.filter, 0, true) and imgui.TreeNode(name) then
				Debug.entity(e)
				imgui.TreePop()
			end
		end
		imgui.EndChild()
	end
	imgui.End()


	-- imgui.ShowTestWindow(true)

	imgui.Render();
end


function Debug.print(t)
	table.insert(Debug.log, t)
	if #Debug.log > 100 then
	  table.remove(Debug.log, 1)
	end
	if not Debug.windows.output.stream then
		imgui.Text(t)
	end
end


function Debug.reset()
	Debug.info = {}
end


function Debug.add(k, v)
	v = v or 1
	local c = Debug.info[k]
	Debug.info[k] = c and c + v or v
end

return Debug