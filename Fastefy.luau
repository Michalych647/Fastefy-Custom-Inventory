if not game:IsLoaded() then
	game.Loaded:Wait()
end

if getgenv().CustomInvLoaded then
	return
end
getgenv().CustomInvLoaded = true

local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Debris = game:GetService("Debris")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
local slotCount = isMobile and 8 or 10
local cellDim = isMobile and 58 or 75
local txtNameSize = isMobile and 11 or 14
local invW = isMobile and 395 or 520
local invH = isMobile and 180 or 260

local function createPrompt(titleText, descText, confirmText)
	local bindable = Instance.new("BindableEvent")
	local sg = Instance.new("ScreenGui")
	sg.Name = "ExecPrompt"
	sg.Parent = CoreGui
	
	local frame = Instance.new("Frame", sg)
	frame.Size = UDim2.new(0, 300, 0, 150)
	frame.Position = UDim2.new(0.5, -150, 0.5, -60)
	frame.BackgroundColor3 = Color3.fromRGB(25, 27, 29)
	frame.BackgroundTransparency = 1
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
	
	local title = Instance.new("TextLabel", frame)
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Text = titleText
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.BackgroundTransparency = 1
	title.TextTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	
	local desc = Instance.new("TextLabel", frame)
	desc.Size = UDim2.new(1, -40, 1, -90)
	desc.Position = UDim2.new(0, 20, 0, 40)
	desc.Text = descText
	desc.TextColor3 = Color3.fromRGB(200, 200, 200)
	desc.TextWrapped = true
	desc.BackgroundTransparency = 1
	desc.TextTransparency = 1
	desc.Font = Enum.Font.Gotham
	desc.TextSize = 14
	
	local cancel = Instance.new("TextButton", frame)
	cancel.Size = UDim2.new(0, 100, 0, 30)
	cancel.AnchorPoint = Vector2.new(0.5, 0.5)
	cancel.Position = UDim2.new(0.3, 0, 1, -25)
	cancel.Text = "Cancel"
	cancel.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
	cancel.BackgroundTransparency = 1
	cancel.TextTransparency = 1
	cancel.Font = Enum.Font.GothamBold
	cancel.TextSize = 14
	Instance.new("UICorner", cancel).CornerRadius = UDim.new(0, 6)
	
	local exec = Instance.new("TextButton", frame)
	exec.Size = UDim2.new(0, 100, 0, 30)
	exec.AnchorPoint = Vector2.new(0.5, 0.5)
	exec.Position = UDim2.new(0.7, 0, 1, -25)
	exec.Text = confirmText
	exec.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	exec.TextColor3 = Color3.fromRGB(0, 0, 0)
	exec.BackgroundTransparency = 1
	exec.TextTransparency = 1
	exec.Font = Enum.Font.GothamBold
	exec.TextSize = 14
	Instance.new("UICorner", exec).CornerRadius = UDim.new(0, 6)

	local function fadeOut(res)
		TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Position = UDim2.new(0.5, -150, 0.5, -60), BackgroundTransparency = 1}):Play()
		TweenService:Create(title, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
		TweenService:Create(desc, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
		TweenService:Create(cancel, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
		TweenService:Create(exec, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
		task.wait(0.2)
		sg:Destroy()
		bindable:Fire(res)
	end

	local function bindBtn(btn, isConfirm)
		btn.MouseButton1Down:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 90, 0, 27)}):Play() end)
		btn.MouseButton1Up:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 100, 0, 30)}):Play() end)
		btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 100, 0, 30)}):Play() end)
		btn.MouseButton1Click:Connect(function() fadeOut(isConfirm) end)
	end

	bindBtn(cancel, false)
	bindBtn(exec, true)

	TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {Position = UDim2.new(0.5, -150, 0.5, -75), BackgroundTransparency = 0.15}):Play()
	TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
	TweenService:Create(desc, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
	TweenService:Create(cancel, TweenInfo.new(0.3), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
	TweenService:Create(exec, TweenInfo.new(0.3), {BackgroundTransparency = 0, TextTransparency = 0}):Play()

	return bindable.Event:Wait()
end

local isEnabled = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack)
if not isEnabled then
	if not createPrompt("Execute This Script?", "This game already has a custom inventory, not recommended to load script", "Execute") then
		getgenv().CustomInvLoaded = false
		return
	end
end

if not isfolder("Inventory Random Shit") then makefolder("Inventory Random Shit") end
if not isfile("Inventory Random Shit/drop.png") then writefile("Inventory Random Shit/drop.png", game:HttpGet("https://images.icon-icons.com/903/PNG/512/export_icon-icons.com_69529.png")) end
if not isfile("Inventory Random Shit/delete.png") then writefile("Inventory Random Shit/delete.png", game:HttpGet("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRICJeWi-qjdpCLFMR0dKB2Ik6zEWyw56EloQ&s")) end

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local camera = workspace.CurrentCamera

pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end)

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "CustomInventory"
MainGui.ResetOnSpawn = false
MainGui.IgnoreGuiInset = true
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
MainGui.DisplayOrder = 1000
MainGui.Parent = player:WaitForChild("PlayerGui")

local hotBar = Instance.new("Frame")
hotBar.Name = "hotBar"
hotBar.ZIndex = 0
hotBar.BorderSizePixel = 0
hotBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
hotBar.AnchorPoint = Vector2.new(0.5, 1)
hotBar.Size = UDim2.new(0.75, 0, 0.11, 0)
hotBar.Position = UDim2.new(0.5, 0, 0.98, 0)
hotBar.BackgroundTransparency = 1
hotBar.Parent = MainGui

local hotBarGrid = Instance.new("UIGridLayout")
hotBarGrid.Name = "Grid"
hotBarGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
hotBarGrid.VerticalAlignment = Enum.VerticalAlignment.Center
hotBarGrid.SortOrder = Enum.SortOrder.LayoutOrder
hotBarGrid.CellSize = UDim2.fromOffset(cellDim, cellDim)
hotBarGrid.CellPadding = UDim2.fromOffset(5, 0)
hotBarGrid.Parent = hotBar

local hotBarAspect = Instance.new("UIAspectRatioConstraint")
hotBarAspect.AspectRatio = 1
hotBarAspect.Parent = hotBarGrid

local toolButton = Instance.new("ImageButton")
toolButton.Name = "toolButton"
toolButton.BorderSizePixel = 0
toolButton.AutoButtonColor = false
toolButton.BackgroundTransparency = 0.15
toolButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
toolButton.Size = UDim2.new(1, 0, 1, 0)

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(1, 0)
UICornerBtn.Parent = toolButton

local toolNumber = Instance.new("TextLabel")
toolNumber.Name = "toolNumber"
toolNumber.ZIndex = 2
toolNumber.BorderSizePixel = 0
toolNumber.TextScaled = true
toolNumber.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
toolNumber.TextColor3 = Color3.fromRGB(255, 255, 255)
toolNumber.BackgroundTransparency = 1
toolNumber.Size = UDim2.new(0.3, 0, 0.25, 0)
toolNumber.Position = UDim2.new(0.05, 0, 0.05, 0)
toolNumber.Parent = toolButton

