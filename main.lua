function love.load(args)
	love3d = require "love3d.love3d"
	
	camX, camY, camZ = getCamPosition()
	
	starImg = love.graphics.newImage("star.png")
	stars = {} -- STAR = {x, y, z, velX, velY, velZ, mass, color}
	table.insert(stars, {0, 0, 0, 0, 0, 0, 1, {255, 255, 255}})
	table.insert(stars, {250, 250, 250, 0, 0, 0, 1, {255, 255, 255}})
	
	pause = true
	wall = true
	
	info = false
	
	starColor = true
	
	--G = 6.674 * 10^-11 * 1^3 * 1^-1 * 1^-2
	
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
	
	uW = 300
	uH = 300
	uD = 300
	
	scrollspeed = 100
	
	visionradius = 250
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
	camX, camY, camZ = getCamPosition()
	if love.keyboard.isScancodeDown("right") then
		camX = camX + camspeed
	end
	if love.keyboard.isScancodeDown("down") then
		camZ = camZ - camspeed
	end
	if love.keyboard.isScancodeDown("left") then
		camX = camX - camspeed
	end
	if love.keyboard.isScancodeDown("up") then
		camZ = camZ + camspeed
	end
	if love.keyboard.isScancodeDown("pageup") then
		camY = camY - camspeed
	end
	if love.keyboard.isScancodeDown("pagedown") then
		camY = camY + camspeed
	end
	setCamPosition(camX, camY, camZ)
	if not pause then
		for k, v in pairs(stars) do
			if wall then
				if v[1] < 0 then
					v[1] = v[1] + uW
				elseif v[1] > uW then
					v[1] = v[1] - uW
				end
				
				if v[2] < 0 then
					v[2] = v[2] + uH
				elseif v[2] > uH then
					v[2] = v[2] - uH
				end
				
				if v[3] < 0 then
					v[3] = v[3] + uD
				elseif v[3] > uD then
					v[3] = v[3] - uD
				end
			end
			for l, w in pairs(stars) do
				if k ~= l then
					local r = math.sqrt((v[1] - w[1])^2 + (v[2] - w[2])^2 + (v[3] - w[3])^2)
					local a1 = math.atan2(v[1] - w[1], v[2] - w[2])
					local a2 = math.atan2(v[2] - w[2], v[3] - w[3])
					if r ~= 0 then
						local vx = math.sin(a1) / r
						local vy = math.cos(a1) / r
						local vz = math.cos(a2) / r
						
						v[4] = v[4] - vx
						v[5] = v[5] - vy
						v[6] = v[6] - vz
					end
				end
			end
		end
		for k, v in pairs(stars) do
			v[1] = v[1] + v[4]
			v[2] = v[2] + v[5]
			v[3] = v[3] + v[6]
		end
	end
end

function generate()
	stars = {}
	
	local x = 0
	while x < uW do
		local y = 0
		
		while y < uH do
			local z = 0
			
			while z < uD do
				local n = love.math.noise(x * 5, y * 5, z * 5) / 25
				local r = love.math.random()
				
				if r < n then
					local a1 = love.math.random() * (math.pi * 2)
					local a2 = love.math.random() * (math.pi * 2)
					local s = love.math.random() * 10
					table.insert(stars, {x, y, z, math.sin(a1) * s, math.cos(a1) * s, math.cos(a2) * s, 1, {love.math.random(224, 255), love.math.random(224, 255), love.math.random(224, 255)}})
				end
				z = z + 10
			end
			y = y + 10
		end
		x = x + 10
	end
	print("TOTAL OF " .. #stars .. " STARS CREATED")
end

function love.draw()
	if love.mouse.isDown(2) then
		love.graphics.setColor({255, 255, 255})
		love.graphics.circle("line", love.mouse.getX(), love.mouse.getY(), eraseBrushSize)
	end
	
	local x, y, z = getCamPosition()
	
	for k, v in pairs(stars) do
		local distance = math.sqrt((x - v[1])^2 + (y - v[2])^2 + (z - v[3])^2)
		local color = map_range(distance, visionradius, 0, 0, 255)
		
		if color > 0 then
			if starColor then love.graphics.setColor({v[8][1], v[8][2], v[8][3], color}) else love.graphics.setColor({255, 255, 255, color}) end
			if starStyle == "image" then
				--love.graphics.draw(starImg, v[1] - (starImg:getWidth() / 2) - camX, v[2] - (starImg:getHeight() / 2) - camY)
				draw(starImg, "center", v[1], v[2], v[3])
			elseif starStyle == "circle" then
				circle("fill", v[1], v[2], v[3], circleSize * map_range(distance, visionradius, 0, 0, 1))
			elseif starStyle == "point" then
				point(v[1], v[2], v[3])
			end
			
			if showVelocity then
				line(v[1], v[2], v[3], v[1] + (v[4] * shownVelMul), v[2] + (v[5] * shownVelMul), v[3] + (v[6] * shownVelMul))
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
		
		text = text .. "Vision radius is " .. visionradius .. "\n"
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
		--camX = 0
		--camY = 0
		pause = true
		generate()
	elseif key == "n" then
		--camX = 0
		--camY = 0
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
			v[4] = 0
			v[5] = 0
			v[6] = 0
		end
	end
end

function love.wheelmoved(x,y)
	if visionradius + y * scrollspeed >= 0 then
		visionradius = visionradius + y * scrollspeed
	end
end

function map_range(value, low1, high1, low2, high2)
	return low2 + (high2 - low2) * (value - low1) / (high1 - low1)
end
