local builder = {}
local replicatedStorage = game:GetService("ReplicatedStorage")
local module = replicatedStorage:WaitForChild("Module")
local joint = require(module:WaitForChild("Joint"))

local resource = replicatedStorage:WaitForChild("Resource")
local ssettings = require(resource:WaitForChild("Settings"))

local soundService = game:GetService("SoundService")

function builder.EquipRim(model, newRim)
	for _, parent in pairs({model, model:FindFirstChild("Preset")}) do
		for _, v in pairs(parent:GetChildren()) do
			if string.find(string.lower(v.Name), "wheel") then
				if v:FindFirstChild("Rim") then
					v.Rim:Destroy()
				end
				local rim = newRim:Clone()
				rim.Parent = v
				rim.Name = "Rim"
				local rimRad = v.Wheel.Size.Z * (rim.Size.Z / resource.Wheel.Size.Z)
				local rimWidth = v.Wheel.Size.X * (rim.Size.X / resource.Wheel.Size.X)
				rim.CFrame = rim.CFrame * CFrame.Angles(0, math.rad(180), 0)
				rim.Size = Vector3.new(rimWidth, rimRad, rimRad)
				v.Wheel.Anchored = false
				rim.Anchored = false
				rim.CanCollide = false
				v.Wheel.CanCollide = false
				local rimWeld = joint.BlankWeld(v.Wheel, rim)
				rimWeld.C1 = (CFrame.new(v.Wheel.Size.X/2 - rim.Size.X/2 + 0.001, 0, 0) + Vector3.new(-v.Wheel.Size.X + 0.25, 0, 0)) * CFrame.Angles(0, math.pi * 2, 0)
			end
		end
	end
end