local toolName = Instance.new("TextLabel")
toolName.Name = "toolName"
toolName.ZIndex = 3
toolName.BorderSizePixel = 0
toolName.TextScaled = false
toolName.TextSize = txtNameSize
toolName.TextTruncate = Enum.TextTruncate.AtEnd
toolName.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
toolName.TextColor3 = Color3.fromRGB(255, 255, 255)
toolName.BackgroundTransparency = 1
toolName.AnchorPoint = Vector2.new(0.5, 1)
toolName.Size = UDim2.new(0.9, 0, 0.28, 0)
toolName.Position = UDim2.new(0.5, 0, 0.97, 0)
toolName.TextWrapped = false
toolName.Parent = toolButton

local toolAmount = Instance.new("TextLabel")
toolAmount.Name = "toolAmount"
toolAmount.ZIndex = 3
toolAmount.BorderSizePixel = 0
toolAmount.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
toolAmount.TextColor3 = Color3.fromRGB(255, 255, 255)
toolAmount.BackgroundTransparency = 1
toolAmount.AnchorPoint = Vector2.new(1, 1)
toolAmount.Size = UDim2.new(0.45, 0, 0.25, 0)
toolAmount.Position = UDim2.new(0.97, 0, 0.97, 0)
toolAmount.TextScaled = true
toolAmount.TextXAlignment = Enum.TextXAlignment.Right
toolAmount.Parent = toolButton

local tAmountConstraint = Instance.new("UITextSizeConstraint")
tAmountConstraint.MaxTextSize = 12
tAmountConstraint.MinTextSize = 5
tAmountConstraint.Parent = toolAmount

local toolIcon = Instance.new("ImageLabel")
toolIcon.Name = "toolIcon"
toolIcon.BorderSizePixel = 0
toolIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toolIcon.AnchorPoint = Vector2.new(0.5, 0.5)
toolIcon.Size = UDim2.new(0.6, 0, 0.6, 0)
toolIcon.Visible = false
toolIcon.BackgroundTransparency = 1
toolIcon.Position = UDim2.new(0.5, 0, 0.42, 0)
toolIcon.Parent = toolButton

local toolIconAspect = Instance.new("UIAspectRatioConstraint")
toolIconAspect.Parent = toolIcon

local BackpackFrame = Instance.new("Frame")
BackpackFrame.Name = "Backpack"
BackpackFrame.Size = UDim2.new(1, 0, 1, 0)
BackpackFrame.BackgroundTransparency = 1
BackpackFrame.Parent = MainGui

local invUI = Instance.new("Frame")
invUI.Name = "Inventory"
invUI.Size = UDim2.new(0, invW, 0, invH)
invUI.Position = UDim2.new(0.5, -(invW/2), 1, -280)
invUI.BackgroundTransparency = 0.3
invUI.BackgroundColor3 = Color3.fromRGB(25, 27, 29)
invUI.Visible = false
invUI.Parent = BackpackFrame

local invUICorner = Instance.new("UICorner")
invUICorner.CornerRadius = UDim.new(0, 8)
invUICorner.Parent = invUI

local invScroll = Instance.new("ScrollingFrame")
invScroll.Name = "ScrollingFrame"
invScroll.Size = UDim2.new(1, 9, 1, -40)
invScroll.Position = UDim2.new(0, 0, 0, 40)
invScroll.BackgroundTransparency = 1
invScroll.ScrollBarThickness = 8
invScroll.ScrollingDirection = Enum.ScrollingDirection.Y
invScroll.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
invScroll.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
invScroll.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
invScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
invScroll.Parent = invUI

local invGridFrame = Instance.new("Frame")
invGridFrame.Name = "UIGridFrame"
invGridFrame.Size = UDim2.new(1, -10, 1, 0)
invGridFrame.Position = UDim2.new(0, 5, 0, 0)
invGridFrame.BackgroundTransparency = 1
invGridFrame.Parent = invScroll

local invGrid = Instance.new("UIGridLayout")
invGrid.Name = "UIGridLayout"
invGrid.SortOrder = Enum.SortOrder.LayoutOrder
invGrid.CellSize = UDim2.fromOffset(cellDim, cellDim)
invGrid.CellPadding = UDim2.fromOffset(6, 6)
invGrid.Parent = invGridFrame

local invSearch = Instance.new("Frame")
invSearch.Name = "Search"
invSearch.Size = UDim2.new(0, 190, 0, 30)
invSearch.Position = UDim2.new(1, -195, 0, 5)
invSearch.BackgroundTransparency = 0.2
invSearch.BackgroundColor3 = Color3.fromRGB(25, 27, 29)
invSearch.Parent = invUI

local invSearchCorner = Instance.new("UICorner")
invSearchCorner.CornerRadius = UDim.new(0, 3)
invSearchCorner.Parent = invSearch

local invSearchStroke = Instance.new("UIStroke")
invSearchStroke.Transparency = 0.8
invSearchStroke.Color = Color3.fromRGB(255, 255, 255)
invSearchStroke.Parent = invSearch

local invSearchBox = Instance.new("TextBox")
invSearchBox.Name = "TextBox"
invSearchBox.Size = UDim2.new(0, 154, 0, 14)
invSearchBox.Position = UDim2.new(0, 8, 0.5, 0)
invSearchBox.AnchorPoint = Vector2.new(0, 0.5)
invSearchBox.BackgroundTransparency = 1
invSearchBox.Text = ""
invSearchBox.ClearTextOnFocus = false
invSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
invSearchBox.TextSize = 16
invSearchBox.TextXAlignment = Enum.TextXAlignment.Left
invSearchBox.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
invSearchBox.PlaceholderText = "Search"
invSearchBox.PlaceholderColor3 = Color3.fromRGB(127, 127, 127)
invSearchBox.Parent = invSearch

local deleteCell = Instance.new("ImageButton")
deleteCell.Name = "DeleteCell"
deleteCell.Size = UDim2.fromOffset(30, 30)
deleteCell.Position = UDim2.fromOffset(10, 5)
deleteCell.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
deleteCell.BackgroundTransparency = 0.15
deleteCell.Image = getcustomasset("Inventory Random Shit/delete.png")
deleteCell.Parent = invUI

local deleteCorner = Instance.new("UICorner")
deleteCorner.CornerRadius = UDim.new(0, 4)
deleteCorner.Parent = deleteCell

local dropCell = Instance.new("ImageButton")
dropCell.Name = "DropCell"
dropCell.Size = UDim2.fromOffset(30, 30)
dropCell.Position = UDim2.fromOffset(45, 5)
dropCell.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
dropCell.BackgroundTransparency = 0.15
dropCell.Image = getcustomasset("Inventory Random Shit/drop.png")
dropCell.Parent = invUI

local dropCorner = Instance.new("UICorner")
dropCorner.CornerRadius = UDim.new(0, 4)
dropCorner.Parent = dropCell

local TopbarHolders = Instance.new("Frame")
TopbarHolders.Name = "Holders"
TopbarHolders.Size = UDim2.new(1, 0, 1, -2)
TopbarHolders.BackgroundTransparency = 1
TopbarHolders.Parent = MainGui

local TopbarInv = Instance.new("Frame")
TopbarInv.Name = "TopbarInventory"
TopbarInv.Size = UDim2.new(0, 44, 0, 44)
TopbarInv.BackgroundTransparency = 1
TopbarInv.ZIndex = 20
TopbarInv.Parent = MainGui

