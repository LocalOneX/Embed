--!strict
--[=[ Onex v1.0.0
	----------
		Discord Embeded Builder; Compatable with SecureWebhook 
		
		originally this was going to look sexy and good, but i kinda lost it 
		and it looks kinda horible, it should still work tho!
		
		Custom libraries implemented;
			Assert; initialize assertion method, looks cleaner than the normal assert methods.
			----
				check whether or not the value being passed is a table or not.
				Assert.table(value: any)
				
				check whether or not the value being passed is a string or not.
				Assert.string(value: any)
			
			Pyf; makes functions work sorta like python, it looks super clean!
			----
				starts a pyf instance
				local self = Pyf.new/Pyf:Create (callback: function)
				
				calls the function within the instance
				self:Call(...args)  
				
				after the execution is over, it will Then call another function
				self:Then(callback: function)
			
			SecureWebhook; make sure to have this in your game for the best experience
			--- https://github.com/LocalOneX/SecureWebhook/blob/main/SecureWebhook.lua
			
		
		creates a embed instance
		local self = Embed:Create
			
			--- used to easily get the table for api
			self:FetchBody
			
			--- create a new embed
			local embed = self:Build
			
			-- Sets the title of the embed.
			embed:SetTitle(title: string)

			-- Sets the description of the embed.
			embed:SetDescription(description: string)

			-- Sets the URL of the embed.
			embed:SetUrl(url: string)

			-- Sets the color of the embed.
			embed:SetColor(color: number)

			-- Sets the timestamp of the embed.
			embed:SetTimestamp(timestamp: number)

			-- Sets the footer of the embed with optional icon.
			embed:SetFooter(text: string, icon_url: string?)

			-- Sets the image of the embed.
			embed:SetImage(image: string)

			-- Sets the thumbnail of the embed.
			embed:SetThumbnail(thumbnail: string)

			-- Sets the author of the embed with an optional icon URL.
			embed:SetAuthor(name: string, url: string, icon_url: string?)

			-- Adds a field to the embed, with an optional inline flag.
			embed:AddField(name: string, value: string, inline: boolean?)

			-- Removes a field from the embed by its index.
			embed:RemoveField(int: number) 
	
	Example usage:
	embed:Create(function(self) 
		-- create one embed
		self:Build():SetTitle("test")
	end):Call():Then(function(self) 
		SecureWebhook.generic(
			"DISCORD_URL",
			self:FetchBody()
		)
	end)
--]=]-------[TYPES]--------------
export type Embed = {
	title: string?,
	description: string?,
	url: string?,
	color: number?,
	timestamp: string?,
	footer: {
		text: string,
		icon_url: string?
	}?,
	image: {
		url: string
	}?,
	thumbnail: {
		url: string
	}?,
	author: {
		name: string,
		url: string?,
		icon_url: string?
	}?,
	fields: {
		{ name: string, value: string, inline: boolean? }
	}?
} 
--[=[
	@objective; make assertion easy and simple!
	@class Assert
	
	Assert.table(false) --> error
	initialize assertion method, looks cleaner than the normal assert methods.
--]=]
local Assert; do
	
	Assert = {}
	
	function Assert.table(value: {}?)
		assert( typeof(value) == "table" , debug.traceback(string.format("(expected table, but got %s instead)", typeof(value))))
	end
	
	function Assert.string(value: string?)
		assert( typeof(value) == "string" , debug.traceback(string.format("(expected string, but got %s instead)", typeof(value))))
	end
	
	function Assert.number(value: number?)
		assert( typeof(value) == "number" , debug.traceback(string.format("(expected number, but got %s instead)", typeof(value))))
	end
	
	function Assert.nilOrString(value:string?)
		if value == nil then
			return
		end
		
		assert( typeof(value) == "string" , debug.traceback(string.format("(expected string, but got %s instead)", typeof(value))))

	end
	
	function Assert.nilOrBoolean(value:string?)
		if value == nil then
			return
		end

		assert( typeof(value) == "boolean" , debug.traceback(string.format("(expected boolean, but got %s instead)", typeof(value))))

	end
	
end

--[=[
	@objective; make functions as they would in Python.
	@class pyf
	
	Pyf.new():Call():Then(function() print"finished" end) --> 'finished'
	this makes code look 100x cleaner. So far it is not optimized and purposed for multiple uses
--]=]
local Pyf; do
	
	type callback = (any) -> (...any)
	
	type p_schema = {
		_call: callback;
		_finishedCall: boolean,
		_callAttempts: number,
		_debug: callback,
		_debris: {any},
		Then: (self: p_schema, callback: callback) -> nil,
		Create: (self: p_schema, callback: callback) -> p_schema,
		Call: (self: p_schema, callback: callback) -> p_schema,
	}
	
	Pyf = {} 
	
	--- alias to (:Create)
	function Pyf.new(callback, ...): p_schema
		local raw = {
			_call = callback;
			_finishedCall = false;
			_callAttempts = 0;
			_debug = warn;
			_debris = {...}
		}
		
		local self = setmetatable(raw, {__index = Pyf; __call = function(self, ...) return self:Call(...) end}) 
		
		return self
	end
	
	function Pyf:Create(callback, ...): p_schema return Pyf.new(callback, ...) end

	function Pyf:Call(...): p_schema
		--self._called = true 
		task.spawn(function(...)
			self._call(...)
			self._finishedCall = true
		end, ...) 

		return self
	end
	
	function Pyf:Then(callback): p_schema
		
		--- put this into a thread to get rid of any issues
		task.spawn(function()
			--repeat task.wait() until (self._finishedCall == true)
			
			if not self._call then
				do
					local _s = tick()
					while task.wait() do
						if (self._finishedCall == true) then
							break
						end
						--- this shouldnt run forever (it isnt ideal), so add a timeout
						if (tick() - _s) > 3 then error(string.format("%s:timeout:", debug.traceback())) end
					end 
				end
			end 

			callback(unpack(self._debris))
			
			--- not sure how this will go 
			self._finishedCall = false
		end)
		
		return self
	end 
	
