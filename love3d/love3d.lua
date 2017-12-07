local graphics = require("love3d.graphics")

function projection(x, y, z, focal, camx, camy, camz, rotx, roty, rotz)
	return (x - camx) * focal / (z - camz) + love.graphics.getWidth() / 2, (y - camy) * focal / (z - camz) + love.graphics.getHeight() / 2
end