local IconButton = Instance.new("Frame")
IconButton.Name = "IconButton"
IconButton.Size = UDim2.new(1, 0, 1, 0)
IconButton.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
IconButton.BackgroundTransparency = 0.08
IconButton.Parent = TopbarInv

local IconButtonCorner = Instance.new("UICorner")
IconButtonCorner.CornerRadius = UDim.new(1, 0)
IconButtonCorner.Parent = IconButton

local IconOverlay = Instance.new("Frame")
IconOverlay.Name = "IconOverlay"
IconOverlay.Size = UDim2.new(1, 0, 1, 0)
IconOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
IconOverlay.BackgroundTransparency = 0.85
IconOverlay.Visible = false
IconOverlay.Parent = IconButton

local IconOverlayCorner = Instance.new("UICorner")
IconOverlayCorner.CornerRadius = UDim.new(1, 0)
IconOverlayCorner.Parent = IconOverlay

local ClickRegion = Instance.new("TextButton")
ClickRegion.Name = "ClickRegion"
ClickRegion.Size = UDim2.new(1, 0, 1, 0)
ClickRegion.BackgroundTransparency = 1
ClickRegion.Text = ""
ClickRegion.Parent = IconButton

local ClickRegionCorner = Instance.new("UICorner")
ClickRegionCorner.CornerRadius = UDim.new(1, 0)
ClickRegionCorner.Parent = ClickRegion

local IconImage = Instance.new("ImageLabel")
IconImage.Name = "IconImage"
IconImage.Size = UDim2.new(0.65, 0, 0.65, 0)
IconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
IconImage.AnchorPoint = Vector2.new(0.5, 0.5)
IconImage.BackgroundTransparency = 1
IconImage.Image = "rbxasset://textures/ui/TopBar/inventoryOff.png"
IconImage.Parent = IconButton

local inventoryHandler = {OBJECTS = {}, SETTINGS = {}, slotAmount = slotCount, SelectedObject = nil, lastToolInput = 0}
inventoryHandler.OBJECTS.HotBar = {}
inventoryHandler.OBJECTS.Inventory = {}

local SETTINGS = inventoryHandler.SETTINGS
SETTINGS.DEFAULT_COLOR = Color3.fromRGB(25, 25, 25)
SETTINGS.EQUIPPED_COLOR = Color3.fromRGB(80, 80, 80)
SETTINGS.DISABLED_COLOR = Color3.fromRGB(128, 64, 65)
SETTINGS.SELECTED_COLOR = Color3.fromRGB(30, 80, 180)
SETTINGS.DEFAULT_IMAGEID = ""
SETTINGS.EQUIPPED_IMAGEID = ""
SETTINGS.DISABLED_IMAGEID = ""
SETTINGS.INVENTORY_KEYBIND = Enum.KeyCode.Backquote
SETTINGS.SHOW_EMPTY_TOOL_FRAMES_IN_HOTBAR = false
SETTINGS.SCROLL_HOTBAR_WITH_WHEEL = true
SETTINGS.ALWAYS_SHOW_TOOL_NAME = false
SETTINGS.CELL_SIZE = cellDim

local EnumKeys = {
	Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three,
	Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.Six,
	Enum.KeyCode.Seven, Enum.KeyCode.Eight, Enum.KeyCode.Nine, Enum.KeyCode.Zero
}

local toolObjectMetatable = {}
toolObjectMetatable.__index = toolObjectMetatable

local newToolsTracker = {}
local layoutMemory = {}

local function applySelectionHighlight(frame)
	if not frame or not frame.Parent then return end
	local stroke = frame:FindFirstChildWhichIsA("UIStroke")
	if not stroke then
		stroke = Instance.new("UIStroke")
		stroke.Name = "SelectionStroke"
		stroke.Thickness = 2.5
		stroke.Color = Color3.fromRGB(255, 128, 0)
		stroke.Transparency = 0
		stroke.Parent = frame
	else
		stroke.Color = Color3.fromRGB(255, 128, 0)
		stroke.Transparency = 0
		stroke.Thickness = 2.5
	end
end

local function removeSelectionHighlight(frame)
	if not frame or not frame.Parent then return end
	local stroke = frame:FindFirstChild("SelectionStroke")
	if stroke then
		stroke:Destroy()
	end
end

local function updateInvScrollSize()
	local gridLayout = invGridFrame:FindFirstChildOfClass("UIGridLayout")
	if not gridLayout then return end
	local contentSize = gridLayout.AbsoluteContentSize
	local scrollFrameAbsSize = invScroll.AbsoluteSize
	local contentH = contentSize.Y
	invGridFrame.Size = UDim2.new(1, -10, 0, contentH)
	if contentH <= scrollFrameAbsSize.Y then
		invScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		invScroll.ScrollBarThickness = 0
	else
		invScroll.CanvasSize = UDim2.new(0, 0, 0, contentH)
		invScroll.ScrollBarThickness = 8
	end
end

local function updateTopbarInvPosition()
	local visibleSlots = 0
	if invUI.Visible then
		visibleSlots = inventoryHandler.slotAmount
	else
		for index = 1, inventoryHandler.slotAmount do
			if inventoryHandler.OBJECTS.HotBar[index] or inventoryHandler.SETTINGS.SHOW_EMPTY_TOOL_FRAMES_IN_HOTBAR then
				visibleSlots = visibleSlots + 1
			end
		end
	end
	if visibleSlots == 0 then
		TopbarInv.AnchorPoint = Vector2.new(0.5, 1)
		TopbarInv.Position = UDim2.new(0.5, 0, 0.98, -7)
	else
		local cellSize = inventoryHandler.SETTINGS.CELL_SIZE
		local padding = 5
		local totalWidth = (visibleSlots * cellSize) + ((visibleSlots - 1) * padding)
		TopbarInv.AnchorPoint = Vector2.new(0, 1)
		TopbarInv.Position = UDim2.new(0.5, (totalWidth / 2) + 10, 0.98, -7)
	end
end

local function getEquippedObj()
	for _, obj in pairs(inventoryHandler.OBJECTS.HotBar) do
		if obj:isEquipped() then return obj end
	end
	for _, obj in pairs(inventoryHandler.OBJECTS.Inventory) do
		if obj:isEquipped() then return obj end
	end
	return nil
end