end  

--- initialize SecureWebhook
---  
local SecureWebhook; do
	if script.Parent.Name == "SecureWebhook" then
		SecureWebhook = require(script.Parent)
	elseif script.Parent.Parent:FindFirstChild("SecureWebhook") then
		SecureWebhook = require(script.Parent.Parent:FindFirstChild("SecureWebhook"))
	end
end

--[=[
	@objective; make embeded as simple and as sexy as can be.
	@class Embed
--]=]

local Embed = {
	_lastUpdated = 1741446742.166044;
	_VERSION = "v1.0.0";
	_repository = "";
}

export type e_schema = {
	SetTitle: (self: e_schema, title: string) -> e_schema,
	SetDescription: (self: e_schema, description: string) -> e_schema,
	SetUrl: (self: e_schema, url: string) -> e_schema,
	SetColor: (self: e_schema, color: number) -> e_schema,
	SetTimestamp: (self: e_schema, timestamp: number) -> e_schema,
	SetFooter: (self: e_schema, text: string, icon_url: string?) -> e_schema,
	SetImage: (self: e_schema, image: string) -> e_schema,
	SetThumbnail: (self: e_schema, thumbnail: string) -> e_schema,
	SetAuthor: (self: e_schema, name: string, url: string, icon_url: string?) -> e_schema,
	AddField: (self: e_schema, name: string, value: string, inline: boolean?) -> e_schema,
	RemoveField: (self: e_schema, int: number) -> e_schema,
}

export type embed_schema = {
	Create: (self: embed_schema, buildCallback: (self: e_schema) -> nil) -> embed_schema,
	Build: (self: embed_schema) -> e_schema,
	FetchBody: (self: embed_schema) -> { embeds: { e_schema } }
} 

function Embed:Create(buildCallback): embed_schema
	local raw = {
		_embeds = {} :: { e_schema },
	}

	--- actual embed builder
	local embed = {}
	function embed:Create(): e_schema
		local self: e_schema = {}
		setmetatable(self, { __index = embed })
		raw._embeds[#raw._embeds + 1] = self
		return self
	end

	function embed:SetTitle(title: string): e_schema
		Assert.string(title)
		self.title = title
		return self
	end

	function embed:SetDescription(description: string): e_schema
		Assert.string(description)
		self.description = description
		return self
	end

	function embed:SetUrl(url: string): e_schema
		Assert.string(url)
		self.url = url
		return self
	end

	function embed:SetColor(color: number): e_schema
		local function hexToDecimal(hex: string): number
			return tonumber(hex, 16) or error("Invalid hex string: " .. tostring(hex))
		end
		
		if typeof(color) == "Color3" then
			color = color:ToHex()
		end
		
		--Assert.number(color)
		self.color = hexToDecimal(color)
		return self
	end

	function embed:SetTimestamp(timestamp: number): e_schema
		--Assert.number(timestamp)
		
		if typeof(timestamp) == 'number' then
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ", timestamp)
		end
		
		self.timestamp = timestamp
		return self
	end

	function embed:SetFooter(text: string, icon_url: string?): e_schema
		Assert.string(text)
		Assert.nilOrString(icon_url)
		self.footer = { text, icon_url }
		return self
	end

	function embed:SetImage(image: string): e_schema
		Assert.string(image)
		self.image = { url = image }
		return self
	end

	function embed:SetThumbnail(thumbnail: string): e_schema
		Assert.string(thumbnail)
		self.thumbnail = { url = thumbnail }
		return self
	end

	function embed:SetAuthor(name: string, url: string, icon_url: string?): e_schema
		Assert.string(name)
		Assert.string(url)
		Assert.nilOrString(icon_url)
		self.author = { name = name, url = url, icon_url = icon_url }
		return self
	end

	function embed:AddField(name: string, value: string, inline: boolean?): e_schema
		Assert.string(name)
		Assert.string(value)
		Assert.nilOrBoolean(inline)

		if not self.fields then
			self.fields = {}
		end

		table.insert(self.fields, { name = name, value = value, inline = inline })
		return self
	end

	function embed:RemoveField(int: number): e_schema
		Assert.number(int)

		if not self.fields then
			return self
		end

		table.remove(self.fields, int)
		return self
	end

	function raw:Build(): e_schema
		return embed:Create()
	end

	function raw:FetchBody(): { embeds: { e_schema } }
		return { embeds = self._embeds }
	end

	local pyfInstance = Pyf:Create(function()
		buildCallback(raw)
	end, raw)

	setmetatable(raw, { __index = pyfInstance })

	return raw
end 

return Embed
