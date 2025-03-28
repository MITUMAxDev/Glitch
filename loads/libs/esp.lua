--[[ Aaaa ]]

local function getGlobalTable()
	return typeof(getfenv().getgenv) == "function" and typeof(getfenv().getgenv()) == "table" and getfenv().getgenv() or _G
end

local ESPLib = getGlobalTable().ESPLib
if ESPLib then 
	return ESPLib 
end

local ESPChange = Instance.new("BindableEvent")
local espLib = {
	ESPValues = setmetatable({}, {
		__index = function(self, name)
			return espLib.Values[name] or false
		end,
		__newindex = function(self, name, value)
			if espLib.Values[name] == value then return end
			espLib.Values[name] = value
			ESPChange:Fire()
		end
	}),
	Values = {},
	ESPApplied = {}
}
local connections = {}

local function safeApplyESP(obj, espSettings)
	-- Comprehensive error checking
	if not obj then 
		warn("ESPLib: Cannot apply ESP to nil object")
		return 
	end

	-- Ensure we have a model or find the model
	local targetModel = obj:IsA("Model") and obj or obj:FindFirstAncestorOfClass("Model")
	if not targetModel then
		warn("ESPLib: Could not find a valid Model for ESP")
		return
	end

	-- Default settings with comprehensive fallbacks
	espSettings = espSettings or {}
	espSettings.Color = espSettings.Color or Color3.new(1, 1, 1)
	espSettings.Text = espSettings.Text or targetModel.Name
	espSettings.ESPName = espSettings.ESPName or tostring(targetModel)
	espSettings.HighlightEnabled = espSettings.HighlightEnabled ~= false

	-- Remove any existing ESP for this object
	pcall(function() deapplyESP(targetModel) end)

	-- Create ESP Folder
	local ESPFolder = Instance.new("Folder", targetModel)
	ESPFolder.Name = "ESPFolder"

	-- Highlight
	if espSettings.HighlightEnabled then
		local hl = Instance.new("Highlight", ESPFolder)
		hl.Adornee = targetModel
		hl.OutlineColor = espSettings.Color
		hl.FillColor = espSettings.Color
		hl.FillTransparency = 0.7
		hl.OutlineTransparency = 0.3
		hl.Enabled = not not espLib.ESPValues[espSettings.ESPName]
	end

	-- Billboard GUI for Name and Dot
	local bg = Instance.new("BillboardGui", ESPFolder)
	bg.Adornee = targetModel
	bg.AlwaysOnTop = true
	bg.Size = UDim2.fromOffset(200, 50)
	bg.MaxDistance = 100
	bg.Enabled = not not espLib.ESPValues[espSettings.ESPName]

	-- Small dot
	local dot = Instance.new("Frame", bg)
	dot.Size = UDim2.fromOffset(4, 4)
	dot.Position = UDim2.fromScale(0.5, 0)
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.BackgroundColor3 = espSettings.Color
	dot.BorderSizePixel = 0

	local corner = Instance.new("UICorner", dot)
	corner.CornerRadius = UDim.new(1, 0)

	-- Name Label
	local label = Instance.new("TextLabel", bg)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 1, -10)
	label.Position = UDim2.new(0, 0, 1, 0)
	label.AnchorPoint = Vector2.new(0, 1)
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = espSettings.Color
	label.Text = espSettings.Text
	label.TextScaled = true
	label.TextStrokeTransparency = 0.5

	-- Add to applied ESP list
	table.insert(espLib.ESPApplied, targetModel)

	-- Connection for cleanup
	local conn = targetModel.Destroying:Connect(function()
		pcall(function() deapplyESP(targetModel) end)
	end)
	connections[targetModel] = conn

	return targetModel
end

local function deapplyESP(obj)
	if not obj then return end
	local targetModel = obj:IsA("Model") and obj or obj:FindFirstAncestorOfClass("Model")
	if not targetModel then return end

	-- Remove from applied list
	local found = table.find(espLib.ESPApplied, targetModel)
	if found then
		table.remove(espLib.ESPApplied, found)
	end

	-- Disconnect any existing connections
	if connections[targetModel] then
		connections[targetModel]:Disconnect()
		connections[targetModel] = nil
	end

	-- Remove ESP Folder
	local espFolder = targetModel:FindFirstChild("ESPFolder")
	if espFolder then
		espFolder:Destroy()
	end
end

-- Assign functions to library
espLib.ApplyESP = safeApplyESP
espLib.DeapplyESP = deapplyESP

-- Store in global table
getGlobalTable().ESPLib = espLib

return espLib