function inventoryHandler:SetSelected(object, isSelected)
	if not object or not object.Frame then return end
	local frame = object.Frame
	if isSelected then
		inventoryHandler.SelectedObject = object
		applySelectionHighlight(frame)
		object:updateIcon()
		if not object.ContextMenu then
			local ctx = Instance.new("Frame")
			ctx.Name = "ContextMenu"
			ctx.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			ctx.BackgroundTransparency = 0
			ctx.AutomaticSize = Enum.AutomaticSize.XY
			ctx.Parent = MainGui

			local function updateCtxPos()
				if not ctx or not ctx.Parent or not frame or not frame.Parent then return end
				if object.Parent == "HotBar" then
					ctx.AnchorPoint = Vector2.new(0.5, 1)
					ctx.Position = UDim2.new(0, frame.AbsolutePosition.X + (frame.AbsoluteSize.X / 2), 0, frame.AbsolutePosition.Y + 50)
				else
					ctx.AnchorPoint = Vector2.new(0.5, 0)
					ctx.Position = UDim2.new(0, frame.AbsolutePosition.X + (frame.AbsoluteSize.X / 2), 0, frame.AbsolutePosition.Y + frame.AbsoluteSize.Y + 65)
				end
			end
			
			updateCtxPos()
			local posConn
			posConn = frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateCtxPos)
			ctx.Destroying:Connect(function()
				if posConn then posConn:Disconnect() end
			end)

			ctx.ZIndex = 999999999

			local layout = Instance.new("UIListLayout")
			layout.SortOrder = Enum.SortOrder.LayoutOrder
			layout.Parent = ctx

			local padding = Instance.new("UIPadding")
			padding.PaddingLeft = UDim.new(0, 5)
			padding.PaddingRight = UDim.new(0, 5)
			padding.PaddingTop = UDim.new(0, 5)
			padding.PaddingBottom = UDim.new(0, 5)
			padding.Parent = ctx

			local corner = Instance.new("UICorner", ctx)
			corner.CornerRadius = UDim.new(0, 4)

			local function createLabel(text, layoutOrder, isCopyable, rawText)
				local btn = Instance.new("TextButton")
				btn.BackgroundTransparency = 1
				btn.AutomaticSize = Enum.AutomaticSize.XY
				btn.Text = text
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
				btn.ZIndex = 999999999
				btn.TextSize = 12
				btn.Font = Enum.Font.GothamMedium
				btn.LayoutOrder = layoutOrder
				btn.TextXAlignment = Enum.TextXAlignment.Left
				btn.Parent = ctx

				if isCopyable then
					btn.MouseButton1Click:Connect(function()
						if setclipboard then pcall(setclipboard, rawText) end
						TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(0, 255, 0)}):Play()
						task.wait(0.2)
						TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
					end)
				end
				return btn
			end

			local nameLabel = createLabel("Name: " .. object.Name, 1, true, object.Name)

			local tipLabel = nil
			local tipText = object.Tool.ToolTip
			if tipText and tipText ~= "" then
				tipLabel = createLabel("Tip: " .. tipText, 2, true, tipText)
			end

			local toggleBtn = Instance.new("TextButton")
			toggleBtn.BackgroundTransparency = 1
			toggleBtn.AutomaticSize = Enum.AutomaticSize.XY
			local enabledStr = object.Tool.Enabled and "On" or "Off"
			toggleBtn.Text = "Enabled: " .. enabledStr
			toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			toggleBtn.ZIndex = 999999999
			toggleBtn.TextSize = 12
			toggleBtn.Font = Enum.Font.GothamMedium
			toggleBtn.LayoutOrder = 3
			toggleBtn.TextXAlignment = Enum.TextXAlignment.Left
			toggleBtn.Parent = ctx

			toggleBtn.MouseButton1Click:Connect(function()
				object.Tool.Enabled = not object.Tool.Enabled
				local newState = object.Tool.Enabled and "On" or "Off"
				toggleBtn.Text = "Enabled: " .. newState
			end)

			local function buildPath(tool)
				local result = ""
				pcall(function()
					local parent = tool.Parent
					local lp = Players.LocalPlayer
					if parent == lp.Backpack then
						result = 'game:GetService("Players").LocalPlayer.Backpack.' .. tool.Name
					elseif parent == lp.Character then
						result = 'game:GetService("Players").LocalPlayer.Character.' .. tool.Name
					else
						local raw = tool:GetFullName()
						local parts = raw:split(".")
						if #parts >= 2 then
							local svcName = parts[2]
							local rest = {}
							for i = 3, #parts do rest[#rest+1] = parts[i] end
							local svcCall = 'game:GetService("' .. svcName .. '")'
							result = #rest > 0 and (svcCall .. "." .. table.concat(rest, ".")) or svcCall
						else
							result = raw
						end
					end
				end)
				return result
			end

			local fullPath = buildPath(object.Tool)
			local copyPathBtn = createLabel("Copy Path", 4, true, fullPath)

			object.ContextMenu = ctx

			local ctxConns = {}
			ctxConns[#ctxConns+1] = object.Tool:GetPropertyChangedSignal("Name"):Connect(function()
				nameLabel.Text = "Name: " .. object.Tool.Name
				local newPath = buildPath(object.Tool)
				copyPathBtn.MouseButton1Click:Connect(function()
					if setclipboard then pcall(setclipboard, newPath) end
					TweenService:Create(copyPathBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(0, 255, 0)}):Play()
					task.wait(0.2)
					TweenService:Create(copyPathBtn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				end)
			end)
			ctxConns[#ctxConns+1] = object.Tool:GetPropertyChangedSignal("Enabled"):Connect(function()
				toggleBtn.Text = "Enabled: " .. (object.Tool.Enabled and "On" or "Off")
			end)
			ctxConns[#ctxConns+1] = object.Tool:GetPropertyChangedSignal("ToolTip"):Connect(function()
				local newTip = object.Tool.ToolTip
				if tipLabel then
					if newTip and newTip ~= "" then
						tipLabel.Text = "Tip: " .. newTip
						tipLabel.Visible = true
					else
						tipLabel.Visible = false
					end
				else
					if newTip and newTip ~= "" then
						tipLabel = createLabel("Tip: " .. newTip, 2, true, newTip)
					end
				end
			end)
			ctx.Destroying:Connect(function()
				for _, c in ipairs(ctxConns) do
					if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
				end
			end)

			task.spawn(function()
				task.wait()
				if not ctx or not ctx.Parent then return end
				local absPos = ctx.AbsolutePosition
				local absSize = ctx.AbsoluteSize
				local vp = workspace.CurrentCamera.ViewportSize
				local shiftX = 0
				if absPos.X < 0 then
					shiftX = -absPos.X + 5
				elseif absPos.X + absSize.X > vp.X then
					shiftX = vp.X - (absPos.X + absSize.X) - 5
				end
				if shiftX ~= 0 then
					ctx.Position = ctx.Position + UDim2.new(0, shiftX, 0, 0)
				end
			end)
		end
	else
		if inventoryHandler.SelectedObject == object then
			inventoryHandler.SelectedObject = nil
		end
		removeSelectionHighlight(frame)
		if object.updateEnabled then object.updateEnabled() end
		if object.updateEquipped then object.updateEquipped() end
		object:updateIcon()
		if object.ContextMenu then
			object.ContextMenu:Destroy()
			object.ContextMenu = nil
		end
	end
end

function toolObjectMetatable:isEquipped()
	local character = player.Character
	if character then
		return self.Tool.Parent == player.Character
	end
	return false
end

function toolObjectMetatable:DisconnectAll()
	if self.CONNECTIONS then
		for _, v in pairs(self.CONNECTIONS) do
			if typeof(v) == "RBXScriptConnection" then
				v:Disconnect()
			end
		end
	end
	self.didRemoval = true
	if self.ContextMenu then
		self.ContextMenu:Destroy()
		self.ContextMenu = nil
	end
	if self.Parent == "HotBar" and self.Position then
		ContextActionService:UnbindAction(self.Position .. "hotBar")
		inventoryHandler.OBJECTS.HotBar[self.Position] = nil
	elseif self.Parent == "Inventory" then
		inventoryHandler.OBJECTS.Inventory[self.Tool] = nil
	end
	if self.Frame and self.Frame.Parent then
		self.Frame:Destroy()
	end
end

