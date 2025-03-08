# Embed
discord embed builder

example:
```lua
local embed = require(script.Parent)
local SecureWebhook = require(script.Parent.Parent.SecureWebhook)

embed:Create(function(self) 
	-- create one embed
	self:Build():SetTitle("Hello World!"):SetColor(Color3.new(1, 0, 0)):SetTimestamp(workspace:GetServerTimeNow()):SetDescription("bloxian")
end):Call():Then(function(self)  
	SecureWebhook.generic(
		"TEST_URL",
		self:FetchBody()
	)
end)
```
