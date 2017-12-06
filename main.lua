function love.load(args)
	starImg = love.graphics.newImage("star.png")
	stars = {} -- STAR = {x, y, velX, velY, nX, nY, mass, color}
	
	pause = false
	wall = true
	
	info = false
	
	starColor = true
	
	--G = 6.674 * 10^-11 * 1^3 * 1^-1 * 1^-2
	
	camX = 0
	camY = 0
	camspeed = 50
	
	argt = {}
	
	for k, v in pairs(args) do
		argt[v] = true
	end
	
	if argt["-g"] then	
		generate()
		pause = true
	end
	
	eraseBrushSize = 25
	circleSize = 5
	
	starStyle = "image"
	
	showVelocity = false
	shownVelMul = 8
end

function love.update(dt)
	if love.mouse.isDown(2) then
		for k, v in pairs(stars) do
			local r = math.sqrt((v[1] - (love.mouse.getX() + camX))^2 + (v[2] - (love.mouse.getY() + camY))^2)
			
			if r <= eraseBrushSize then
				table.remove(stars, k)
			end
		end
	end
	if love.keyboard.isScancodeDown("right") then
		camX = camX + camspeed
	end
	if love.keyboard.isScancodeDown("down") then
		camY = camY + camspeed
	end
	if love.keyboard.isScancodeDown("left") then
		camX = camX - camspeed
	end
	if love.keyboard.isScancodeDown("up") then
		camY = camY - camspeed
	end
	if not pause then
		for k, v in pairs(stars) do
			if wall then
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

function generate()
	stars = {}
	
	local x = 0
	while x < love.graphics.getWidth() do
		local y = 0
		
		while y < love.graphics.getHeight() do
			local n = love.math.noise(x * 5, y * 5) / 25
			local r = love.math.random()
			
			if r < n then
				table.insert(stars, {x, y, 0, 0, 0, 0, 1, {love.math.random(224, 255), love.math.random(224, 255), love.math.random(224, 255)}})
			end
			
				y = y + 5
		end
		x = x + 5
	end
	print("TOTAL OF " .. #stars .. " STARS CREATED")
end

function love.draw()
	if love.mouse.isDown(2) then
		love.graphics.setColor({255, 255, 255})
		love.graphics.circle("line", love.mouse.getX(), love.mouse.getY(), eraseBrushSize)
	end
	
	for k, v in pairs(stars) do
		if starColor then love.graphics.setColor(v[8]) else love.graphics.setColor({255, 255, 255}) end
		if starStyle == "image" then
			love.graphics.draw(starImg, v[1] - (starImg:getWidth() / 2) - camX, v[2] - (starImg:getHeight() / 2) - camY)
		elseif starStyle == "circle" then
			love.graphics.circle("fill", v[1] - camX, v[2] - camY, circleSize)
		elseif starStyle == "point" then
			love.graphics.points(v[1] - camX, v[2] - camY)
		end
		
		if showVelocity then
			love.graphics.line(v[1] - camX, v[2] - camY, (v[1] - camX) + (v[3] * shownVelMul), (v[2] - camY) + (v[4] * shownVelMul))
		end
	end
	
	if info then
		local text = #stars .. " stars\n"
		text = text .. love.timer.getFPS() .. " FPS\n"
		if pause then
			text = text .. "Paused\n"
		else
			text = text .. "Running\n"
		end
		
		
		if wall then
			text = text .. "Wall\n"
		else
			text = text .. "No wall\n"
		end
		
		
		if starColor then
			text = text .. "Stars are colored\n"
		else
			text = text .. "Stars are all the same\n"
		end
		
		if starStyle == "image" then
			text = text .. "Stars are images\n"
		elseif starStyle == "circle" then
			text = text .. "Stars are circles\n"
		elseif starStyle == "point" then
			text = text .. "Stars are points\n"
		end
		
		
		if showVelocity then
			text = text .. "Velocity is shown\n"
		end
		love.graphics.setColor({255, 255, 255})
		love.graphics.print(text, 5, 5)
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "space" then
		pause = not pause
	elseif key == "w" then
		wall = not wall
	elseif key == "g" then
		camX = 0
		camY = 0
		pause = true
		generate()
	elseif key == "n" then
		camX = 0
		camY = 0
		stars = {}
	elseif key == "i" then
		info = not info
	elseif key == "c" then
		starColor = not starColor
	elseif key == "s" then
		if starStyle == "image" then starStyle = "circle"
		elseif starStyle == "circle" then starStyle = "point"
		elseif starStyle == "point" then starStyle = "image"
		end
	elseif key == "v" then
		showVelocity = not showVelocity
	end
end

function love.mousepressed(x, y, button, isTouch)
	if button == 1 then
		table.insert(stars, {x + camX, y + camY, 0, 0, 0, 0, 1, {love.math.random(224, 255), love.math.random(224, 255), love.math.random(224, 255)}})
	elseif button == 3 then
		for k, v in pairs(stars) do
			v[3] = 0
			v[4] = 0
		end
	end
end