function toolObjectMetatable:updateIcon()
	local tool = self.Tool
	local frame = self.Frame
	if not frame or not frame.Parent then return end
	local textureId = tool.TextureId
	if textureId == "" or textureId == nil then
		if frame:FindFirstChild("toolIcon") then
			frame.toolIcon.Visible = false
			frame.toolIcon.Image = ""
		end
		if frame:FindFirstChild("toolName") then
			frame.toolName.Visible = true
			frame.toolName.Text = tool.Name
			frame.toolName.AnchorPoint = Vector2.new(0.5, 0.5)
			frame.toolName.Position = UDim2.new(0.5, 0, 0.5, 0)
			frame.toolName.Size = UDim2.new(0.88, 0, 0.6, 0)
			frame.toolName.TextWrapped = false
			frame.toolName.TextTruncate = Enum.TextTruncate.AtEnd
		end
	else
		if frame:FindFirstChild("toolIcon") then
			frame.toolIcon.Visible = true
			frame.toolIcon.Image = textureId
			frame.toolIcon.AnchorPoint = Vector2.new(0.5, 0.5)
			frame.toolIcon.Position = UDim2.new(0.5, 0, 0.42, 0)
			frame.toolIcon.Size = UDim2.new(0.58, 0, 0.58, 0)
		end
		if frame:FindFirstChild("toolName") then
			frame.toolName.Visible = true
			frame.toolName.Text = tool.Name
			frame.toolName.AnchorPoint = Vector2.new(0.5, 1)
			frame.toolName.Position = UDim2.new(0.5, 0, 0.97, 0)
			frame.toolName.Size = UDim2.new(0.9, 0, 0.26, 0)
			frame.toolName.TextWrapped = false
			frame.toolName.TextTruncate = Enum.TextTruncate.AtEnd
		end
	end
	if frame:FindFirstChild("toolNumber") then
		frame.toolNumber.Position = UDim2.new(0.05, 0, 0.05, 0)
	end
	if frame:FindFirstChild("toolAmount") then
		frame.toolAmount.Position = UDim2.new(0.97, 0, 0.97, 0)
	end
end

function toolObjectMetatable:getParentInstance()
	return self.Parent == "Inventory" and invGridFrame or hotBar
end

function inventoryHandler:removeCurrentDescription()
	local descriptionFrame = MainGui:FindFirstChild("descriptionFrame")
	if descriptionFrame then
		descriptionFrame:Destroy()
	end
end

function inventoryHandler:getObjectFromTool(tool)
	if not tool then return nil end
	for _, toolObject in pairs(self.OBJECTS.HotBar) do
		if toolObject.Tool == tool then return toolObject end
	end
	return self.OBJECTS.Inventory[tool]
end

function inventoryHandler:getToolPosition(tool)
	local toolObject = self:getObjectFromTool(tool)
	return toolObject and toolObject.Position
end

function inventoryHandler:searchTool()
	local searchText = invSearchBox.Text:lower()
	local sel = inventoryHandler.SelectedObject
	if sel and sel.ContextMenu then
		if searchText == "" then
			sel.ContextMenu.Visible = true
		else
			local matches = string.find(sel.Name:lower(), searchText) ~= nil
			sel.ContextMenu.Visible = matches
		end
	end
	for _, toolObject in pairs(self.OBJECTS.Inventory) do
		if toolObject and toolObject.Frame and toolObject.Frame.Parent then
			if searchText == "" then
				toolObject.Frame.Visible = true
			else
				toolObject.Frame.Visible = string.find(toolObject.Name:lower(), searchText) ~= nil
			end
		end
	end
	for index = 1, self.slotAmount do
		local toolObject = self.OBJECTS.HotBar[index]
		if toolObject then
			if toolObject.Frame and toolObject.Frame.Parent then
				if searchText == "" then
					toolObject.Frame.Visible = true
				else
					toolObject.Frame.Visible = string.find(toolObject.Name:lower(), searchText) ~= nil
				end
			end
		else
			local emptyFrame = hotBar:FindFirstChild(tostring(index))
			if emptyFrame then
				if searchText == "" then
					if invUI.Visible or self.SETTINGS.SHOW_EMPTY_TOOL_FRAMES_IN_HOTBAR then
						emptyFrame.Visible = true
					else
						emptyFrame.Visible = false
					end
				else
					emptyFrame.Visible = false
				end
			end
		end
	end
	task.defer(updateInvScrollSize)
end

function inventoryHandler:lockSlots(unequipCurrentTool)
	self.slotsLocked = true
	if unequipCurrentTool then
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:UnequipTools()
		end
	end
end

function inventoryHandler:unlockSlots() self.slotsLocked = false end
function inventoryHandler:lockSlotsPosition() self.slotsPositionLocked = true end
function inventoryHandler:unlockSlotsPosition() self.slotsPositionLocked = false end

local showSlotsSignal = Instance.new("BindableEvent")
local knownBackpackTools = {}

local function buildKnownSet()
	knownBackpackTools = {}
	local bp = player:FindFirstChild("Backpack")
	if bp then
		for _, child in ipairs(bp:GetChildren()) do
			if child:IsA("Tool") then
				knownBackpackTools[child] = true
			end
		end
	end
	local char = player.Character
	if char then
		for _, child in ipairs(char:GetChildren()) do
			if child:IsA("Tool") then
				knownBackpackTools[child] = true
			end
		end
	end
end

function inventoryHandler:newTool(tool)
	if not tool:IsA("Tool") then return end
	local obj = inventoryHandler:getObjectFromTool(tool)
	if obj then return end
	
	local mem = layoutMemory[tool.Name]
	if mem then
		if mem.Parent == "HotBar" and not self.OBJECTS.HotBar[mem.Pos] then
			inventoryHandler:addTool(tool, "HotBar", mem.Pos)
			return
		elseif mem.Parent == "Inventory" then
			inventoryHandler:addTool(tool, "Inventory", mem.Pos)
			return
		end
	end

	local savedPos = tool:GetAttribute("position")
	if savedPos and savedPos >= 1 and savedPos <= self.slotAmount and not self.OBJECTS.HotBar[savedPos] then
		inventoryHandler:addTool(tool, "HotBar", savedPos)
		return
	end
	for index = 1, self.slotAmount do
		if self.OBJECTS.HotBar[index] == nil then
			inventoryHandler:addTool(tool, "HotBar", index)
			return
		end
	end
	inventoryHandler:addTool(tool, "Inventory")
end

