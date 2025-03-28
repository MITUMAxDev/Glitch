local function getGlobalTable()
	return typeof(getfenv().getgenv) == "function" and typeof(getfenv().getgenv()) == "table" and getfenv().getgenv() or _G
end

if getGlobalTable().ESPLib then
	return getGlobalTable().ESPLib
end

local ESPChange = Instance.new("BindableEvent")
local espLib = {
	ESPValues = setmetatable({}, {
		__index = function(self, name)
			return espLib.Values[name]
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

local function applyESP(obj, espSettings)
	if not obj then return end
	obj = obj:IsA("Model") and obj or obj:FindFirstAncestorOfClass("Model") or obj

	-- Default settings
	espSettings = espSettings or {}
	espSettings.Color = espSettings.Color or Color3.new(1, 1, 1)
	espSettings.Text = espSettings.Text or obj.Name
	espSettings.ESPName = espSettings.ESPName or ""
	espSettings.HighlightEnabled = espSettings.HighlightEnabled ~= false

	-- Remove any existing ESP for this object
	deapplyESP(obj)

	-- Create ESP Folder
	local ESPFolder = Instance.new("Folder", obj)
	ESPFolder.Name = "ESPFolder"

	-- Highlight
	if espSettings.HighlightEnabled then
		local hl = Instance.new("Highlight", ESPFolder)
		hl.Adornee = obj
		hl.OutlineColor = espSettings.Color
		hl.FillColor = espSettings.Color
		hl.FillTransparency = 0.7
		hl.OutlineTransparency = 0.3
		hl.Enabled = not not espLib.ESPValues[espSettings.ESPName]
	end

	-- Billboard GUI for Name
	local bg = Instance.new("BillboardGui", ESPFolder)
	bg.Adornee = obj
	bg.AlwaysOnTop = true
	bg.Size = UDim2.fromOffset(200, 50)
	bg.MaxDistance = 100
	bg.Enabled = not not espLib.ESPValues[espSettings.ESPName]

	local label = Instance.new("TextLabel", bg)
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = espSettings.Color
	label.Text = espSettings.Text
	label.TextScaled = true
	label.TextStrokeTransparency = 0.5

	-- Add to applied ESP list
	table.insert(espLib.ESPApplied, obj)

	-- Connection for cleanup
	local conn = obj.Destroying:Connect(function()
		deapplyESP(obj)
	end)
	connections[obj] = conn
end

local function deapplyESP(obj)
	if not obj then return end
	obj = obj:IsA("Model") and obj or obj:FindFirstAncestorOfClass("Model") or obj

	-- Remove from applied list
	local found = table.find(espLib.ESPApplied, obj)
	if found then
		table.remove(espLib.ESPApplied, found)
	end

	-- Disconnect any existing connections
	if connections[obj] then
		connections[obj]:Disconnect()
		connections[obj] = nil
	end

	-- Remove ESP Folder
	local espFolder = obj:FindFirstChild("ESPFolder")
	if espFolder then
		espFolder:Destroy()
	end
end

-- Assign functions to library
espLib.ApplyESP = applyESP
espLib.DeapplyESP = deapplyESP

-- Store in global table
getGlobalTable().ESPLib = espLib

return espLib
