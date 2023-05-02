local players = game:GetService("Players")
local player = players.LocalPlayer
local mouse = player:GetMouse()
local char, hum, hrp

local leaderstats = player:WaitForChild("leaderstats")
local moneyValue = leaderstats:WaitForChild("Money")
local playerGui = player:WaitForChild("PlayerGui")

local rep = game:GetService("ReplicatedStorage")
local module = rep:WaitForChild("Module")
local chassis = require(module:WaitForChild("AlexChassis"))
local ragdoll = require(module:WaitForChild("AlexRagdoll"))
local input = require(module:WaitForChild("AlexInput"))
local heli = require(module:WaitForChild("Heli"))
local ikr15 = require(module:WaitForChild("IKR15"))
local joint = require(module:WaitForChild("Joint"))
local mathModule = require(module:WaitForChild("Math"))
local newIKv2 = require(module:WaitForChild("R15IKv2"))

local resource = rep:WaitForChild("Resource")
local ssettings = require(resource:WaitForChild("Settings"))
local event = resource:WaitForChild("Event")

local camera = workspace.CurrentCamera
local camerasFolder = workspace:WaitForChild("Cameras")
local vehiclesFolder = workspace:WaitForChild("Vehicles")
local timeValue = workspace:WaitForChild("Time")

local runService = game:GetService("RunService")
local mps = game:GetService("MarketplaceService")
local uis = game:GetService("UserInputService")
local cas = game:GetService("ContextActionService")
local starterPlayer = game:GetService("StarterPlayer")
local soundService = game:GetService("SoundService")
local starterGui = game.StarterGui
local teams = game.Teams
local tS = game:GetService("TweenService")
local lighting = game.Lighting
local debris = game:GetService("Debris")

local notificationSound = Instance.new("Sound")
notificationSound.Name = "Notification"
notificationSound.SoundId = "rbxassetid://" .. ssettings.Sounds.Notification
notificationSound.Parent = soundService

local currentSchedule = "Breakfast"
local currentCameraTween = nil

local sprinting = false
local walkingWalkSpeed = 16
local sprintingWalkSpeed = 20
local crouchedWalkSpeed = 14
local walkSpeed = walkingWalkSpeed

local isCrawling = false
local lastPunch = tick()

local holdingHandcuffs = false
local walkSpeedWeapon = false

local isDead = false
local isRagdoll = false

local t = 0

local teamSelected
local muted = false

local vehiclePacket
local vehicleSeat

local guis = {}
local connections = {}
local replicateVehicles = {}
local equippedWeapons = {}
local Inventory = {
	ItemStacks = {}
}

local inputPosition = Vector3.new(0, 0, 0)

local animIds = {
	punchLeft = "rbxassetid://6242147556",
	punchRight = "rbxassetid://6242150073",
	crawl = "rbxassetid://6242152006"
}
local anims = {}
for a, b in next, animIds do
	local animation = Instance.new("Animation")
	animation.AnimationId = b
	anims[a] = animation
end
local trackAnims = {}

local enterVehicle, leaveVehicle
local Equip, Unequip

for i, v in next, rep.StarterGui:GetChildren() do
	guis[v.Name] = v:Clone()
	guis[v.Name].Parent = playerGui
end

local function addCommas(number)
	local left, num, right = string.match(number, "^([^%d]*%d)(%d*)(.-)$")
	return left .. num:reverse():gsub("(%d%d%d)", "%1,"):reverse() .. right
end