function inventoryHandler:addTool(tool, parent, position)
	tool:SetAttribute("position", nil)
	if parent == "HotBar" and position then
		local existingEmpty = hotBar:FindFirstChild(tostring(position))
		if existingEmpty then existingEmpty:Destroy() end
		local existingObj = self.OBJECTS.HotBar[position]
		if existingObj then existingObj:DisconnectAll() end
	elseif parent == "Inventory" then
		if not position then
			local maxPos = 0
			for _, obj in pairs(self.OBJECTS.Inventory) do
				if obj.Position and obj.Position > maxPos then
					maxPos = obj.Position
				end
			end
			position = maxPos + 1
		end
	end
	local frame = toolButton:Clone()
	local amount = tool:GetAttribute("amount") or 1
	if amount > 1 then frame.toolAmount.Text = "x" .. amount else frame.toolAmount.Text = "" end
	frame.Parent = parent == "Inventory" and invGridFrame or hotBar
	frame.Name = parent == "Inventory" and tool.Name or tostring(position)
	frame.toolNumber.Text = parent == "Inventory" and "" or tostring(position)
	frame.LayoutOrder = position
	local object = {}
	setmetatable(object, toolObjectMetatable)
	object.Tool = tool
	object.Frame = frame
	object.Parent = parent
	object.Position = position
	object.Name = tool.Name
	if parent == "HotBar" then
		self.OBJECTS.HotBar[position] = object
	else
		self.OBJECTS.Inventory[tool] = object
	end
	
	layoutMemory[tool.Name] = {Parent = parent, Pos = position}
	
	local function manageTool(_, inputState, inputObject)
		if inputObject and inputObject.UserInputType ~= Enum.UserInputType.Keyboard and inputObject.UserInputType ~= Enum.UserInputType.Touch and inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 or not tool.Parent or inputState == Enum.UserInputState.End or self.slotsLocked then return end
		if object:isEquipped() then
			tool:SetAttribute("RealUnequip", tick())
			humanoid:UnequipTools()
			if inventoryHandler.SelectedObject ~= object then
				frame.BackgroundColor3 = SETTINGS.DEFAULT_COLOR
				frame.BackgroundTransparency = 0.15
				frame.Image = SETTINGS.DEFAULT_IMAGEID
			end
			inventoryHandler.currentlyEquipped = nil
		elseif tool.Enabled then
			if inventoryHandler.currentlyEquipped and inventoryHandler.currentlyEquipped.Parent then
				local eqToolObj
				for _, o in pairs(inventoryHandler.OBJECTS.HotBar) do
					if o.Frame == inventoryHandler.currentlyEquipped then eqToolObj = o.Tool break end
				end
				if not eqToolObj then
					for _, o in pairs(inventoryHandler.OBJECTS.Inventory) do
						if o.Frame == inventoryHandler.currentlyEquipped then eqToolObj = o.Tool break end
					end
				end
				if eqToolObj then eqToolObj:SetAttribute("RealUnequip", tick()) end
				
				if inventoryHandler.SelectedObject == nil or inventoryHandler.SelectedObject.Frame ~= inventoryHandler.currentlyEquipped then
					inventoryHandler.currentlyEquipped.BackgroundColor3 = SETTINGS.DEFAULT_COLOR
					inventoryHandler.currentlyEquipped.BackgroundTransparency = 0.15
					inventoryHandler.currentlyEquipped.Image = SETTINGS.DEFAULT_IMAGEID
				end
			end
			tool:SetAttribute("RealUnequip", tick())
			humanoid:EquipTool(tool)
			inventoryHandler.currentlyEquipped = frame
			frame.BackgroundColor3 = SETTINGS.EQUIPPED_COLOR
			frame.BackgroundTransparency = 0.05
			frame.Image = SETTINGS.EQUIPPED_IMAGEID
		end
	end
	local function updateEquipped()
		if inventoryHandler.SelectedObject == object then return end
		if object:isEquipped() and tool.Enabled then
			if inventoryHandler.currentlyEquipped and inventoryHandler.currentlyEquipped.Parent then
				if inventoryHandler.SelectedObject == nil or inventoryHandler.SelectedObject.Frame ~= inventoryHandler.currentlyEquipped then
					inventoryHandler.currentlyEquipped.BackgroundColor3 = SETTINGS.DEFAULT_COLOR
					inventoryHandler.currentlyEquipped.BackgroundTransparency = 0.15
					inventoryHandler.currentlyEquipped.Image = SETTINGS.DEFAULT_IMAGEID
				end
			end
			inventoryHandler.currentlyEquipped = frame
			frame.BackgroundColor3 = SETTINGS.EQUIPPED_COLOR
			frame.BackgroundTransparency = 0.05
			frame.Image = SETTINGS.EQUIPPED_IMAGEID
		else
			if inventoryHandler.currentlyEquipped == frame then
				inventoryHandler.currentlyEquipped = nil
			end
			if not tool.Enabled then return end
			frame.BackgroundColor3 = SETTINGS.DEFAULT_COLOR
			frame.BackgroundTransparency = 0.15
			frame.Image = SETTINGS.DEFAULT_IMAGEID
		end
	end
	local function updateEnabled()
		if inventoryHandler.SelectedObject == object then return end
		if tool.Enabled then
			if object:isEquipped() then
				frame.BackgroundColor3 = SETTINGS.EQUIPPED_COLOR
				frame.BackgroundTransparency = 0.05
				frame.Image = SETTINGS.EQUIPPED_IMAGEID
			else
				frame.BackgroundColor3 = SETTINGS.DEFAULT_COLOR
				frame.BackgroundTransparency = 0.15
				frame.Image = SETTINGS.DEFAULT_IMAGEID
			end
			frame.ImageTransparency = 0
			if frame:FindFirstChild("toolIcon") then frame.toolIcon.ImageTransparency = 0 end
			if frame:FindFirstChild("toolName") then frame.toolName.TextTransparency = 0 end
			if frame:FindFirstChild("toolNumber") then frame.toolNumber.TextTransparency = 0 end
			if frame:FindFirstChild("toolAmount") then frame.toolAmount.TextTransparency = 0 end
		else
			frame.Image = SETTINGS.DISABLED_IMAGEID
			frame.BackgroundColor3 = SETTINGS.DISABLED_COLOR
			frame.BackgroundTransparency = 0.05
			frame.ImageTransparency = 0.35
			if frame:FindFirstChild("toolIcon") then frame.toolIcon.ImageTransparency = 0.5 end
			if frame:FindFirstChild("toolName") then frame.toolName.TextTransparency = 0.6 end
			if frame:FindFirstChild("toolNumber") then frame.toolNumber.TextTransparency = 0.6 end
			if frame:FindFirstChild("toolAmount") then frame.toolAmount.TextTransparency = 0.6 end
		end
	end
	object.updateEnabled = updateEnabled
	object.updateEquipped = updateEquipped
	updateEnabled()
	updateEquipped()
	object:updateIcon()
	object.CONNECTIONS = {}
	object.CONNECTIONS.EnabledConn = tool:GetPropertyChangedSignal("Enabled"):Connect(updateEnabled)
	object.CONNECTIONS.ToolRemoved = tool.AncestryChanged:Connect(function(_, newParent)
		if player and (newParent == nil or (newParent ~= player.Backpack and newParent ~= player.Character)) then
			if inventoryHandler.SelectedObject == object then
				inventoryHandler:SetSelected(object, false)
			end
			object:DisconnectAll()
			if parent == "HotBar" and position then
				showSlotsSignal:Fire()
			end
		end
		updateEquipped()
	end)
	object.CONNECTIONS.NameChanged = tool:GetPropertyChangedSignal("Name"):Connect(function()
		if tool.TextureId == "" or tool.TextureId == nil then
			if frame:FindFirstChild("toolName") then frame.toolName.Text = tool.Name end
		end
		object.Name = tool.Name
		if parent == "Inventory" then frame.Name = tool.Name end
	end)
	object.CONNECTIONS.TextureIdChanged = tool:GetPropertyChangedSignal("TextureId"):Connect(function() object:updateIcon() end)
	object.CONNECTIONS.AmountChanged = tool:GetAttributeChangedSignal("amount"):Connect(function()
		amount = tool:GetAttribute("amount") or 1
		if frame:FindFirstChild("toolAmount") then
			if amount > 1 then frame.toolAmount.Text = "x" .. amount else frame.toolAmount.Text = "" end
		end
	end)
	object.CONNECTIONS.GrabConn = frame.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		if self.slotsPositionLocked then return end
		inventoryHandler.lastToolInput = tick()
		local isHeld = false
		local holdStart = tick()
		local inputEnded = false
		local endConn
		endConn = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				inputEnded = true
			end
		end)
		while not inputEnded and tick() - holdStart < 0.25 do
			task.wait(0.01)
		end
		if endConn then endConn:Disconnect() end
		isHeld = not inputEnded
		if not isHeld then
			if inventoryHandler.SelectedObject then
				if inventoryHandler.SelectedObject == object then
					inventoryHandler:SetSelected(object, false)
				else
					local selObj = inventoryHandler.SelectedObject
					local myTool = object.Tool
					local myOldParent = object.Parent
					local myOldPos = object.Position
					local theirTool = selObj.Tool
					local theirOldParent = selObj.Parent
					local theirOldPos = selObj.Position
					inventoryHandler:SetSelected(selObj, false)
					object:DisconnectAll()
					selObj:DisconnectAll()
					if myOldParent == "HotBar" then
						inventoryHandler:addTool(theirTool, "HotBar", myOldPos)
					else
						inventoryHandler:addTool(theirTool, "Inventory", myOldPos)
					end
					if theirOldParent == "HotBar" then
						inventoryHandler:addTool(myTool, "HotBar", theirOldPos)
					else
						inventoryHandler:addTool(myTool, "Inventory", theirOldPos)
					end
					if object.Tool then layoutMemory[object.Tool.Name] = {Parent = theirOldParent, Pos = theirOldPos} end
					if selObj.Tool then layoutMemory[selObj.Tool.Name] = {Parent = myOldParent, Pos = myOldPos} end
					inventoryHandler:searchTool()
					if (myOldParent == "HotBar" or theirOldParent == "HotBar") then
						showSlotsSignal:Fire()
					end
					task.defer(updateInvScrollSize)
				end
			else
				manageTool(nil, Enum.UserInputState.Begin, input)
			end
		else
			if inventoryHandler.SelectedObject == object then
				inventoryHandler:SetSelected(object, false)
			else
				if inventoryHandler.SelectedObject then
					inventoryHandler:SetSelected(inventoryHandler.SelectedObject, false)
				end
				inventoryHandler:SetSelected(object, true)
			end
		end
	end)
	if parent == "HotBar" and position and EnumKeys[position] then
		ContextActionService:BindAction(position .. "hotBar", manageTool, false, EnumKeys[position])
	end
	task.defer(updateInvScrollSize)
