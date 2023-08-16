-- button.lua
local Inky = require("library.inky")

return Inky.defineElement(function(self, ...)
	-- self.props.color = {1,1,1,0.7}
	-- self.props.state
	-- self:onPointer("release", function()
	-- 	self.props.color = rc()
	-- end)

    self:onPointerEnter(function(self, pointer, ...)
		self.props.color = {1,1,0.2,1}
	end)

    self:onPointerExit(function(self, pointer, ...)
		-- self.props.color = self.props.state and {0.2,1,0.2,0.7} or {1,0.2,0.2,0.7}
	end)

	return function(_, x, y, w, h)
		love.graphics.setColor(self.props.color)
		love.graphics.draw(self.props.image, x, y)
	end
end)