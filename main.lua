function love.load(args)
	starImg = love.graphics.newImage("star.png")
	stars = {} -- STAR = {x, y, velX, velY, nX, nY}
	
	--for x = 0, 50 do
	--	for y = 0, 50 do
	--		local r = love.math.random()
	--		if r > 0.9 then
	--			table.insert(stars, {x + 50 * 10, y + 50 * 10, 0, 0, 0, 0})
	--		end
	--	end
	--end
	
	pause = false
	
	eraseBrushSize = 25
end

function love.update(dt)
	if love.mouse.isDown(2) then
		for k, v in pairs(stars) do
			local r = math.sqrt((v[1] - love.mouse.getX())^2 + (v[2] - love.mouse.getY())^2)
			
			if r <= eraseBrushSize then
				table.remove(stars, k)
			end
		end
	end
	if not pause then
		for k, v in pairs(stars) do
			if v[1] < 0 then
				v[1] = v[1] + love.graphics.getWidth()
			elseif v[1] > love.graphics.getWidth() then
				v[1] = v[1] - love.graphics.getWidth()
			end
			
			if v[2] < 0 then
				v[2] = v[2] + love.graphics.getHeight()
			elseif v[2] > love.graphics.getHeight() then
				v[2] = v[2] - love.graphics.getHeight()
			end
			for l, w in pairs(stars) do
				if k ~= l then
					local r = math.sqrt((v[1] - w[1])^2 + (v[2] - w[2])^2)
					local a = math.atan2(v[1] - w[1], v[2] - w[2])
					
					if r ~= 0 then
						local vx = math.sin(a) / r
						local vy = math.cos(a) / r
						
						v[3] = v[3] - vx
						v[4] = v[4] - vy
					end
				end
			end
			
			v[5] = v[1] + v[3]
			v[6] = v[2] + v[4]
		end
		for k, v in pairs(stars) do
			v[1] = v[5]
			v[2] = v[6]
		end
	end
end

function love.draw()
	if love.mouse.isDown(2) then
		love.graphics.circle("fill", love.mouse.getX(), love.mouse.getY(), eraseBrushSize)
	end
	
	for k, v in pairs(stars) do
		love.graphics.draw(starImg, v[1] - (starImg:getWidth() / 2), v[2] - (starImg:getHeight() / 2))
	end
end

function love.keypressed(key, scancode, isrepeat)
	if scancode == "space" then
		pause = not pause
	end
end

function love.mousepressed(x, y, button, isTouch)
	if button == 1 then
		table.insert(stars, {x, y, 0, 0, 0, 0})
	elseif button == 3 then
		for k, v in pairs(stars) do
			v[3] = 0
			v[4] = 0
		end
	end
end