end

local function updateGridCellSize()
	local cellSize = inventoryHandler.SETTINGS.CELL_SIZE
	invGrid.CellSize = UDim2.fromOffset(cellSize, cellSize)
	invGrid.CellPadding = UDim2.fromOffset(6, 6)
	if hotBarGrid then
		hotBarGrid.CellSize = UDim2.fromOffset(cellSize, cellSize)
		hotBarGrid.CellPadding = UDim2.fromOffset(5, 0)
	end
end

local function showSlots()
	updateGridCellSize()
	local searchText = invSearchBox.Text:lower()
	for index = 1, inventoryHandler.slotAmount do
		local toolObject = inventoryHandler.OBJECTS.HotBar[index]
		local existingFrame = hotBar:FindFirstChild(tostring(index))
		if not toolObject then
			if invUI.Visible or inventoryHandler.SETTINGS.SHOW_EMPTY_TOOL_FRAMES_IN_HOTBAR then
				if not existingFrame then
					local frame = toolButton:Clone()
					frame.toolName.Text = ""
					frame.toolName.AnchorPoint = Vector2.new(0.5, 0.5)
					frame.toolName.Position = UDim2.new(0.5, 0, 0.5, 0)
					frame.toolName.Size = UDim2.new(0.88, 0, 0.6, 0)
					frame.toolAmount.Text = ""
					frame.toolNumber.Text = tostring(index)
					frame.Name = tostring(index)
					frame.LayoutOrder = index
					frame.Parent = hotBar
					frame.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							if inventoryHandler.SelectedObject then
								local selObj = inventoryHandler.SelectedObject
								local toolToMove = selObj.Tool
								local oldParent = selObj.Parent
								inventoryHandler:SetSelected(selObj, false)
								selObj:DisconnectAll()
								inventoryHandler:addTool(toolToMove, "HotBar", index)
								if oldParent == "HotBar" then
									showSlots()
								end
								inventoryHandler:searchTool()
								task.defer(updateInvScrollSize)
							end
						end
					end)
				end
				if existingFrame or hotBar:FindFirstChild(tostring(index)) then
					local f = hotBar:FindFirstChild(tostring(index))
					if f then
						if searchText == "" then
							f.Visible = true
						else
							f.Visible = false
						end
					end
				end
			else
				if existingFrame then
					existingFrame:Destroy()
				end
			end
		else
			if existingFrame and existingFrame ~= toolObject.Frame then
				existingFrame:Destroy()
			end
			if toolObject.Frame and toolObject.Frame.Parent then
				if searchText == "" then
					toolObject.Frame.Visible = true
				else
					toolObject.Frame.Visible = string.find(toolObject.Name:lower(), searchText) ~= nil
				end
			end
		end
	end
	updateTopbarInvPosition()
	task.defer(updateInvScrollSize)
end

showSlotsSignal.Event:Connect(showSlots)

invGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateInvScrollSize)

invScroll.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if tick() - inventoryHandler.lastToolInput < 0.1 then return end
		if inventoryHandler.SelectedObject and inventoryHandler.SelectedObject.Parent == "HotBar" then
			local selObj = inventoryHandler.SelectedObject
			local toolToMove = selObj.Tool
			inventoryHandler:SetSelected(selObj, false)
			selObj:DisconnectAll()
			inventoryHandler:addTool(toolToMove, "Inventory")
			showSlots()
			inventoryHandler:searchTool()
			task.defer(updateInvScrollSize)
		end
	end
end)

local isToggled = false

local function updateButtonAppearance()
	if isToggled then
		IconImage.Image = "rbxasset://textures/ui/TopBar/inventoryOn.png"
		IconButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
		IconOverlay.Visible = true
		invUI.Visible = true
		local sel = inventoryHandler.SelectedObject
		if sel and sel.Parent == "Inventory" and sel.ContextMenu then
			sel.ContextMenu.Visible = true
		end
	else
		IconImage.Image = "rbxasset://textures/ui/TopBar/inventoryOff.png"
		IconButton.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
		IconOverlay.Visible = false
		invUI.Visible = false
		local sel = inventoryHandler.SelectedObject
		if sel and sel.Parent == "Inventory" and sel.ContextMenu then
			sel.ContextMenu.Visible = false
		end
	end
	updateTopbarInvPosition()
	task.defer(updateInvScrollSize)
end

local function manageInventory(_, inputState)
	if not inputState or inputState == Enum.UserInputState.Begin then
		isToggled = not isToggled
		updateButtonAppearance()
		inventoryHandler:removeCurrentDescription()
		showSlots()
		inventoryHandler:searchTool()
	end
end

local function searchTool()
	inventoryHandler:searchTool()
end

local pendingNewTools = {}

local function newTool(tool)
	if not tool:IsA("Tool") then return end
	if not knownBackpackTools[tool] then
		knownBackpackTools[tool] = true
		pendingNewTools[tool] = tick()
	end
	inventoryHandler:newTool(tool)
	showSlots()
