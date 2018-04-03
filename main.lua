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
	camspeed = 64

	zoom = 1
	
	argt = {}
	
	for i = 1, #args do
		if args[i] == "-g" and (not argt["g-"]) then	
			argt["-g"] = true
			generate()
			pause = true
		end
		if args[i] == "-l" and (not argt["-l"]) then	
			argt["-l"] = true
			loadUniverse(args[i + 1])
			i = i + 1
		end
	end
	
	eraseBrushSize = 25
	circleSize = 5
	
	starStyle = "image"
	
	wallMode = "stop"
	
	showVelocity = false
	shownVelMul = 8
	showAcceleration = false
	shownAccMul = 32
	
	scrollspeed = 2
	
	focus = nil
	starInfo = nil
	
	starInfoCircle = 25
	
	GM = 1
	GMscrollspeed = 2

	zoomspeed = 2
end

function love.update(dt)
	if love.mouse.isDown(2) then
		for k, v in pairs(stars) do
			local r = math.sqrt((v[1] - ((love.mouse.getX() / zoom) + camX))^2 + (v[2] - ((love.mouse.getY() / zoom) + camY))^2) * zoom
			
			if r <= eraseBrushSize then
				table.remove(stars, k)
			end
		end
	end
	if focus == nil then
		if love.keyboard.isScancodeDown("right") then
			camX = camX + camspeed / zoom
		end
		if love.keyboard.isScancodeDown("down") then
			camY = camY + camspeed / zoom
		end
		if love.keyboard.isScancodeDown("left") then
			camX = camX - camspeed / zoom
		end
		if love.keyboard.isScancodeDown("up") then
			camY = camY - camspeed / zoom
		end
	else
		if stars[focus] ~= nil then
			camY = stars[focus][2] - ((love.graphics.getHeight() / zoom) / 2)
			camX = stars[focus][1] - ((love.graphics.getWidth() / zoom) / 2)
		end
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
				elseif wallMode == "stop" then
					if v[1] < 0 then
						v[1] = 0
						v[3] = 0
					elseif v[1] > love.graphics.getWidth() then
						v[1] = love.graphics.getWidth()
						v[3] = 0
					end
					
					if v[2] < 0 then
						v[2] = 0
						v[4] = 0
					elseif v[2] > love.graphics.getHeight() then
						v[2] = love.graphics.getHeight()
						v[4] = 0
					end
				end
			end
			if not v[7] then
				for l, w in pairs(stars) do
					if k ~= l then
						local r = math.sqrt((v[1] - w[1])^2 + (v[2] - w[2])^2)
						local a = math.atan2(v[1] - w[1], v[2] - w[2])
						if r > 1 then
							local vx = math.sin(a) / w[5] * GM / r
							local vy = math.cos(a) / w[5] * GM / r
							
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
				generateStar(x, y)
			end
			
				y = y + 5
		end
		x = x + 5
	end
	print("TOTAL OF " .. #stars .. " STARS CREATED")
end

function loadUniverse(file)
	local contents, e = nil
	fileinfo = love.filesystem.getInfo(file)
	if fileinfo == nil or fileinfo.type ~= "file" then--not love.filesystem.exists(file) then
		file = "saves/" .. file
		fileinfo = love.filesystem.getInfo(file)
		if fileinfo == nil or fileinfo.type ~= "file" then
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
			local byteColor = true
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
			if decoded.properties.byteColor ~= nil then byteColor = decoded.properties.byteColor end
			
			stars = decoded.stars
			
			if byteColor then
				for i = 1, #stars do
					stars[i][6][1] = stars[i][6][1] / 255
					stars[i][6][2] = stars[i][6][2] / 255
					stars[i][6][3] = stars[i][6][3] / 255
				end
			end
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

function drawUniverse(x, y, sx, sy)
	love.graphics.push()
	love.graphics.scale(sx,sy)
	love.graphics.translate(-x,-y)
	for k, v in pairs(stars) do
		if v[1] > x and v[1] < (love.graphics.getWidth() / zoom) + x
		and v[2] > y and v[2] < (love.graphics.getHeight() / zoom) + y then
			if starColor then love.graphics.setColor(v[6]) else love.graphics.setColor({1, 1, 1}) end
			if starStyle == "image" then
				love.graphics.draw(starImg, v[1] - (starImg:getWidth() / 2), v[2] - (starImg:getHeight() / 2))
			elseif starStyle == "circle" then
				love.graphics.circle("fill", v[1], v[2], circleSize)
			elseif starStyle == "point" then
				love.graphics.points(v[1], v[2])
			end
			if showVelocity then
				love.graphics.line(v[1], v[2], v[1] + (v[3] * shownVelMul), v[2] + (v[4] * shownVelMul))
			end
			if showAcceleration then
				if starsV[k] then
					if starsV[k][3] and starsV[k][4] then
						love.graphics.line(v[1], v[2], v[1] - (starsV[k][3] * shownAccMul), v[2] - (starsV[k][4] * shownAccMul))
					end
				end
			end
		end
	end
	if wall then
		love.graphics.setColor({1, 1, 1})
		love.graphics.rectangle("line", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	end
	love.graphics.pop()
end

function drawUI()
	if starInfo ~= nil then
		if stars[starInfo] ~= nil then
			if stars[starInfo][1] > camX and stars[starInfo][1] < (love.graphics.getWidth() / zoom) + camX
			and stars[starInfo][2] > camY and stars[starInfo][2] < (love.graphics.getHeight() / zoom) + camY then
				local starInfoText = ""
				starInfoText = starInfoText .. "X: " .. stars[starInfo][1] .. "\n"
				starInfoText = starInfoText .. "Y: " .. stars[starInfo][2] .. "\n"
				--starInfoText = starInfoText .. "Horizontal velocity: " .. stars[starInfo][3] .. "\n"
				--starInfoText = starInfoText .. "Vertical velocity: " .. stars[starInfo][4] .. "\n"
				starInfoText = starInfoText .. "Mass: " .. stars[starInfo][5] .. "\n"
				if stars[starInfo][7] then tarInfoText = starInfoText .. "Unaccelerable\n" end
				
				love.graphics.setColor(1, 1, 1)
				love.graphics.circle("line", (stars[starInfo][1] - camX) * zoom, (stars[starInfo][2] - camY) * zoom, starInfoCircle)
				love.graphics.print(starInfoText, ((stars[starInfo][1] - camX) * zoom) + starInfoCircle, ((stars[starInfo][2] - camY) * zoom) + starInfoCircle)
			end
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
			if wallMode == "wormhole" then
				text = text .. "Walls teleports stars\n"
			elseif wallMode == "bounce" then
				text = text .. "Stars bounces on walls\n"
			elseif wallMode == "stop" then
				text = text .. "Stars stops on walls\n"
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
		text = text .. "Gravity multiplier: " .. GM .. "\n"
		text = text .. "Zoom: " .. zoom .. "\n"
		love.graphics.setColor({1, 1, 1})
		love.graphics.print(text, 5, 5)
	end
end

function love.draw()
	--gameCanvas = love.graphics.newCanvas()
	--UICanvas = love.graphics.newCanvas()
	--love.graphics.setCanvas(gameCanvas)
	drawUniverse(camX, camY, zoom, zoom)
	--love.graphics.setCanvas(UICanvas)
	if love.mouse.isDown(2) then
		love.graphics.setColor({1, 1, 1})
		love.graphics.circle("line", love.mouse.getX(), love.mouse.getY(), eraseBrushSize)
	end
	drawUI()
	--love.graphics.setCanvas()
	--love.graphics.draw(gameCanvas)
	--love.graphics.draw(UICanvas)
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
		zoom = 1
		generate()
	elseif key == "n" then
		camX = 0
		camY = 0
		starInfo = nil
		focus = nil
		zoom = 1
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
		elseif wallMode == "bounce" then wallMode = "stop"
		else wallMode = "wormhole" end
	elseif key == "pageup" then
		GM = GM * GMscrollspeed
	elseif key == "pagedown" then
		GM = GM / GMscrollspeed
	elseif key == "home" then
		zoom = zoom * zoomspeed
	elseif key == "end" then
		zoom = zoom / zoomspeed
	end
end

function love.mousepressed(x, y, button, isTouch)
	if button == 1 then
		--table.insert(stars, {x + camX, y + camY, 0, 0, 1, {love.math.random(224, 255), love.math.random(224, 255), love.math.random(224, 255)}, false})
		generateStar((x / zoom) + camX, (y / zoom) + camY)
	elseif button == 3 then
		for k, v in pairs(stars) do
			v[3] = 0
			v[4] = 0
		end
	end
end

function love.wheelmoved(x,y)
	if camspeed / scrollspeed >= 0 then
		if y > 0 then
			camspeed = camspeed * scrollspeed
		elseif y < 0 then
			camspeed = camspeed / scrollspeed
		end
	end
end

function map_range(value, low1, high1, low2, high2)
	return low2 + (high2 - low2) * (value - low1) / (high1 - low1)
end

function addStar(x, y, velX, velY, mass, color, unaccelerable)
	table.insert(stars, {x, y, velX, velY, mass, color, unaccelerable})
end
function generateStar(x, y)
	addStar(x, y, 0, 0, map_range(love.math.random(), 0, 1, 0.25, 10), {map_range(love.math.random(), 0, 1, 224/255, 1), map_range(love.math.random(), 0, 1, 224/255, 1), map_range(love.math.random(), 0, 1, 224/255, 1)}, false)
end