local function dealWithInput(info, boolean, inputObject)
	if info.Name == "Crouch" then
		if boolean and trackAnims.crawl then
			if isCrawling then
				trackAnims.crawl:Stop()
				if hum then
					hum.WalkSpeed = walkingWalkSpeed
				end
				if hrp then
					hrp.CanCollide = true
				end
			else
				trackAnims.crawl:Play()
				Unequip()
				if hum then
					hum.WalkSpeed = crouchedWalkSpeed
				end
				if hrp then
					hrp.CanCollide = false
				end
			end
			isCrawling = not isCrawling
		end
	elseif info.Name == "Punch" then
		if boolean then
			local difference = (tick() - lastPunch)
			if difference < 1 then return end
			lastPunch = tick()
			local punchAnims = {}
			for a, b in next, trackAnims do
				if string.find(string.lower(a), "punch") then
					table.insert(punchAnims, b)
				end
			end
			if #punchAnims > 0 then
				local anim = punchAnims[math.random(1, #punchAnims)]
				anim:Play()
				event:FireServer({cmd = "punch"})
			end
		end
	elseif info.Name == "Sprint" then
		if not hum then return end
		if hum.Health <= 0 then return end
		if walkSpeedWeapon then return end
		if boolean then
			walkSpeed = sprintingWalkSpeed
		else
			walkSpeed = walkingWalkSpeed
		end
	end
end

local function onAction(info, boolean, inputObject)
	chassis.OnAction(info, boolean, inputObject)
	heli.OnAction(info, boolean, inputObject)
end

local actionsFrame = guis.ScreenGui:WaitForChild("ActionButtons")
local UI = input.MakeUI()
UI.Container = actionsFrame

local driftButton = input.MakeBindA("Drift", onAction, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonX)
driftButton.Image = ssettings.Images.Drift
local hornButton = input.MakeBindA("Horn", onAction, Enum.KeyCode.H, Enum.KeyCode.ButtonL3)
hornButton.Image = ssettings.Images.Horn
local lightsButton = input.MakeBindA("Lights", onAction, Enum.KeyCode.L, Enum.KeyCode.ButtonL1)
lightsButton.Image = ssettings.Images.Headlights
local flipButton = input.MakeBindA("Flip", onAction, Enum.KeyCode.V, Enum.KeyCode.ButtonR1)
flipButton.Image = ssettings.Images.CarFlip
local radioButton = input.MakeBindA("Radio", onAction, Enum.KeyCode.R)
radioButton.Image = ssettings.Images.Radio
local sirenButton = input.MakeBindA("Sirens", onAction, Enum.KeyCode.F, Enum.KeyCode.ButtonR3)
sirenButton.Image = ssettings.Images.Siren
sirenButton.Hidden = true

local upButton = input.MakeBindA("Up", onAction, Enum.KeyCode.E)
upButton.Image = ssettings.Images.HeliUp
local downButton = input.MakeBindA("Down", onAction, Enum.KeyCode.Q)
downButton.Image = ssettings.Images.HeliDown

local vehicleGroup = input.MakeGroupA(driftButton, hornButton, lightsButton, flipButton, radioButton, sirenButton)
vehicleGroup.UI = UI

local crouchButton = input.MakeBindA("Crouch", dealWithInput, Enum.KeyCode.C, Enum.KeyCode.ButtonR3)
crouchButton.Image = ssettings.Images.Crawl
local punchButton = input.MakeBindA("Punch", dealWithInput, Enum.KeyCode.F, Enum.KeyCode.ButtonB)
punchButton.Image = ssettings.Images.Punch
local sprintButton = input.MakeBindA("Sprint", dealWithInput, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL2)
sprintButton.Image = ssettings.Images.Sprint

local defaultGroup = input.MakeGroupA(crouchButton, punchButton, sprintButton)
defaultGroup.UI = UI

local lastGroup = defaultGroup

local function bindActions(inVehicle)
	input.UnbindGroup(defaultGroup)
	input.UnbindGroup(vehicleGroup)
	if inVehicle then
		if not vehiclePacket then bindActions(false) return end
		local vehicle = vehiclePacket.Model
		if not vehicle then bindActions(false) return end
		local vehicleType = vehiclePacket.Type
		local policeSirens = vehicle:FindFirstChild("PoliceLights")
		if policeSirens then policeSirens = true end
		sirenButton.Hidden = not (policeSirens)
		if vehicleType == "Heli" then
			vehicleGroup.Binds = {upButton, downButton, hornButton, radioButton}
		else
			if sirenButton.Hidden then
				vehicleGroup.Binds = {driftButton, hornButton, lightsButton, flipButton, radioButton}
			else
				vehicleGroup.Binds = {driftButton, hornButton, lightsButton, flipButton, radioButton, sirenButton}
			end
		end
		input.BindGroup(vehicleGroup)
		lastGroup = vehicleGroup
	else
		input.BindGroup(defaultGroup)
		lastGroup = defaultGroup
	end
end

function characterAdded(c)
	char = c
	hum = c:WaitForChild("Humanoid")
	hrp = char:WaitForChild("HumanoidRootPart")
	
	if connections.ragdoll then
		connections.ragdoll:Disconnect()
	end
	if connections.died then
		connections.died:Disconnect()
	end
	
	isCrawling = false
	isDead = false
	if Unequip then Unequip() end
	
	bindActions(false)
	ragdoll.Unragdoll(c)
	isRagdoll = false
	holdingHandcuffs = false
	walkSpeedWeapon = false
	
	if vehiclePacket then
		leaveVehicle(vehiclePacket)
	end
	
	--[[for _ = 1, 5 do
		camera.CameraType = Enum.CameraType.Custom
		wait()
	end]]
	
	hum.CameraOffset = Vector3.new(0, 0.35, 0)
	
	for a, b in next, trackAnims do
		if b then
			b:Stop()
			b = nil
		end
	end
	for c, d in next, anims do
		local trackAnim = hum:LoadAnimation(d)
		trackAnims[c] = trackAnim
	end
	
	local startJump
	local heightRequired = 15
	
	connections.ragdoll = hum.FreeFalling:Connect(function(active)
		if not vehiclePacket then
			if active then
				startJump = hrp.Position.Y
			else
				local jumpHeight = startJump - hrp.Position.Y
				if jumpHeight > heightRequired then
					local em = (jumpHeight - heightRequired)
					event:FireServer({cmd = "ragdoll", em = em})
					
					Unequip()
					ragdoll.Ragdoll(c)
					isRagdoll = true
					delay(3, function()
						ragdoll.Unragdoll(c)
						isRagdoll = false
					end)
				end
			end
		end
	end)
	
	connections.died = hum.Died:Connect(function()
		if ragdoll.IsRagdoll(player) then
			ragdoll.Unragdoll(c)
		end
		isCrawling = false
		isDead = true
		Unequip()
		holdingHandcuffs = false
		walkSpeedWeapon = false
	end)
end

if player.Character then
	characterAdded(player.Character)
end
player.CharacterAdded:Connect(characterAdded)

local function confirmationGui(text, yes, no)
	local confirmation = guis.ScreenGui.Confirm
	confirmation.Title.Text = text
	confirmation.Visible = true
	
	local conn1, conn2
	
	local function close()
		confirmation.Visible = false
		confirmation.Title.Text = ""
		
		conn1:Disconnect()
		conn2:Disconnect()
	end
	
	conn1, conn2 = confirmation.Yes.MouseButton1Down:Connect(function()
		if yes then yes() end
		close()
	end), confirmation.No.MouseButton1Down:Connect(function()
		if no then no() end
		close()
	end)
end

local function setCameraCf(cf)
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = cf
end

local function getTweenTime(distance, speed)
	return distance / speed
end

local function tweenCameraCf(cf, tweenTime, style, callback)
	if not style then style = Enum.EasingStyle.Linear end
	local tween = tS:Create(camera, TweenInfo.new(tweenTime, style, Enum.EasingDirection.Out, 0, false, 0), {CFrame = cf})
	tween:Play()
	currentCameraTween = tween
	task.wait(tweenTime-3.1)
	if callback then
		callback()
	end
	currentCameraTween = nil
end

local cutsceneCity
local currentCityCam = 1
local cutsceneCityPlaying = false
local currentBlackScreenTween
do
	function cutsceneCity(boolean)
		if not cutsceneCityPlaying then return end
		local function doo()
			local part = camerasFolder:FindFirstChild("City" .. currentCityCam .. "_Start")
			if not part then
				currentCityCam = 1
				cutsceneCity()
				return
			end
			local part2 = camerasFolder:FindFirstChild("City" .. currentCityCam .. "_Stop")
			if not part2 then
				currentCityCam = 1
				cutsceneCity()
				return
			end
			local distance, speed = (part.Position - part2.Position).Magnitude, 30
			local tweenTime = getTweenTime(distance, speed)
			if not cutsceneCityPlaying then return end
			currentCityCam = currentCityCam + 1
			setCameraCf(part.CFrame)
			tweenCameraCf(part2.CFrame, tweenTime, Enum.EasingStyle.Linear, function()
				if not cutsceneCityPlaying then return end
				local tween = tS:Create(guis.ScreenGui.BlackScreen, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {BackgroundTransparency = 0})
				tween:Play()
				currentBlackScreenTween = tween
				local connection
				connection = tween.Completed:Connect(function()
					if not cutsceneCityPlaying then return end
					cutsceneCity(true)
					connection:Disconnect()
				end)
			end)
		end
		if boolean then
			local part = camerasFolder:FindFirstChild("City" .. currentCityCam .. "_Start")
			if not part then
				currentCityCam = 1
				cutsceneCity(true)
				return
			end
			local part2 = camerasFolder:FindFirstChild("City" .. currentCityCam .. "_Stop")
			if not part2 then
				currentCityCam = 1
				cutsceneCity(true)
				return
			end
			setCameraCf(part.CFrame)
			local tween = tS:Create(guis.ScreenGui.BlackScreen, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {BackgroundTransparency = 1})
			tween:Play()
			doo()
		else
			doo()
		end
	end
end

local function switchTeams()
	cutsceneCityPlaying = true
	guis.ScreenGui.Team.Visible = true
	if currentCameraTween then
		currentCameraTween:Cancel()
	end
	if currentBlackScreenTween then
		currentBlackScreenTween:Cancel()
	end
	cutsceneCity()
end

local sideBar = guis.ScreenGui.Sidebar

sideBar.SwitchTeams.MouseButton1Down:Connect(function()
	confirmationGui("Switch Teams?", switchTeams, nil)
end)

sideBar.ToggleDevProducts.MouseButton1Down:Connect(function()
	guis.ProductGui.DevProduct.Visible = not guis.ProductGui.DevProduct.Visible
end)

sideBar.ToggleFeedback.MouseButton1Down:Connect(function()
	guis.ScreenGui.Feedback.Visible = not guis.ScreenGui.Feedback.Visible
end)

sideBar.ToggleMute.MouseButton1Down:Connect(function()
	if muted then
		sideBar.ToggleMute.Image = ssettings.Images.Unmute
	else
		sideBar.ToggleMute.Image = ssettings.Images.Mute
	end
	muted = not muted
end)

sideBar.ToggleSafes.MouseButton1Down:Connect(function()
	guis.ProductGui.Safe.Visible = not guis.ProductGui.Safe.Visible
end)

guis.ScreenGui.Team.Prisoner.MouseButton1Down:Connect(function()
	teamSelected = teams.Prisoner
	guis.ScreenGui.Team.Confirm.Visible = true
	
	if currentCameraTween then
		currentCameraTween:Cancel()
	end
	if currentBlackScreenTween then
		currentBlackScreenTween:Cancel()
	end
	local cameraPart = camerasFolder.Prisoner_Foodcourt
	if currentSchedule == "Breakfast" or currentSchedule == "Dinner" then
		cameraPart = camerasFolder.Prisoner_Foodcourt
	else
		cameraPart = camerasFolder.Prisoner_Yard
	end
	cutsceneCityPlaying = false
		setCameraCf(cameraPart.CFrame + Vector3.new(2, 1, 2))
		tweenCameraCf(cameraPart.CFrame, 0.5, Enum.EasingStyle.Sine, false)
end)

guis.ScreenGui.Team.Police.MouseButton1Down:Connect(function()
	teamSelected = teams.Police
	guis.ScreenGui.Team.Confirm.Visible = true
	
	if currentCameraTween then
		currentCameraTween:Cancel()
	end
	if currentBlackScreenTween then
		currentBlackScreenTween:Cancel()
	end
	cutsceneCityPlaying = false
	setCameraCf(camerasFolder.Cop.CFrame + Vector3.new(2, 1, 2))
	tweenCameraCf(camerasFolder.Cop.CFrame, 0.5, Enum.EasingStyle.Sine, false)
end)

guis.ScreenGui.Team.Confirm.MouseButton1Down:Connect(function()
	event:FireServer({cmd = "changeTeams", t = teamSelected})
	guis.ScreenGui.Team.Visible = false
	guis.ScreenGui.Team.Confirm.Visible = false
	
	--[[camera.CFrame = hrp.CFrame
	for _ = 1, 5 do
		camera.CameraType = Enum.CameraType.Custom
		wait()
	end]]
end)

guis.ScreenGui.Feedback.Close.MouseButton1Down:Connect(function()
	guis.ScreenGui.Feedback.Visible = false
end)

guis.ScreenGui.Feedback.Submit.MouseButton1Down:Connect(function()
	local text = guis.ScreenGui.Feedback.TextBox.Text
	if string.len(text) > 0 then
		event:FireServer({cmd = "feedback", em = text})
		guis.ScreenGui.Feedback.Visible = false
	end
end)

guis.ProductGui.DevProduct.Close.MouseButton1Down:Connect(function()
	guis.ProductGui.DevProduct.Visible = false
end)

for a, b in next, guis.ProductGui.DevProduct.Body.Buy:GetChildren() do
	b.MouseButton1Down:Connect(function()
		local amount = string.split(b.Price.Text, "$")
		amount = amount[2]
		amount = tonumber(amount)
		local found
		
		for c, d in next, ssettings.DevProduct do
			if d.Amount == amount then
				found = d.Amount
				break
			end
		end
		
		if found then
			mps:PromptProductPurchase(player, found)
		end
	end)
end

guis.ProductGui.Safe.Close.MouseButton1Down:Connect(function()
	guis.ProductGui.Safe.Visible = false
end)

guis.ScreenGui.CollectMoney.DuffelBag.MouseButton1Down:Connect(function()
	mps:PromptGamePassPurchase(player, ssettings.Gamepass.DuffelBag.PassId)
end)

local function updateMoneyText()
	guis.ProductGui.DevProduct.Money.Text = ("$%s"):format(addCommas(moneyValue.Value))
	guis.ScreenGui.BuyVehicle.Money.Text = ("$%s"):format(addCommas(moneyValue.Value))
end

updateMoneyText()
moneyValue:GetPropertyChangedSignal("Value"):Connect(updateMoneyText)

guis.ScreenGui.BuyVehicle.Buy.MouseButton1Down:Connect(function()
	local vehicleName = guis.ScreenGui.BuyVehicle.Vehicle.Value
	if vehicleName == "" then
		vehicleName = "Model3"
	end
	event:FireServer({cmd = "buyVehicle", vehicleName = vehicleName})
	guis.ScreenGui.BuyVehicle.Visible = false
	guis.ScreenGui.BuyVehicle.Vehicle.Value = ""
	guis.ScreenGui.BuyVehicle.TextLabel.Text = ""
end)

guis.ScreenGui.BuyVehicle.Cancel.MouseButton1Down:Connect(function()
	guis.ScreenGui.BuyVehicle.Visible = false
	guis.ScreenGui.BuyVehicle.Vehicle.Value = ""
	guis.ScreenGui.BuyVehicle.TextLabel.Text = ""
end)

local function promptBuyVehicle(vehicleName, vehiclePrice)
	guis.ScreenGui.BuyVehicle.Vehicle.Value = vehicleName
	guis.ScreenGui.BuyVehicle.TextLabel.Text = ("Buy %s for $%s?"):format(vehicleName, addCommas(vehiclePrice))
	guis.ScreenGui.BuyVehicle.Visible = true
end

local function updateChassisLowQuality(packet, dt)
	local model, height, ttype = packet.Model, packet.Height, packet.Type
	if not model then return end
	local engine = model:FindFirstChild("Engine")
	if not engine then return end
	
	local velocity = engine.CFrame:VectorToObjectSpace(engine.Velocity)
	local distance = velocity.Z * dt
	
	local wheelRotation = packet.WheelRotation + distance / (model.WheelFrontRight.Wheel.Size.Y * 0.5 * math.pi)
	wheelRotation = wheelRotation % (2 * math.pi)
	packet.WheelRotation = wheelRotation
	
	chassis.UpdateWheelLowQuality(packet, model, height, packet.PartFrontRight, wheelRotation)
	chassis.UpdateWheelLowQuality(packet, model, height, packet.PartFrontLeft, wheelRotation)
	chassis.UpdateWheelLowQuality(packet, model, height, packet.PartBackRight, wheelRotation)
	chassis.UpdateWheelLowQuality(packet, model, height, packet.PartBackLeft, wheelRotation)
	
	chassis.UpdateSoundLowQuality(packet, packet.Gears, velocity)
end

local function updateHeliLowQuality(packet, dt)
	local model = packet.Model
	if not model then
		return
	end
	local engine = model:FindFirstChild("Engine")
	if not engine then
		return
	end
	heli.SpinProp(packet, dt)
end

local dddt = 1
function enterVehicle(packet)
	vehiclePacket = packet
	if not vehicleSeat then return end
	if packet.Type == "Heli" then
		if vehicleSeat == "Driver" then
			updateHeliLowQuality(packet, dddt)
		end
		heli.VehicleEnter(packet)
	else
		if vehicleSeat == "Driver" then
			updateChassisLowQuality(packet, dddt)
			chassis.UpdateStats(packet)
		end
		chassis.VehicleEnter(packet)
	end
	bindActions(vehicleSeat == "Driver" and true or false)
	Unequip()
end

function leaveVehicle(packet)
	vehiclePacket = nil
	if packet.Type == "Heli" then
		heli.VehicleLeave(packet)
	else
		chassis.VehicleLeave(packet)
	end
	vehicleSeat = nil
	bindActions(false)
end

local function fpor2(Position, Direction, ...)
	local v3b = Vector3.new(0, 0, 0)
	local MaxDistance = Direction.magnitude
	Direction = Direction.unit
	local LastPosition = Position
	local Distance = 0
	local Ignore = {
		...
	}
	local h, p, n = nil, v3b, v3b
	local Attempts = 0
	repeat
		Attempts = Attempts + 1
		local r = Ray.new(LastPosition, Direction * (MaxDistance - Distance))
		h, p, n = workspace:FindPartOnRayWithIgnoreList(r, Ignore, false, true)
		local Done = h and h.CanCollide and h.Parent.Name ~= "Cone"
		if not Done then
			table.insert(Ignore, h)
		end
		Distance = (Position - p).magnitude
		LastPosition = p
	until Done or MaxDistance - Distance <= 0.001 or Attempts > 4
	if not h then
		p, n = Position + Direction * MaxDistance, v3b
	end
	return h, p, n
end

local MouseButton1Down = false

local function playSound(player2, itemStack, soundType)
	local sound = player2.Character.PrimaryPart:FindFirstChild(soundType)
	if not sound then return end
	
	if sound.IsPlaying then
		sound:Stop()
	end
	if soundType == "Fire" then
		sound.TimePosition = itemStack.Name == "Pistol" and 8 or 0
	end
	
	sound:Play()
	if soundType == "Reload" then return end
	
	local playTime = itemStack.Delay
	if itemStack.Name == "Taser" then
		playTime = sound.TimeLength
	end
	
	delay(playTime, function()
		sound:Stop()
	end)
end

local function RawMB1(PlayerName, Position, IsLocal)
	local Player = players:FindFirstChild(PlayerName)
	if not Player then
		return
	end
	local ItemStack = equippedWeapons[PlayerName]
	if not ItemStack then
		return
	end
	playSound(Player, ItemStack, "Fire")
	if Position == nil then return end
	local Model = ItemStack.Model
	local Name = ItemStack.Name
	if Name == "Taser" then
		local Tip = Model.Skeleton.Tip
		local d = (Position - Tip.Position).Magnitude
		local Part = Instance.new("Part")
		Part.BrickColor = Name == "Taser" and BrickColor.new("Black")
		Part.Anchored = true
		Part.CanCollide = false
		Part.Size = Vector3.new(0.2, 0.2, d)
		Part.CFrame = CFrame.new(Tip.Position, Position) * CFrame.new(0, 0, -d * 0.5)
		local Mesh = Instance.new("BlockMesh")
		Mesh.Scale = Vector3.new(0.4, 0.4, 1)
		Mesh.Parent = Part
		Part.Parent = ItemStack.Model
		debris:AddItem(Part, 0.1)
	elseif ItemStack.Name == "Rifle" or ItemStack.Name == "Pistol" then
		local Tip = Model.Skeleton.Tip
		local d = (Position - Tip.Position).Magnitude
		local Part = Instance.new("Part")
		Part.BrickColor = BrickColor.new("White")
		Part.Transparency = 0.6
		Part.Anchored = true
		Part.CanCollide = false
		Part.Size = Vector3.new(0.3, d, 0.3)
		Part.CFrame = CFrame.new(Tip.Position, Position) * CFrame.new(0, 0, -d * 0.5) * CFrame.Angles(math.pi * 0.5, 0, 0)
		local Mesh = Instance.new("CylinderMesh")
		Mesh.Scale = Vector3.new(0.3, 1, 0.3)
		Mesh.Parent = Part
		Part.Parent = ItemStack.Model
		debris:AddItem(Part, 0.1)
	elseif ItemStack.Name == "Shotgun" then
		local RealPosition = Position
		for i = 1, ItemStack.Pellets do
			local x, y, z = (math.random() - 0.5) * 0.23, (math.random() - 0.5) * 0.23, (math.random() - 0.5) * 0.23
			local Tip = Model.Skeleton.Tip
			local d = (Position - Tip.Position).Magnitude
			Position = RealPosition + Vector3.new(x, y, z) * d * 0.9
			local Part = Instance.new("Part")
			Part.BrickColor = BrickColor.new("White")
			Part.Transparency = 0.6
			Part.Anchored = true
			Part.CanCollide = false
			Part.Size = Vector3.new(0.3, d, 0.3)
			Part.CFrame = CFrame.new(Tip.Position, Position) * CFrame.new(0, 0, -d * 0.5) * CFrame.Angles(math.pi * 0.5, 0, 0)
			local Mesh = Instance.new("CylinderMesh")
			Mesh.Scale = Vector3.new(0.3, 1, 0.3)
			Mesh.Parent = Part
			Part.Parent = ItemStack.Model
			debris:AddItem(Part, 0.1)
		end
	end
end

function GetMousePoint(X, Y)
	local RayMag1 = camera:ScreenPointToRay(X, Y)
	local NewRay = Ray.new(RayMag1.Origin, RayMag1.Direction * 1000)
	local Target, Position = workspace:FindPartOnRay(NewRay, char)
	return Position
end 

local function RayFromTip(ItemStack, Center, Offset)
	local Model = ItemStack.Model
	local Skeleton = Model:FindFirstChild("Skeleton")
	if not Skeleton then
		return
	end
	local Tip = Skeleton:FindFirstChild("Tip")
	if not Tip then
		return
	end
	local x, y
	if Center == true then
		local ViewportSize = guis.ScreenGui.AbsoluteSize 
		x, y = ViewportSize.X * 0.5, ViewportSize.Y * 0.3
	else
		x, y = inputPosition.X, inputPosition.Y
	end
	local cvptr = camera:ViewportPointToRay(x, y, 1000) 
	local V3Mouse = GetMousePoint(x,y)
	local FireDirection = (mouse.Hit.p - Tip.CFrame.p).Unit
	local DirectionWithMagnitude = FireDirection * 1000
	local r = Ray.new(Tip.CFrame.p, mouse.Hit.lookVector * 1000)
	local _, MousePoint = workspace:FindPartOnRayWithIgnoreList(r, {ItemStack.Model, char})
	local d = (MousePoint - Tip.Position).unit 
	if Offset then
		d = d + Offset
	end
	local MaxDistance = 250
	if ItemStack.Name == "Taser" then
		MaxDistance = 100
	end
	local h, p = fpor2(Tip.Position, d * MaxDistance, ItemStack.Model, char)
	return h, p
end

local function GunShoot(h, p, ItemStack)
	if not h then
		return
	end
	local Character = h.Parent
	if not Character then
		return
	end
	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
	if not Humanoid then
		Character = Character.Parent
		if not Character then
			return
		end
		Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
		if not Humanoid then
			return
		end
	end
	local target = players:GetPlayerFromCharacter(Character)
	if not target then
		return
	end
	event:FireServer({cmd = "damage", target = target, damage = ItemStack.Damage})
end

local function GunReload(ItemStack, Time)
	Time = Time or 2
	if ItemStack.Reloading then
		return
	end
	ItemStack.Reloading = true
	playSound(player, ItemStack, "Reload")
	if ItemStack.Name == "Taser" then
		local function Finish()
			ItemStack.MagSize = ItemStack.MaxMagSize
			UpdateAmmoGui(ItemStack)
			ItemStack.Reloading = false
			playSound(player, ItemStack, "Reload")
		end
		delay(Time, Finish)
	elseif ItemStack.Name == "Rifle" then
		local function Finish()
			ItemStack.MagSize = ItemStack.MaxMagSize
			UpdateAmmoGui(ItemStack)
			ItemStack.Reloading = false
			playSound(player, ItemStack, "Reload")
		end
		delay(Time, Finish)
	elseif ItemStack.Name == "Shotgun" then
		local function Finish()
			ItemStack.MagSize = ItemStack.MaxMagSize
			UpdateAmmoGui(ItemStack)
			ItemStack.Reloading = false
			playSound(player, ItemStack, "Reload")
		end
		delay(Time, Finish)
	elseif ItemStack.Name == "Pistol" then
		local function Finish()
			ItemStack.MagSize = ItemStack.MaxMagSize
			UpdateAmmoGui(ItemStack)
			ItemStack.Reloading = false
			playSound(player, ItemStack, "Reload")
		end
		delay(Time, Finish)
	end
end

local ClickProxy = 0
local IsAttemptingHS = false

local function MB1(ItemStack, Center)
	local Character = char
	if not Character then
		return
	end
	local HumanoidRootPart = hrp
	if not HumanoidRootPart then
		return
	end
	local mClickProxy = ClickProxy + 1
	ClickProxy = mClickProxy
	if ItemStack.Name == "Rifle" then
		if tick() - ItemStack.LastFire < ItemStack.Delay then
			return
		end
		if IsAttemptingHS then
			return
		end
		while true do
			if ClickProxy ~= mClickProxy then
				return
			end
			if ItemStack.Reloading then
				return
			end
			if not MouseButton1Down or IsAttemptingHS then 
				return
			end
			ItemStack.LastFire = tick()
			local h, p = RayFromTip(ItemStack, Center)
			GunShoot(h, p, ItemStack)
			event:FireServer({cmd = "replicateShoot", position = p})
			RawMB1(player.Name, p, true)
			local MagSize = ItemStack.MagSize - 1
			ItemStack.MagSize = MagSize
			UpdateAmmoGui(ItemStack)
			if MagSize <= 0 then
				GunReload(ItemStack, ItemStack.ReloadTime)
				return
			end
			local Delay = ItemStack.Delay
			wait(Delay)
		end
	elseif ItemStack.Name == "Pistol" then
		if tick() - ItemStack.LastFire < ItemStack.Delay then
			return
		end
		if ItemStack.Reloading then
			return
		end
		if not MouseButton1Down then 
			return
		end
		if IsAttemptingHS then
			return
		end
		ItemStack.LastFire = tick()
		local h, p = RayFromTip(ItemStack, Center)
		GunShoot(h, p, ItemStack)
		event:FireServer({cmd = "replicateShoot", position = p})
		RawMB1(player.Name, p, true)
		local MagSize = ItemStack.MagSize - 1
		ItemStack.MagSize = MagSize
		UpdateAmmoGui(ItemStack)
		if MagSize <= 0 then
			return GunReload(ItemStack, ItemStack.ReloadTime)
		end
	elseif ItemStack.Name == "Shotgun" then
		if tick() - ItemStack.LastFire < ItemStack.Delay then
			return
		end
		if IsAttemptingHS then
			return
		end
		while true do
			if ClickProxy ~= mClickProxy then
				return
			end
			if ItemStack.Reloading then
				return
			end
			if not MouseButton1Down then 
				return
			end
			if IsAttemptingHS then
				return
			end
			ItemStack.LastFire = tick()
			local h, p = RayFromTip(ItemStack, Center)
			GunShoot(h, p, ItemStack)
			for i = 1, math.ceil(ItemStack.Pellets / 2) do
				local x, y, z = (math.random() - 0.5) * 0.23, (math.random() - 0.5) * 0.23, (math.random() - 0.5) * 0.23
				local h, p = RayFromTip(ItemStack, Center, Vector3.new(x, y, z))
				GunShoot(h, p, ItemStack)
			end
			event:FireServer({cmd = "replicateShoot", position = p})
			RawMB1(player.Name, p, true)
			local MagSize = ItemStack.MagSize - 1
			ItemStack.MagSize = MagSize
			UpdateAmmoGui(ItemStack)
			if MagSize <= 0 then
				GunReload(ItemStack, ItemStack.ReloadTime)
				return
			end
			local Delay = ItemStack.Delay
			wait(Delay)
		end
	elseif ItemStack.Name == "Taser" then
		if tick() - ItemStack.LastFire < ItemStack.Delay then
			return
		end
		if ItemStack.Reloading then
			return
		end
		if IsAttemptingHS then
			return
		end
		ItemStack.LastFire = tick()
		local h, p = RayFromTip(ItemStack, false)
		if h and h.Parent:FindFirstChild("Humanoid") then
			local Character = h.Parent
			local target = players:GetPlayerFromCharacter(Character)
			if target then
				event:FireServer({cmd = "taser", target = target})
			end
		end
		event:FireServer({cmd = "replicateShoot", position = p})
		RawMB1(player.Name, p, true)
		local MagSize = ItemStack.MagSize - 1
		ItemStack.MagSize = MagSize
		UpdateAmmoGui(ItemStack)
		if MagSize <= 0 then
			GunReload(ItemStack, ItemStack.ReloadTime)
			return
		end
	end
end

function UpdateAmmoGui(ItemStack)
	if ItemStack.MagSize then
		local Ammo = guis.ScreenGui.Ammo
		Ammo.Current.Text = ("%s/"):format(ItemStack.MagSize)
		Ammo.MagSize.Text = ItemStack.MaxMagSize
	end
end

function ShowAmmoGui(ItemStack)
	if ItemStack.IsGun then
		UpdateAmmoGui(ItemStack)
		guis.ScreenGui.Ammo.Visible = true
	end
end

function HideAmmoGui()
	guis.ScreenGui.Ammo.Visible = false
end

local function RawEquip(PlayerName, ItemStack, IKPacket, IsLocal)
	if equippedWeapons[PlayerName] then
		return
	end
	local Player = players:FindFirstChild(PlayerName)
	if not Player then
		return
	end
	local Character = Player.Character
	if not Character then
		return
	end
	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	if not HumanoidRootPart then
		return
	end
	local UpperTorso = Character:FindFirstChild("UpperTorso")
	if not UpperTorso then
		return
	end
	local Waist = UpperTorso:FindFirstChild("Waist")
	if not Waist then
		return
	end
	local Head = Character:FindFirstChild("Head")
	if not Head then
		return
	end
	local Neck = Head:FindFirstChild("Neck")
	if not Neck then
		return
	end
	local v3b = Vector3.new()
	local cfb = CFrame.new()
	local Items = resource.Item
	local Item = Items:FindFirstChild(ItemStack.Name)
	if not Item then return end
	Item = Item:Clone()
	Item.Parent = workspace
	joint.WeldAllTo(Item, Item.Center)
	ItemStack.Waist = Waist
	ItemStack.Neck = Neck
	ItemStack.WaistC0 = Waist.C0
	ItemStack.NeckC0 = Neck.C0
	ItemStack.LastFire = 0
	local IsRightArm = not not Item.Skeleton:FindFirstChild("RightArm")
	local IsLeftArm = not not Item.Skeleton:FindFirstChild("LeftArm")
	local Packet = {RightArm = IsRightArm, LeftArm = IsLeftArm}
	local PosStart, RotStart
	if IsRightArm and IsLeftArm then
		PosStart = Vector3.new(0.5, -0.5, -0.5)
		RotStart = Vector3.new(-math.pi * 0.5, 0, 0)
	else
		PosStart = Vector3.new(-0.1, 0.5, -0.2)
		RotStart = Vector3.new(math.pi * 0.5, 0, 0)
	end
	ItemStack.PosSpring = mathModule.MakeSpring(PosStart, 10, 0.6)
	ItemStack.RotSpring = mathModule.MakeSpring(RotStart, 14, 0.7)
	ItemStack.NeckSpring = mathModule.MakeSpring(v3b, 2, 0.5)
	ItemStack.WaistSpring = mathModule.MakeSpring(v3b, 10, 0.8)
	mathModule.SpringSetTarget(ItemStack.RotSpring, t, v3b)
	mathModule.SpringSetTarget(ItemStack.PosSpring, t, Vector3.new(0, 0.7, 0))
	if ItemStack.Name == "Rifle" then
		mathModule.SpringSetTarget(ItemStack.NeckSpring, t, Vector3.new(0, 0.43, 0))
		mathModule.SpringSetTarget(ItemStack.WaistSpring, t, Vector3.new(0, -0.43, 0))
		mathModule.SpringSetTarget(ItemStack.PosSpring, t, v3b)
	elseif ItemStack.Name == "Shotgun" then
		mathModule.SpringSetTarget(ItemStack.NeckSpring, t, Vector3.new(0, 0.6, 0))
		mathModule.SpringSetTarget(ItemStack.WaistSpring, t, Vector3.new(0, -0.6, 0))
	elseif ItemStack.Name == "Cuffed" then
		mathModule.SpringSetTarget(ItemStack.NeckSpring, t, Vector3.new(-0.5, 0, 0))
		mathModule.SpringSetTarget(ItemStack.WaistSpring, t, Vector3.new(-0.4, 0, 0))
		mathModule.SpringSetTarget(ItemStack.PosSpring, t, Vector3.new(0, -0.7, 0))
	elseif (ItemStack.Name == "Pistol") and ItemStack.HasSwat then
		Item.Model.Handle.Mesh.VertexColor = Vector3.new(0, 0, 0)
	end
	local UpdateRightArm, UpdateLeftArm = true, true
	if IKPacket then
		UpdateRightArm = Packet.RightArm ~= IKPacket.RightArm
		UpdateLeftArm = Packet.LeftArm ~= IKPacket.LeftArm
		local RightArm, LeftArm = Packet.RightArm, Packet.LeftArm
		Packet = IKPacket
		Packet.RightArm, Packet.LeftArm = RightArm, LeftArm
	end
	if true or UpdateRightArm then
	end
	if true or UpdateLeftArm then
	end
	local pk = newIKv2.BuildPacketArms(Character)
	for i, v in pairs(pk) do
		Packet[i] = v
	end
	ItemStack.IK = Packet
	local Part1
	if ItemStack.Name == "Cuffed" then
		Part1 = Character.UpperTorso
	else
		Part1 = Character.Head
	end
	local C0 = CFrame.new(ItemStack.PosSpring.p) * mathModule.CFrameFromAxisAngle(ItemStack.RotSpring.p)
	local Motor = joint.CustomMotor(Item.Center, Part1, C0, cfb)
	ItemStack.Motor = Motor
	ItemStack.Model = Item
	equippedWeapons[PlayerName] = ItemStack
	if IsLocal and ItemStack.MagSize then
		UpdateAmmoGui(ItemStack)
	end
	if ItemStack.WalkSpeed then
		if hum and not isDead then
			walkSpeed = ItemStack.WalkSpeed
			walkSpeedWeapon = true
		end
	end
	if ItemStack.IsGun then
		local soundTypes = {"Fire", "Reload"}
		for _, soundType in next, soundTypes do
			local oldSound = HumanoidRootPart:FindFirstChild(soundType)
			if oldSound then
				oldSound:Destroy()
			end
			local soundId = ssettings.Sounds[ItemStack.Name .. soundType]
			if soundId then
				local sound = Instance.new("Sound")
				sound.Name = soundType
				sound.Volume = 1
				sound.Parent = HumanoidRootPart
				sound.SoundId = "rbxassetid://" .. soundId
			end
		end
	end
	if not ItemStack.Locked then
		local sound = Instance.new("Sound")
		sound.Name = "Equip"
		sound.Volume = 2.5
		sound.Parent = HumanoidRootPart
		sound.SoundId = "rbxassetid://" .. ssettings.Sounds.Equip
		repeat
			wait()
		until sound.TimeLength
		sound:Play()
		delay(3, function()
			sound:Destroy()
		end)
	end
	MouseButton1Down = false
end

local function RawUnequip(PlayerName, KeepIK, IsLocal)
	local Player = players:FindFirstChild(PlayerName)
	if not Player then
		return
	end
	local ItemStack = equippedWeapons[PlayerName]
	if not ItemStack then
		return
	end
	local Character = Player.Character
	ItemStack.Model:Destroy()
	ItemStack.Motor = nil
	equippedWeapons[PlayerName] = nil
	if IsLocal then
	end
	if not KeepIK then
		ikr15.EnableRightArm(ItemStack.IK, Character, false)
		ikr15.EnableLeftArm(ItemStack.IK, Character, false)
	end
	local UpperTorso = Character:FindFirstChild("UpperTorso")
	if UpperTorso then
		local Waist = UpperTorso:FindFirstChild("Waist")
		if Waist then
			Waist.C0 = ItemStack.WaistC0
		end
	end
	local Head = Character:FindFirstChild("Head")
	if Head then
		local Neck = Head:FindFirstChild("Neck")
		if Neck then
			Neck.C0 = ItemStack.NeckC0
		end
	end
	if ItemStack.FreeBody then
	end
	if IsLocal then
	end
	if ItemStack.WalkSpeed then
		walkSpeed = walkingWalkSpeed
		walkSpeedWeapon = false
	end
	MouseButton1Down = false
end

function Equip(ItemStack, IKPacket)
	if ItemStack then
		local Frame = guis.ScreenGui.Inventory.Inner:FindFirstChild(ItemStack.Name)
		if Frame then
			Frame.ImageTransparency = 0.5
		end
	end
	event:FireServer({cmd = "equipItem", stack = ItemStack})
	MouseButton1Down = false
	ShowAmmoGui(ItemStack)
	if ItemStack.Name == "Handcuffs" then
		holdingHandcuffs = true
	end
	return RawEquip(player.Name, ItemStack, IKPacket, true)
end

function Unequip(KeepIK)
	local ItemStack = equippedWeapons[player.Name]
	if ItemStack then
		local Frame = guis.ScreenGui.Inventory.Inner:FindFirstChild(ItemStack.Name)
		if Frame then
			Frame.ImageTransparency = 0
		end
	end
	event:FireServer({cmd = "unequipItem"})
	MouseButton1Down = false
	HideAmmoGui()
	holdingHandcuffs = false
	return RawUnequip(player.Name, KeepIK, true)
end

local LastHotbarIndex = 0
local function AttemptHotbarSelect(i)
	LastHotbarIndex = i
	local ItemStack = equippedWeapons[player.Name]
	if isCrawling or isDead or isRagdoll then
		return
	end
	if vehiclePacket then
		return
	end
	if ItemStack and ItemStack.Locked then
		return
	end
	local NewItem = Inventory.ItemStacks[i]
	local ShouldEquipNewItem
	if not ItemStack then
		ShouldEquipNewItem = true
	else
		ShouldEquipNewItem = ItemStack and NewItem and NewItem.i ~= ItemStack.i
	end
	local IKPacket
	if ItemStack then
		Unequip()
	else
		if NewItem then
			IKPacket = NewItem.IK
		end
	end
	if NewItem and ShouldEquipNewItem then
		Equip(NewItem, IKPacket)
		local Character = player.Character
		if Character then
			local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
		end
	end
end

function ChangeInventory(m, ForceEquip)
	Inventory = m
	local ItemStack = equippedWeapons[player.Name]
	local locked = false
	if ItemStack then
		local Found = false
		if Inventory then
			for _, v in next, Inventory, nil do
				if v.i == ItemStack.i then
					Found = true
					break
				end
			end
		end
		if not Found then
			Unequip()
		end
	end
	local ScreenGui = guis.ScreenGui
	local Inner = ScreenGui.Inventory.Inner
	local Preset = ScreenGui.Inventory.ItemPreset
	local Indexed = {}
	Inner.Visible = true
	if m then
		for k, ItemStack in next, m.ItemStacks, nil do
			do
				local Name = ItemStack.Name
				local Frame = Inner:FindFirstChild(Name)
				if not Frame then
					Frame = Preset:Clone()
					Frame.Name = Name
					Frame.Parent = Inner
					Frame.Visible = true
					Frame.ImageTransparency = 0
					Frame.LayoutOrder = ItemStack.i
					Frame.MouseButton1Down:connect(function()
						MouseButton1Down = false
						AttemptHotbarSelect(Indexed[Frame])
					end)
				end
				Frame.Image = player.Team == teams.Police and ssettings.Images.CirclePolice or ssettings.Images.CirclePrisoner
				Frame.TextLabel.Text = ItemStack.i
				Frame.TextLabel.TextColor3 = player.Team == teams.Police and ssettings.Images.CirclePoliceColor or ssettings.Images.CirclePrisonerColor
				local weaponIcon = ssettings.Images[Name]
				if weaponIcon then
					Frame.ImageLabel.Image = weaponIcon
				end
				Indexed[Frame] = k
			end
		end
	end
	for _, v in next, Inner:GetChildren() do
		if not Indexed[v] and v.Name ~= "Template" and v.Name ~= "UIListLayout" then
			v:Destroy()
		end
	end
	if ForceEquip then
		local ItemStack = equippedWeapons[player.Name]
		if ItemStack and ItemStack.Locked then
			return
		end
		if not ForceEquip.Locked then
			return
		end
		Equip(ForceEquip)
		if ForceEquip.Locked then
			Inner.Visible = false
		end
	end
end

event.OnClientEvent:Connect(function(args)
	if args.cmd == "enterVehicle" then
		enterVehicle(args.packet)
	elseif args.cmd == "leaveVehicle" then
		leaveVehicle(args.packet)
	elseif args.cmd == "forceLeave" then
		event:FireServer({cmd = "leaveVehicle"})
	elseif args.cmd == "updateReplicateVehicles" then
		replicateVehicles = args.replicateVehicles
	elseif args.cmd == "changeInventory" then
		ChangeInventory(args.inventory, args.forceEquip)
	elseif args.cmd == "equipItem" then
		RawEquip(args.playerName, args.stack)
	elseif args.cmd == "unequipItem" then
		RawUnequip(args.playerName)
	elseif args.cmd == "showRobberyGui" then
		guis.ScreenGui.CollectMoney.Money.Text = "$0"
		guis.ScreenGui.CollectMoney.Progress.Frame.Size = UDim2.new(0, 0, 1, 0)
		guis.ScreenGui.CollectMoney.Visible = true
	elseif args.cmd == "hideRobberyGui" then
		guis.ScreenGui.CollectMoney.Visible = false
	elseif args.cmd == "updateRobberyGui" then
		guis.ScreenGui.CollectMoney.Money.Text = ("$%s"):format(addCommas(args.money))
		tS:Create(guis.ScreenGui.CollectMoney.Progress.Frame, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {Size = UDim2.new((args.money / args.maxMoney), 0, 1, 0)}):Play()
	elseif args.cmd == "showBountyGui" then
		
	elseif args.cmd == "hideBountyGui" then
		
	elseif args.cmd == "updateBountyGui" then
		
	elseif args.cmd == "sendNotification" then
		notificationSound:Play()
		local s, e  = pcall(function()
			starterGui:SetCore("SendNotification", args.info)
		end)
		if not s then
			warn(e)
		end
	elseif args.cmd == "chatMessage" then
		local s, e  = pcall(function()
			starterGui:SetCore("ChatMakeSystemMessage", args.info)
		end)
		if not s then
			warn(e)
		end
	elseif args.cmd == "promptBuyVehicle" then
		promptBuyVehicle(args.vehicleName, args.vehiclePrice)
	elseif args.cmd == "promptPlusCash" then
		guis.ScreenGui.PlusCash.Text = args.text1
		guis.ScreenGui.PlusCash.Desc.Text = args.text2 or ""
		guis.ScreenGui.PlusCash.Visible = true
		delay(5, function()
			guis.ScreenGui.PlusCash.Visible = false
			guis.ScreenGui.PlusCash.Text = ""
			guis.ScreenGui.PlusCash.Desc.Text = ""
		end)
	elseif args.cmd == "promptBannerGui" then
		guis.ScreenGui.Banner.Title.Text = args.title
		guis.ScreenGui.Banner.Desc.Text = args.desc
		guis.ScreenGui.Banner.Visible = true
		delay(5, function()
			guis.ScreenGui.Banner.Visible = false
			guis.ScreenGui.Banner.Title.Text = ""
			guis.ScreenGui.Banner.Desc.Text = ""
		end)
	elseif args.cmd == "promptFaultyAction" then
		guis.ScreenGui.FaultyAction.Visible = true
		delay(5, function()
			guis.ScreenGui.FaultyAction.Visible = false
		end)
	elseif args.cmd == "promptCellTime" then
		guis.ScreenGui.CellTime.Visible = true
		for i = ssettings.Time.Cell, 0, -1 do
			guis.ScreenGui.CellTime.Time.Text = i .. "s"
			wait(1)
		end
		guis.ScreenGui.CellTime.Visible = false
	elseif args.cmd == "tween" then
		args.b = TweenInfo.new(
			args.b.t or 1,
			args.b.s or Enum.EasingStyle.Linear,
			args.b.d or Enum.EasingDirection.Out,
			args.b.r or 0,
			args.b.re or false,
			args.b.de or 0
		)
		tS:Create(args.a, args.b, args.c):Play()
	elseif args.cmd == "ragdoll" then
		if char then
			ragdoll.Ragdoll(char)
			isRagdoll = true
			delay(args.time, function()
				ragdoll.Unragdoll(char)
				isRagdoll = false
			end)
		end
	elseif args.cmd == "replicateShoot" then
		RawMB1(args.playerName, args.position)
	end
end)

local ePromptFunc, ePrompt
do
	local currentObject
	local currentRange
	local action
	
	local circleAction = guis.ScreenGui.CircleAction
	
	function ePromptFunc(inputName, inputState, inputObject)
		if not hrp then return end
		if not hum then return end
		if hum.Health <= 0 then return end
		
		if not currentObject then return end
		if not currentRange then return end
		if not action then return end
		
		local function inRange(part)
			return (hrp.Position - part.Position).Magnitude < currentRange
		end
		
		if inputState == Enum.UserInputState.Begin then
			if not vehiclePacket then
				local playerValue = currentObject:FindFirstChild("Player")
				if playerValue then
					if not inRange(currentObject) then
						return
					end
					
					if playerValue.Value then
						if action == "eject" then
							if not holdingHandcuffs then return end
							event:FireServer({cmd = "eject", vehicle = currentObject.Parent})
						end
					else
						if action == "enterVehicle" then
							if string.lower(currentObject.Name) == "seat" then
								vehicleSeat = "Driver"
							elseif string.find(string.lower(currentObject.Name), "passenger") then
								vehicleSeat = "Passenger"
							end
							event:FireServer({cmd = "enterVehicle", vehicle = currentObject.Parent, seat = currentObject})
						end
					end
				end
			end
			
			if action == "arrest" or action == "pickpocket" then
				if currentObject.Team then
					if currentObject.Team == teams.Prisoner or currentObject.Team == teams.Criminal then
						if player.Team == teams.Police then
							local char2 = currentObject.Character
							if not char2 then return end
							local hum2 = char:FindFirstChildWhichIsA("Humanoid")
							if not hum2 then return end
							if hum2:GetState() == Enum.HumanoidStateType.Seated then return end
							local hrp2 = char2:FindFirstChild("HumanoidRootPart")
							if not hrp2 then return end
							
							if not inRange(hrp2) then
								return
							end
							
							if not holdingHandcuffs then return end
							if currentObject:FindFirstChild("Arrested") then return end
							
							event:FireServer({cmd = "arrest", target = currentObject})
						end
					elseif currentObject.Team == teams.Police then
						if player.Team == teams.Prisoner or player.Team == teams.Criminal then
							local char2 = currentObject.Character
							if not char2 then return end
							local hum2 = char:FindFirstChildWhichIsA("Humanoid")
							if not hum2 then return end
							if hum2:GetState() == Enum.HumanoidStateType.Seated then return end
							local hrp2 = char2:FindFirstChild("HumanoidRootPart")
							if not hrp2 then return end
							
							if not inRange(hrp2) then
								return
							end
							
							event:FireServer({cmd = "pickpocket", target = currentObject})
						end
					end
				end
			end
		end
	end
	
	circleAction.Button.MouseButton1Down:Connect(function()
		ePromptFunc(nil, Enum.UserInputState.Begin, Enum.UserInputType.Touch)
	end)
	circleAction.Button.MouseButton1Up:Connect(function()
		ePromptFunc(nil, Enum.UserInputState.End, Enum.UserInputType.Touch)
	end)
	
	local function show(part, holdText, helpText)
		local vector = camera:WorldToScreenPoint(part.Position)
		circleAction.Position = UDim2.new(0, vector.X, 0, vector.Y)
		circleAction.Hold.Text = holdText or "hold"
		circleAction.Help.Text = helpText or ""
		circleAction.Visible = true
	end
	
	function ePrompt()
		circleAction.Visible = false
		
		if not hrp then return end
		if not hum then return end
		if hum.Health <= 0 then return end
		if hum:GetState() == Enum.HumanoidStateType.Seated then return end
		
		if not vehiclePacket then
			for _, child in next, vehiclesFolder:GetDescendants() do
				if child:IsA("BasePart") then
					if string.lower(child.Name) == "seat" or string.find(string.lower(child.Name), "passenger") then
						local distance = (hrp.Position - child.Position).Magnitude
						if distance <= 7.5 then
							local playerValue = child:FindFirstChild("Player")
							if playerValue then
								if holdingHandcuffs then
									if player.Team == teams.Police then
										show(child, "press", "Eject")
										currentObject = child
										currentRange = 7.5
										action = "eject"
										break
									end
								else
									local helpText = "Driver"
									if string.lower(child.Name) == "seat" then
										helpText = "Driver"
									elseif string.find(string.lower(child.Name), "passenger") then
										helpText = "Passenger"
									end
									show(child, "press", ("Enter %s"):format(helpText))
									
									currentObject = child
									currentRange = 7.5
									action = "enterVehicle"
									break
								end
							end
						end
					end
				end
			end
		end
		
		for _, player2 in next, players:GetPlayers() do
			if player2.Team then
				if player2.Team == teams.Prisoner or player2.Team == teams.Criminal then
					if player.Team == teams.Police then
						local char2 = player2.Character
						if not char2 then return end
						local hum2 = char:FindFirstChildWhichIsA("Humanoid")
						if not hum2 then return end
						if hum2:GetState() == Enum.HumanoidStateType.Seated then return end
						local hrp2 = char2:FindFirstChild("HumanoidRootPart")
						if not hrp2 then return end
						local upperTorso = char2:FindFirstChild("UpperTorso")
						if not upperTorso then return end
						
						local distance = (hrp.Position - hrp2.Position).Magnitude
						if distance > 10 then return end
						
						if not holdingHandcuffs then return end
						if player2:FindFirstChild("Arrested") then return end
						
						show(upperTorso, "hold", "Arrest")
						
						currentObject = player2
						currentRange = 10
						action = "arrest"
						break
					end
				elseif player2.Team == teams.Police then
					if player.Team == teams.Prisoner or player.Team == teams.Criminal then
						local char2 = player2.Character
						if not char2 then return end
						local hum2 = char:FindFirstChildWhichIsA("Humanoid")
						if not hum2 then return end
						if hum2:GetState() == Enum.HumanoidStateType.Seated then return end
						local hrp2 = char2:FindFirstChild("HumanoidRootPart")
						if not hrp2 then return end
						local upperTorso = char2:FindFirstChild("UpperTorso")
						if not upperTorso then return end
						
						local distance = (hrp.Position - hrp2.Position).Magnitude
						if distance > 10 then return end
						
						show(upperTorso, "hold", "Pickpocket")
						
						currentObject = player2
						currentRange = 10
						action = "pickpocket"
						break
					end
				end
			end
		end
	end
end

runService.Stepped:Connect(function(_, dt)
	t = t + dt
	
	if not hum then return end
	if hum.Health <= 0 then return end
	
	local speed = walkSpeed * (hum.Health / hum.MaxHealth)
	speed = math.clamp(speed, 8, sprintingWalkSpeed)
	hum.WalkSpeed = speed
	
	ePrompt()
	
	if hrp and trackAnims.crawl then
		local velocity = hrp.CFrame:VectorToObjectSpace(hrp.Velocity)
		trackAnims.crawl:AdjustSpeed(velocity.Z / 16)
	end
	
	for PlayerName, ItemStack in next, equippedWeapons do
		local Skeleton = ItemStack.Model:FindFirstChild("Skeleton")
		local player2 = players:FindFirstChild(PlayerName)
		if not player2 then return end
		local Character = player2.Character
		if not Character or not Character:FindFirstChild("UpperTorso") then return end
		if Skeleton then
			if ItemStack.FreeBody then
				local leftTarget,rightTarget
				if ItemStack.IK.RightArm then
					rightTarget = Skeleton.RightArm.Position
				end
				if ItemStack.IK.LeftArm then
					leftTarget = Skeleton.LeftArm.Position
				end
				ItemStack.FreeBody:UpdatePositions(leftTarget, rightTarget)
			end
			if ItemStack.IK.RightArm then
				ItemStack.IK.RightArm = Skeleton.RightArm.Position
			end
			if ItemStack.IK.LeftArm then
				ItemStack.IK.LeftArm = Skeleton.LeftArm.Position
			end
			newIKv2.Arms(ItemStack.IK)
			if ItemStack.IK.RightArm then
			end
			if ItemStack.IK.LeftArm then
			end
		end
		local p, v = mathModule.Spring(ItemStack.PosSpring, t)
		local rp, rv = mathModule.Spring(ItemStack.RotSpring, t)
		ItemStack.Motor.C0 = CFrame.new(p) * mathModule.CFrameFromAxisAngle(rp)
		local p, v = mathModule.Spring(ItemStack.WaistSpring, t)
		ItemStack.Waist.C0 = ItemStack.WaistC0 * mathModule.CFrameFromAxisAngle(p)
		local p, v = mathModule.Spring(ItemStack.NeckSpring, t)
		ItemStack.Neck.C0 = CFrame.new(ItemStack.NeckC0.p) * mathModule.CFrameFromAxisAngle(p)
	end
end)

local function replicateVehicleChassis(packet, dt)
	if packet.Type == "Heli" then
		updateHeliLowQuality(packet, dt)
	else
		updateChassisLowQuality(packet, dt)
	end
end

runService.RenderStepped:Connect(function(dt)
	if vehiclePacket and vehicleSeat then
		if vehicleSeat == "Driver" then
			if vehiclePacket.Type == "Heli" then
				heli.Update(vehiclePacket, dt)
			else
				chassis.Update(vehiclePacket, dt)
			end
		end
	end
	for _, packet in next, replicateVehicles do
		if vehiclePacket then
			if vehiclePacket.Model then
				if packet.Model ~= vehiclePacket.Model then
					replicateVehicleChassis(packet, dt)
				end
			else
				replicateVehicleChassis(packet, dt)
			end
		else
			replicateVehicleChassis(packet, dt)
		end
	end
end)

uis.InputBegan:Connect(function(input, processedEvent)
	chassis.InputBegan(input)
	heli.InputBegan(input)
	
	if uis:GetFocusedTextBox() then
		return
	end
	
	if input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.ButtonY then
		ePromptFunc("enterVehicle", Enum.UserInputState.Begin, input)
	end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR2 then
		MouseButton1Down = true
	end
	
	local k = input.KeyCode
	local kv = k.Value
	if kv >= 49 and kv <= 57 then
		local i = kv - 49 + 1
		AttemptHotbarSelect(i)
	elseif k == Enum.KeyCode.R or k == Enum.KeyCode.ButtonX then
		local ItemStack = equippedWeapons[player.Name]
		if ItemStack then
			GunReload(ItemStack, ItemStack.ReloadTime)
		end
	elseif k == Enum.KeyCode.ButtonL1 then
		LastHotbarIndex = LastHotbarIndex - 1
		if LastHotbarIndex < 0 then
			LastHotbarIndex = 0
			Unequip()
		elseif LastHotbarIndex > #Inventory.ItemStacks then
			LastHotbarIndex = #Inventory.ItemStacks + 1
			Unequip()
		else
			AttemptHotbarSelect(LastHotbarIndex)
		end
	elseif k == Enum.KeyCode.ButtonR1 then
		LastHotbarIndex = LastHotbarIndex + 1
		if LastHotbarIndex < 0 then
			LastHotbarIndex = 0
			Unequip()
		elseif LastHotbarIndex > #Inventory.ItemStacks then
			LastHotbarIndex = #Inventory.ItemStacks + 1
			Unequip()
		else
			AttemptHotbarSelect(LastHotbarIndex)
		end
	elseif k == Enum.KeyCode.ButtonR2 or input.UserInputType == Enum.UserInputType.MouseButton1 then
		local ItemStack = equippedWeapons[player.Name]
		if ItemStack then
			local ViewportSize = camera.ViewportSize
			MouseButton1Down = true
			MB1(ItemStack, true)
		end
	end
end)

uis.InputEnded:Connect(function(input, processedEvent)
	chassis.InputEnded(input)
	heli.InputEnded(input)
	
	if uis:GetFocusedTextBox() then
		return
	end
	
	if input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.ButtonY then
		ePromptFunc("enterVehicle", Enum.UserInputState.End, input)
	end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR2 then
		MouseButton1Down = false
	end
end)

uis.InputChanged:Connect(function(input, processedEvent)
	chassis.InputChanged(input)
	heli.InputChanged(input)
	inputPosition = input.Position
end)

uis.TouchStarted:Connect(function(touch, processedEvent)
	if processedEvent then
		return
	end
	inputPosition = touch.Position
	local posx = touch.Position.x
	local posy = touch.Position.y
	local itemStack = equippedWeapons[player.Name]
	if itemStack then
		local ViewportSize = camera.ViewportSize
		MouseButton1Down = true
		MB1(itemStack, false)
	end
end)

uis.TouchMoved:Connect(function(touch, processedEvent)
	inputPosition = touch.Position
	MouseButton1Down = false
end)

uis.JumpRequest:Connect(function()
	if not vehiclePacket then return end
	event:FireServer({cmd = "leaveVehicle"})
end)

do
	switchTeams()
	
	local function updateSchedule()
		local timeNow = lighting.TimeOfDay
		timeNow = string.sub(timeNow, 1, string.len(timeNow) - 3)
		if string.sub(timeNow, 1, 1) == "0" then
			timeNow = string.sub(timeNow, 2, string.len(timeNow))
		end
		
		local timeStamp = "AM"
		if timeValue.Value >= 0 and timeValue.Value < 12 then
			timeStamp = "AM"
		else
			timeStamp = "PM"
		end
		
		local schedule = "Breakfast"
		if timeValue.Value >= 6 and timeValue.Value < 9 then
			schedule = "Breakfast"
		elseif timeValue.Value >= 9 and timeValue.Value < 12 then
			schedule = "Yard"
		elseif timeValue.Value >= 12 and timeValue.Value < 16 then
			schedule = "Free"
		elseif timeValue.Value >= 16 and timeValue.Value < 20 then
			schedule = "Dinner"
		elseif timeValue.Value >= 20 or timeValue.Value > 0 and timeValue.Value < 6 then
			schedule = "Cells"
		end
		
		currentSchedule = schedule
		guis.ScreenGui.Schedule.Text = ("%s %s    Schedule: %s"):format(timeNow, timeStamp, schedule)
	end
	updateSchedule()
	timeValue:GetPropertyChangedSignal("Value"):Connect(updateSchedule)
end

do
	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Event:Connect(function()
		event:FireServer({cmd = "resetAttempt"})
	end)
	local s, e = pcall(function()
		starterGui:SetCore("ResetButtonCallback", bindableEvent)
	end)
	if not s then
		warn(e)
	end
end