function builder.BuildChassis(model)
	local body
	if model.Make.Value == "Chassis" or model.Make.Value == "Model3" then
		body = model.Model.Body
	else
		body = model.Model.Body
	end
	
	local Engine = model:FindFirstChild("Engine")
	if not Engine then
		Engine = Instance.new("Part")
		Engine.Parent = model
		Engine.CanCollide = false
		Engine.CFrame = body.CFrame
		Engine.Size = Vector3.new(6, 1, math.floor(body.Size.Z) - 4)
		Engine.Name = "Engine"
		Engine.Transparency = 1
		Engine.CFrame = Engine.CFrame * CFrame.Angles(0, math.rad(180), 0)
		joint.WeldAllTo(model.Model, Engine, true)
		local Bounding = Instance.new("Part")
		Bounding.Parent = model
		Bounding.Name = "BoundingBox"
		Bounding.CFrame = Engine.CFrame
		Bounding.Size = model:GetExtentsSize()
		Bounding.CanCollide = false
		Bounding.Transparency = 1
		local Weight = Bounding:Clone()
		Bounding.Name = "Weight"
		Bounding.CFrame = Engine.CFrame - Vector3.new(0, 1, 0)
		Bounding.Size = model.Model:GetExtentsSize()
		local Nitrous = Instance.new("Part", model)
		Nitrous.Name = "Nitrous"
		Nitrous.Size = Vector3.new(0.5, 0.5, 0.5)
		Nitrous.CanCollide = false
		Nitrous.Transparency = 1
		Nitrous.CFrame = Engine.CFrame + -Engine.CFrame.lookVector * Engine.Size.Z/2
		
		local mass = 0
		for _, child in next, model:GetDescendants() do
			if child:IsA("BasePart") then
				mass = mass + child:GetMass()
			end
		end
		
		local driveThrust = Instance.new("BodyThrust", Engine)
		driveThrust.Name = "BodyThrust"
		driveThrust.Force = Vector3.new()
		driveThrust.Location = Vector3.new()
		local bf = Instance.new("BodyForce", Engine)
		bf.Name = "BodyForce"
		local bodyGyro = Instance.new("BodyGyro", Engine)
		bodyGyro.Name = "Flip"
		bodyGyro.MaxTorque = Vector3.new()
		local angularVelocity = Instance.new("BodyAngularVelocity", Engine)
		angularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
		angularVelocity.MaxTorque = Vector3.new(mass, math.huge, mass)
		
		for _, v in ipairs(script:GetChildren()) do
			v:Clone().Parent = Engine
		end
		
		local preset = model:FindFirstChild("Preset")
		local children = preset and preset:GetChildren() or model:GetChildren()
		for _, v in ipairs(children) do
			if string.find(string.lower(v.Name), "wheel") then
				local Thruster = Instance.new("Part", model)
				Thruster.CFrame = CFrame.new(Vector3.new(v.Wheel.CFrame.p.X, Engine.CFrame.p.Y, v.Wheel.CFrame.p.Z)) * (Engine.CFrame-Engine.CFrame.p)
				Thruster.CanCollide = false
				Thruster.Size = Vector3.new(1, 1, 1)
				local namething = (string.find(v.Name, "Front") and "F" or "R") .. (string.find(v.Name, "Right") and "R" or "L")
				Thruster.Name = "Thrust" .. namething
				Thruster.Transparency = 1
				Thruster.Parent = model
				local thrust = Instance.new("BodyThrust", Thruster)
				thrust.Name = "BodyThrust"
				if not string.find(v.Name, "Front") then
					local name = "Drift" .. (string.find(v.Name, "Right") and "R" or "L")
					local part = Thruster:Clone()
					part.Parent = model
					part.Name = name
					part.CFrame = part.CFrame - Vector3.new(0, 3, 0)
					local particle = resource.DriftParticle:Clone()
					particle.Parent = part
					particle.Name = "ParticleEmitter"
					local w = joint.Weld(part, Thruster)
					w.Name = "Drift"
					w.Parent = Thruster
				end
				local m = joint.Motor(v.Wheel, Thruster)
				m.C1 = m.C0:inverse()
				m.C0 = CFrame.new()
				m.Parent = Thruster
			end
		end
		
		for _, v in ipairs(model.Model:GetChildren()) do
			if v.Name == "Headlights" then
				local l = script.Headlight:Clone()
				l.Parent = v
				l.Name = "SpotLight"
				if model.Name == "Model3" or model.Name == "SWATVan" then
					l.Face = Enum.NormalId.Front
				end
			elseif v.Name == "Brakelights" then
				local l = script.Brakelight:Clone()
				l.Parent = v
				l.Name = "SpotLight"
				if model.Name == "Model3" or model.Name == "SWATVan" then
					l.Face = Enum.NormalId.Back
				end
			end
		end
	end
	
	if not model:FindFirstChild("Camera") then
		local Camera = Instance.new("Part")
		Camera.Parent = model
		Camera.CanCollide = false
		Camera.CFrame = Engine.CFrame + Vector3.new(0, 4, 0)
		Camera.Size = Vector3.new(2, 2, 2)
		Camera.Name = "Camera"
		Camera.Transparency = 1
	end
	
	local soundGroup = soundService:FindFirstChild(model.Make.Value)
	local hornSound = Instance.new("Sound")
	hornSound.Name = "Horn"
	hornSound.SoundId = "rbxassetid://" .. ssettings.Sounds.Horn
	hornSound.Volume = 1
	hornSound.Looped = true
	hornSound.Parent = Engine
	hornSound.SoundGroup = soundGroup ~= nil and soundGroup or nil
	
	if not model.PrimaryPart then
		model.PrimaryPart = Engine
	end
	
	if model.Make.Value == "Heli" then
		for _, child in next, model:GetDescendants() do
			if child:IsA("BasePart") then
				joint.Weld(child, Engine)
				child.Anchored = false
			end
		end
	else
		joint.WeldAllTo(model, Engine, true)
		for _, v in pairs({model:FindFirstChild("Preset") and model:FindFirstChild("Preset"):GetChildren() or model:GetChildren()}) do
			if v.Name == "Steer" then
				joint.Weld(v, Engine)
				v.Anchored = false
			end
 		end
	end
	
	local vehicleColor = ssettings.VehicleDefaultColors[model.Name]
	if type(vehicleColor) == "table" then
		vehicleColor = vehicleColor[math.random(1, #vehicleColor)]
	end
	body.Color = vehicleColor
	
	local windows = model:FindFirstChild("Windows") or model.Model:FindFirstChild("Windows")
	if windows then
		windows.Color = ssettings.Colors.Blacker.Color
	end
	
	if model.Make.Value ~= "Heli" then
		local headlights = model.Model:FindFirstChild("Headlights")
		if headlights then
			headlights.Color = ssettings.Colors.White.Color
		end
		
		builder.EquipRim(model, resource.Rims.Rim)
	end
end

return builder