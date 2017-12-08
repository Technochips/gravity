function love.load(args)
	JSON = require "lib.JSON"
	
	starImg = love.graphics.newImage("star.png")
	stars = {} -- STAR = {x, y, velX, velY, mass, color, unaccelerable}
	
	starsV = {} -- STAR VISUALISATION = {velX, velY, accelX, accelY}
	
	pause = false
	wall = true
	
	info = false
	
	starColor = true
	
	--G = 6.674 * 10^-11 * 1^3 * 1^-1 * 1^-2
	
	camX = 0
	camY = 0
	camspeed = 50
	
	argt = {}
	
	for i = 1, #args do
		if args[i] == "-g" and (not argt["g-"]) then	
			argt["-g"] = true
			generate()
			pause = true
		end
		if args[i] == "-l" and (not argt["-l"]) then	
			argt["-t"] = true
			loadUniverse(args[i + 1])
			i = i + 1
		end
	end
	
	eraseBrushSize = 25
	circleSize = 5
	
	starStyle = "image"
	
	wallMode = "wormhole"
	
	showVelocity = false
	shownVelMul = 8
	showAcceleration = false
	shownAccMul = 32
	
	scrollspeed = 10
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
			starsV[k] = {0, 0, 0, 0}
			if wall then
				if wallMode == "wormhole" then
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
				elseif wallMode == "bounce" then
					if v[1] < 0 or v[1] > love.graphics.getWidth() then
						v[3] = -v[3]
					end
					
					if v[2] < 0 or v[2] > love.graphics.getHeight() then
						v[4] = -v[4]
					end
				end
			end
			if not v[7] then
				for l, w in pairs(stars) do
					if k ~= l then
						local r = math.sqrt((v[1] - w[1])^2 + (v[2] - w[2])^2)
						local a = math.atan2(v[1] - w[1], v[2] - w[2])
						if r > 1 then
							--local vx = math.sin(a) / r / v[5] * w[5]
							--local vy = math.cos(a) / r / v[5] * w[5]
							local vx = math.sin(a) / w[5] / r^2
							local vy = math.cos(a) / w[5] / r^2
							
							v[3] = v[3] - vx
							v[4] = v[4] - vy
							
							starsV[k][3] = starsV[k][3] + vx
							starsV[k][4] = starsV[k][4] + vy
						end
					end
				end
			end
		end
		for k, v in pairs(stars) do
			v[1] = v[1] + v[3]
			v[2] = v[2] + v[4]
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
				table.insert(stars, {x, y, 0, 0, map_range(love.math.random(), 0, 1, 0.25, 10), {love.math.random(224, 255), love.math.random(224, 255), love.math.random(224, 255)}, false})
			end
			
				y = y + 5
		end
		x = x + 5
	end
	print("TOTAL OF " .. #stars .. " STARS CREATED")
end

function loadUniverse(file)
	local contents, e = nil
	if not love.filesystem.exists(file) then
		file = "saves/" .. file
		if not love.filesystem.exists(file) then
			e = "File doesn't exists"
		end
	end
	if e == nil then
		local contents, e = love.filesystem.read(file)
		if contents == nil then
			print("Something went wrong while loading!\n" .. e)
		else
			local decoded = JSON:decode(contents)
			stars = {}
			if decoded.properties.pause ~= nil then pause = decoded.properties.pause end
			if decoded.properties.wall ~= nil then wall = decoded.properties.wall end
			if decoded.properties.camX ~= nil then camX = decoded.properties.camX end
			if decoded.properties.camY ~= nil then camY = decoded.properties.camY end
			if decoded.properties.info ~= nil then info = decoded.properties.info end
			if decoded.properties.starColor ~= nil then starColor = decoded.properties.starColor end
			if decoded.properties.starStyle ~= nil then starStyle = decoded.properties.starStyle end
			if decoded.properties.showVelocity ~= nil then showVelocity = decoded.properties.showVelocity end
			if decoded.properties.showAcceleration ~= nil then showAcceleration = decoded.properties.showAcceleration end
			if decoded.properties.camspeed ~= nil then camspeed = decoded.properties.camspeed end
			
			stars = decoded.stars
		end
	end
end

function saveUniverse()
	--"saves/" .. os.time
	local decoded = {}
	decoded.stars = stars
	decoded.properties = {}
	decoded.properties.pause = pause
	decoded.properties.wall = wall
	decoded.properties.camX = camX
	decoded.properties.camY = camY
	decoded.properties.info = info
	decoded.properties.starColor = starColor
	decoded.properties.starStyle = starStyle
	decoded.properties.showVelocity = showVelocity
	decoded.properties.showAcceleration = showAcceleration
	decoded.properties.camspeed = camspeed
	
	local encoded = JSON:encode(decoded)
	
	local filePath = "saves/" .. os.time()
	
	if not love.filesystem.isDirectory("saves") then
		love.filesystem.createDirectory("saves")
	end
	
	success, e = love.filesystem.write(filePath, encoded)
	if not success then
		print("Something went wrong while saving!\n" .. e)
	else
		print("Saved in " .. filePath)
	end
end

function love.draw()
	if love.mouse.isDown(2) then
		love.graphics.setColor({255, 255, 255})
		love.graphics.circle("line", love.mouse.getX(), love.mouse.getY(), eraseBrushSize)
	end
	
	for k, v in pairs(stars) do
		if starColor then love.graphics.setColor(v[6]) else love.graphics.setColor({255, 255, 255}) end
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
		if showAcceleration then
			if starsV[k] then
				if starsV[k][3] and starsV[k][4] then
					love.graphics.line(v[1] - camX, v[2] - camY, (v[1] - camX) - (starsV[k][3] * shownAccMul), (v[2] - camY) - (starsV[k][4] * shownAccMul))
				end
			end
		end
	end
	if wall then
		love.graphics.setColor({255, 255, 255})
		love.graphics.rectangle("line", -camX, -camY, love.graphics.getWidth(), love.graphics.getHeight())
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
			if wallMode == "wormhole" then
				text = text .. "Walls teleports stars\n"
			elseif wallMode == "bounce" then
				text = text .. "Stars bounces on walls\n"
			end
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
		if showAcceleration then
			text = text .. "Acceleration is shown\n"
		end
		
		text = text .. "Camera speed: " .. camspeed .. "\n"
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
		else starStyle = "image" end
	elseif key == "v" then
		showVelocity = not showVelocity
	elseif key == "o" then
		saveUniverse()
	elseif key == "a" then
		showAcceleration = not showAcceleration
	elseif key == "m" then
		if wallMode == "wormhole" then wallMode = "bounce"
		else wallMode = "wormhole" end
	end
end

function love.mousepressed(x, y, button, isTouch)
	if button == 1 then
		--table.insert(stars, {x + camX, y + camY, 0, 0, 1, {love.math.random(224, 255), love.math.random(224, 255), love.math.random(224, 255)}, false})
		table.insert(stars, {x + camX, y + camY, 0, 0, map_range(love.math.random(), 0, 1, 0.25, 10), {love.math.random(224, 255), love.math.random(224, 255), love.math.random(224, 255)}, false})
	elseif button == 3 then
		for k, v in pairs(stars) do
			v[3] = 0
			v[4] = 0
		end
	end
end

function love.wheelmoved(x,y)
	if camspeed + y * scrollspeed >= 0 then
		camspeed = camspeed + y * scrollspeed
	end
end

function map_range(value, low1, high1, low2, high2)
	return low2 + (high2 - low2) * (value - low1) / (high1 - low1)
end
