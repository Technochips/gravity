local focal = 1000
local camx = 0
local camy = 0
local camz = 0
local rotx = 0
local roty = 0
local rotz = 0

function point(x, y, z)
	local nx, ny = nil
	if(z > camz) then
		nx, ny = projection(x,y,z,focal,camx,camy,camz,rotx,roty,rotz)
		love.graphics.points(nx, ny)
	end
	return nx, ny
end

function line(x1, y1, z1, x2, y2, z2)
	local nx1, nx2, ny1, ny2 = nil
	if z1 > camz and z2 > camz then
		nx1, ny1 = projection(x1, y1, z1, focal, camx, camy, camz, rotx, roty, rotz)
		nx2, ny2 = projection(x2, y2, z2, focal, camx, camy, camz, rotx, roty, rotz)
		love.graphics.line(nx1, ny1, nx2, ny2)
	end
	return nx1, ny1, nx2, ny2
end

function circle(mode, x, y, z, r)
	local nx, ny = nil
	if(z > camz) then
		nx, ny = projection(x,y,z,focal,camx,camy,camz,rotx,roty,rotz)
		love.graphics.circle(mode, nx, ny, r)
	end
	return nx, ny
end

function draw(drawable, mode, x, y, z)
	local nx, ny = nil
	if(z > camz) then
		nx, ny = projection(x,y,z,focal,camx,camy,camz,rotx,roty,rotz)
		if mode == "center" then
			love.graphics.draw(drawable, nx - (drawable:getWidth() / 2), ny - (drawable:getHeight() / 2), r)
		else
			error("Must has mode")
		end
	end
	return nx, ny
end

function setCamPosition(x, y, z)
	camx = x
	camy = y
	camz = z
end

function getCamPosition()
	return camx, camy, camz
end

function setCamRotation(x, y, z)
	rotx = x
	roty = y
	rotz = z
end

function getCamRotation()
	return rotx, roty, rotz
end