end

local function reloadInventory(character)
	inventoryHandler.currentlyEquipped = nil
	for _, obj in pairs(inventoryHandler.OBJECTS.HotBar) do
		if obj then obj:DisconnectAll() end
	end
	for _, obj in pairs(inventoryHandler.OBJECTS.Inventory) do
		if obj then obj:DisconnectAll() end
	end
	inventoryHandler.OBJECTS.HotBar = {}
	inventoryHandler.OBJECTS.Inventory = {}
	hotBar:ClearAllChildren()
	hotBarGrid:Clone().Parent = hotBar
	invGridFrame:ClearAllChildren()
	invGrid:Clone().Parent = invGridFrame
	backpack = player:WaitForChild("Backpack")
	knownBackpackTools = {}
	pendingNewTools = {}
	for _, tool in pairs(character:GetChildren()) do
		if tool:IsA("Tool") then
			knownBackpackTools[tool] = true
			inventoryHandler:newTool(tool)
		end
	end
	for _, tool in pairs(backpack:GetChildren()) do
		if tool:IsA("Tool") then
			knownBackpackTools[tool] = true
			inventoryHandler:newTool(tool)
		end
	end
	backpack.ChildAdded:Connect(newTool)
	character.ChildAdded:Connect(newTool)
	
	character.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") and child.Parent == player:FindFirstChild("Backpack") then
			local lastRU = child:GetAttribute("RealUnequip") or 0
			if tick() - lastRU > 0.5 then
				local hum = character:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 then
					hum:EquipTool(child)
				end
			end
		end
	end)
	
	showSlots()
	task.defer(updateInvScrollSize)
end

local function updateHudPosition()
	showSlots()
end

reloadInventory(player.Character or player.CharacterAdded:Wait())
camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateHudPosition)
player.CharacterAdded:Connect(reloadInventory)
invSearchBox:GetPropertyChangedSignal("Text"):Connect(searchTool)

if inventoryHandler.SETTINGS.INVENTORY_KEYBIND then
	ContextActionService:BindAction("manageInventory", manageInventory, false, inventoryHandler.SETTINGS.INVENTORY_KEYBIND)
end

ClickRegion.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isToggled = not isToggled
		updateButtonAppearance()
		inventoryHandler:removeCurrentDescription()
		showSlots()
		inventoryHandler:searchTool()
	end
end)

deleteCell.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local targetObj = inventoryHandler.SelectedObject or getEquippedObj()
		if targetObj then
			local toolToDestroy = targetObj.Tool
			inventoryHandler:SetSelected(targetObj, false)
			targetObj:DisconnectAll()
			if toolToDestroy then
				toolToDestroy:Destroy()
			end
			showSlots()
			inventoryHandler:searchTool()
		else
			if createPrompt("Do u sure?", "It delete all your tools from inventory", "Success") then
				for _, obj in pairs(inventoryHandler.OBJECTS.Inventory) do
					if obj.Tool then obj.Tool:Destroy() end
				end
				for _, obj in pairs(inventoryHandler.OBJECTS.HotBar) do
					if obj.Tool then obj.Tool:Destroy() end
				end
				inventoryHandler.OBJECTS.Inventory = {}
				inventoryHandler.OBJECTS.HotBar = {}
				showSlots()
				inventoryHandler:searchTool()
			end
		end
	end
end)

dropCell.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local targetObj = inventoryHandler.SelectedObject or getEquippedObj()
		if targetObj then
			local toolToDrop = targetObj.Tool
			inventoryHandler:SetSelected(targetObj, false)
			targetObj:DisconnectAll()
			if toolToDrop then
				local char = player.Character
				local humanoid = char and char:FindFirstChildOfClass("Humanoid")
				if toolToDrop.Parent ~= char and humanoid then
					humanoid:EquipTool(toolToDrop)
				end
				local tool = char and char:FindFirstChildOfClass("Tool")
				if tool then tool.Parent = game.Workspace else toolToDrop.Parent = game.Workspace end
			end
			showSlots()
			inventoryHandler:searchTool()
		else
			if createPrompt("Do u sure?", "It drop all your tools from inventory", "Success") then
				local allToolsToDrop = {}
				for _, obj in pairs(inventoryHandler.OBJECTS.Inventory) do
					if obj.Tool then table.insert(allToolsToDrop, obj.Tool) end
				end
				for _, obj in pairs(inventoryHandler.OBJECTS.HotBar) do
					if obj.Tool then table.insert(allToolsToDrop, obj.Tool) end
				end
				inventoryHandler.OBJECTS.Inventory = {}
				inventoryHandler.OBJECTS.HotBar = {}
				showSlots()
				inventoryHandler:searchTool()
				
				task.spawn(function()
					local char = player.Character
					local humanoid = char and char:FindFirstChildOfClass("Humanoid")
					for _, t in ipairs(allToolsToDrop) do
						if humanoid then
							humanoid:EquipTool(t)
							task.wait(0.1)
						end
						t.Parent = game.Workspace
						task.wait(0.05)
					end
				end)
			end
		end
	end
end)

local function getToolEquipped()
	local character = player.Character
	return character and character:FindFirstChildOfClass("Tool")
end

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel and inventoryHandler.SETTINGS.SCROLL_HOTBAR_WITH_WHEEL then
		local direction = -math.sign(input.Position.Z)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end
		local toolEquipped = getToolEquipped()
		local currentPos = inventoryHandler:getToolPosition(toolEquipped) or 0
		local targetPos = currentPos + direction
		if targetPos > inventoryHandler.slotAmount then
			targetPos = 1
		elseif targetPos < 1 then
			targetPos = inventoryHandler.slotAmount
		end
		local iterations = 0
		while iterations < inventoryHandler.slotAmount do
			local toolObject = inventoryHandler.OBJECTS.HotBar[targetPos]
			if toolObject then
				toolObject.Tool:SetAttribute("RealUnequip", tick())
				humanoid:EquipTool(toolObject.Tool)
				break
			end
			targetPos = targetPos + direction
			if targetPos > inventoryHandler.slotAmount then
				targetPos = 1
			elseif targetPos < 1 then
				targetPos = inventoryHandler.slotAmount
			end
			iterations = iterations + 1
		end
	end
end)

RunService.Stepped:Connect(function()
	local now = tick()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	local currentBackpackTools = {}
	local bp = player:FindFirstChild("Backpack")
	if bp then
		for _, child in ipairs(bp:GetChildren()) do
			if child:IsA("Tool") then
				child.CanBeDropped = true
				currentBackpackTools[child] = true
			end
		end
	end
	if character then
		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("Tool") then
				child.CanBeDropped = true
				currentBackpackTools[child] = true
			end
		end
	end

	for tool, _ in pairs(currentBackpackTools) do
		if not knownBackpackTools[tool] then
			knownBackpackTools[tool] = true
			pendingNewTools[tool] = now
		end
	end

	for tool, addedTime in pairs(pendingNewTools) do
		if now - addedTime <= 0.3 then
			if character and tool.Parent == character and humanoid then
				tool:SetAttribute("RealUnequip", tick())
				humanoid:UnequipTools()
			end
		else
			pendingNewTools[tool] = nil
		end
	end
end)

updateButtonAppearance()
showSlots()
