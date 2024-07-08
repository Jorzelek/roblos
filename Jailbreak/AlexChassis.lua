local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.Module.Audio)
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local AlexInput = require(ReplicatedStorage.Module.AlexInput)
local UI = require(ReplicatedStorage.Module.UI)
local RunService = game:GetService("RunService")
local IsStudio = RunService:IsStudio()
local Joint = require(ReplicatedStorage.Module.Joint)
local HapticService = game:GetService("HapticService")
local CurrentCamera = workspace.CurrentCamera
local IKR15 = require(ReplicatedStorage.Module.R15IKv2)
local Region = require(ReplicatedStorage.Module.Region)
local Settings = require(ReplicatedStorage.Resource.Settings)
local ChassisShared = require(ReplicatedStorage.Module.ChassisShared)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local GetMoveVector
function GetMoveVector()
	return Vector3.new()
end
do
	local ControlModule = LocalPlayer.PlayerScripts:WaitForChild("PlayerModule", 5).ControlModule
	if ControlModule then
		ControlModule = require(ControlModule)
		function GetMoveVector()
			return ControlModule:GetMoveVector()
		end
	end
end
local cf, v3, cfa = CFrame.new, Vector3.new, CFrame.Angles
local cfb, v3b, v3d = cf(0, 0, 0), v3(0, 0, 0), v3(0, -1, 0)
local RayNew = Ray.new
local fpor = workspace.FindPartOnRay
local fporwil = workspace.FindPartOnRayWithIgnoreList
local min, max, abs, tanh = math.min, math.max, math.abs, math.tanh
local exp = math.exp
local tos, vtos, vtws = cfb.toObjectSpace, cfb.vectorToObjectSpace, cfb.vectorToWorldSpace
local Event
local function RayCast(Origin, Direction, IgnoreList)
	local Length = Direction.magnitude
	Direction = Direction.unit
	local Position = Origin
	local Traveled = 0
	local Ignored = {IgnoreList}
	local h, p, normal = nil, v3b, v3b
	local Attempts = 0
	local CanCollide
	repeat
		Attempts = Attempts + 1
		local r = RayNew(Position, Direction * (Length - Traveled))
		h, p, normal = fporwil(workspace, r, Ignored, false, true)
		CanCollide = h and h.CanCollide
		if not CanCollide then
			table.insert(Ignored, h)
		end
		Traveled = (Origin - p).magnitude
		Position = p
	until CanCollide or Length - Traveled <= 0.001 or Attempts > 4
	if not h then
		p, normal = Origin + Direction * Length, v3d
	end
	return h, p, normal
end
local function SmartCast(Origin, Direction, IgnoreList)
	local Length = Direction.magnitude
	Direction = Direction.unit
	local IgnoreListIsTable = type(IgnoreList) == "table"
	local Ignored = IgnoreListIsTable and {
		IgnoreList,
		nil,
		nil
	} or IgnoreList
	local IgnoreIndex = IgnoreListIsTable and 1 or 0
	local Position = Origin
	local Traveled = 0
	local h, p, normal, mat
	local r = RayNew(Position, Direction * Length)
	if IgnoreListIsTable then
		h, p, normal, mat = fporwil(workspace, r, Ignored, false, true)
	else
		h, p, normal, mat = fpor(workspace, r, Ignored, false, true)
	end
	if h and h.CanCollide then
		return h, p, normal, mat
	end
	Traveled = (Origin - p).magnitude
	if not IgnoreListIsTable then
		Ignored = {
			IgnoreList,
			h,
			nil
		}
		IgnoreListIsTable = true
	else
		IgnoreIndex = IgnoreIndex + 1
		Ignored[IgnoreIndex] = h
	end
	Position = p
	local r = RayNew(Position, Direction * (Length - Traveled))
	if IgnoreListIsTable then
		h, p, normal, mat = fporwil(workspace, r, Ignored, false, true)
	else
		h, p, normal, mat = fpor(workspace, r, Ignored, false, true)
	end
	if h and h.CanCollide then
		return h, p, normal, mat
	end
	Traveled = (Origin - p).magnitude
	IgnoreIndex = IgnoreIndex + 1
	Ignored[IgnoreIndex] = h
	Position = p
	local r = RayNew(Position, Direction * (Length - Traveled))
	if IgnoreListIsTable then
		h, p, normal, mat = fporwil(workspace, r, Ignored, false, true)
	else
		h, p, normal, mat = fpor(workspace, r, Ignored, false, true)
	end
	if h and h.CanCollide then
		return h, p, normal, mat
	end
	return nil, Origin + Direction * Length, normal, mat
end
local SoundEffects = {
	Echo = SoundService.Chassis.EchoSoundEffect,
	Equalizer = SoundService.Chassis.EqualizerSoundEffect,
	Reverb = SoundService.Chassis.ReverbSoundEffect
}
local SoundOptions = {
	Echo = {
		"Delay",
		"DryLevel",
		"Feedback",
		"WetLevel"
	},
	Equalizer = {
		"HighGain",
		"LowGain",
		"MidGain"
	},
	Reverb = {
		"DecayTime",
		"Density",
		"Diffusion",
		"DryLevel",
		"WetLevel"
	}
}
local SoundValues = {
	Tunnel = {
		Echo = {
			Delay = 0.35,
			DryLevel = 0,
			Feedback = 0,
			WetLevel = -27
		},
		Equalizer = {
			HighGain = 0,
			LowGain = -2.5,
			MidGain = -2.5
		},
		Reverb = {
			DecayTime = 3.5,
			Density = 1,
			Diffusion = 0.6,
			DryLevel = 4,
			WetLevel = 0
		}
	},
	Outside = {
		Echo = {
			Delay = 1.5,
			DryLevel = 0,
			Feedback = 0,
			WetLevel = -42.2
		},
		Equalizer = {
			HighGain = 0,
			LowGain = 0,
			MidGain = 0
		},
		Reverb = {
			DecayTime = 10,
			Density = 1,
			Diffusion = 1,
			DryLevel = 0,
			WetLevel = -35
		}
	},
	City = {
		Echo = {
			Delay = 0.198,
			DryLevel = 0,
			Feedback = 0,
			WetLevel = -9.8
		},
		Equalizer = {
			HighGain = 0,
			LowGain = -8,
			MidGain = 0
		},
		Reverb = {
			DecayTime = 4.6,
			Density = 1,
			Diffusion = 0.6,
			DryLevel = 0,
			WetLevel = -28
		}
	}
}
local Transition = 0
local SetRPMRaw
do
	local f = function(a, b, c)
		return math.exp(-(a - b) ^ 2 / (2 * c * c))
	end
	local function SetRPM3(Sounds, RPM, Throttle, Make)
		local Mult = 0.8
		local IdleSpeed, OnLowSpeed, OnMidSpeed, OnHighSpeed, OffLowSpeed
		local IdleMult = 1
		if Make == "Lamborghini" or Make == "Bugatti" or Make == "Revuelto" then
			Mult = 0.6
			if RPM < 6000 then
				IdleSpeed = (RPM + 2000) / 5500 + 0.8
				OnLowSpeed = RPM / 12000 + 0.5 + 0.07 - 0.1
				IdleMult = 0.5
			end
			OnMidSpeed = 1 + RPM / 12000 - 0.5 + 0.07 - 0.1
			OnHighSpeed = 1 + RPM / 12000 - 0.3 + 0.25 - 0.1
			OffLowSpeed = RPM / 12000 + 0.6 + 0.1 - 0.1
		else
			if RPM < 6000 then
				IdleSpeed = (RPM + 1000) / 6000
				OnLowSpeed = RPM / 10000 + 0.2
			end
			OnMidSpeed = 1 + RPM / 10000 - 0.7
			OnHighSpeed = 1 + RPM / 10000 - 1
			OffLowSpeed = RPM / 10000 + 0.2
		end
		if IdleSpeed then
			Sounds.Idle.PlaybackSpeed = IdleSpeed
		end
		if OnLowSpeed then
			Sounds.OnLow.PlaybackSpeed = OnLowSpeed
		end
		Sounds.OnMid.PlaybackSpeed = OnMidSpeed
		Sounds.OnHigh.PlaybackSpeed = OnHighSpeed
		Sounds.OffLow.PlaybackSpeed = OffLowSpeed
		local Ratio = RPM / 8000
		local IdleVolume = f(-0.1, Ratio, 0.2) * Mult * IdleMult
		local OnLowVolume = f(0.3, Ratio, 0.1) * Mult
		local OnMidVolume = f(0.6, Ratio, 0.2) * Mult
		local OnHighVolume = f(0.9, Ratio, 0.15) * Mult
		Sounds.Idle.Volume = IdleVolume
		if Throttle > 0 then
			Sounds.OnLow.Volume = OnLowVolume
			Sounds.OnMid.Volume = OnMidVolume
			Sounds.OnHigh.Volume = OnHighVolume
			Sounds.OffLow.Volume = 0
		else
			Sounds.OnLow.Volume = OnLowVolume * 0.5
			Sounds.OnMid.Volume = OnMidVolume * 1
			Sounds.OnHigh.Volume = OnHighVolume * 1
			Sounds.OffLow.Volume = OnLowVolume * 0.5
		end
	end
	local function SetRPM1(Sounds, RPM, Throttle, Make)
		local Mult = 0.5
		local Ratio = RPM / (Make == "Volt" and 10000 or 6000)
		Sounds.Idle.PlaybackSpeed = (RPM + 3000) / 8000
		local Q86f05955 = f(1.1, Ratio, 0.5) * Mult
		Sounds.Idle.Volume = Q86f05955
	end
	function SetRPMRaw(Make, Sounds, RPM, Throttle)
		if Make == "Model3" or Make == "Volt" then
			SetRPM1(Sounds, RPM, Throttle, Make)
		else
			SetRPM3(Sounds, RPM, Throttle, Make)
		end
	end
end
local function UpdateGearsAndRPM(p, Gears, Speed, Throttle, dt)
	local Gear, LastGear, t3, LastRPM = p.Gear, p.LastGear, p.t3, p.LastRPM
	local EngineSpeed = Speed / (p.Model.WheelBackRight.Wheel.Size.Y / 2.9) * 1000 / 3600 / 0.34
	local GearRatio = LastGear * (1 - t3) + Gear * t3
	if LastGear ~= Gear then
		GearRatio = Gears[2 + LastGear] * (1 - t3 * t3) + Gears[2 + Gear] * t3 * t3
		t3 = t3 + dt * 1 / 0.26
		p.t3 = t3
		if t3 >= 1 then
			p.LastGear = Gear
			p.t3 = 0
		end
	else
		GearRatio = Gears[2 + Gear]
	end
	local RPM = EngineSpeed * Gears[1] * GearRatio * 60 / (2 * math.pi)
	local FullRPM = EngineSpeed * Gears[1] * Gears[2 + Gear] * 60 / (2 * math.pi)
	local ChangeIn = FullRPM - LastRPM
	if not p.NoGears then
		if Throttle > 0 and ChangeIn > 0 and FullRPM > 6000 and Gear < 6 then
			p.Gear = Gear + 1
		elseif ChangeIn < 0 and FullRPM < 3400 and Gear > 1 then
			p.Gear = Gear - 1
		end
	end
	SetRPMRaw(p.Make, p.Sounds, RPM, Throttle)
	p.LastRPM = FullRPM
	return Gear, GearRatio
end
local m = {}
local WASDQE = {
	0,
	0,
	0,
	0,
	0,
	0
}
local ShouldDrift, Lights, ShouldBrake, Autopilot = false, false, false, false
local Sirens = false
local function GetMass(Model)
	local Mass = 0
	for _, v in next, Model:GetChildren() do
		if v:IsA("BasePart") then
			local m = v:GetMass()
			if v.CustomPhysicalProperties then
				local Density = v.CustomPhysicalProperties.Density
				if Density ~= Density then
					Density = 0
				end
				m = m * Density
			end
			Mass = Mass + m
		end
		Mass = Mass + GetMass(v)
	end
	return Mass
end
local SetHumanoidEnabled = function(Character, Enabled)
	for _, State in next, Enum.HumanoidStateType:GetEnumItems() do
		if State ~= Enum.HumanoidStateType.Dead and State ~= Enum.HumanoidStateType.None and State ~= Enum.HumanoidStateType.Jumping then
			Character.Humanoid:SetStateEnabled(State, Enabled)
		end
	end
end
local function OnAction(b, State, i)
	local Name = b.Name
	if State then
		if Name == "Drift" then
			ShouldDrift = true
			ChassisShared.HandBrake = true
		elseif Name == "Lights" then
			Lights = not Lights
			Event:FireServer("OnAction", "Lights", Lights)
		elseif Name == "Sirens" then
			Sirens = not Sirens
			Event:FireServer("OnAction", "PoliceLights", Sirens)
		elseif Name == "Brake" then
			ShouldBrake = not ShouldBrake
		elseif Name == "Forward" then
			WASDQE[1] = 1
		elseif Name == "Backward" then
			WASDQE[3] = 1
		elseif Name == "Autopilot" then
			Autopilot = not Autopilot
		elseif Name == "Action" then
			if ChassisShared.VehicleMake == "Firetruck" then
				Event:FireServer("OnAction", "FiretruckWater", true)
			else
				Event:FireServer("OnAction", "Action")
			end
		end
	elseif Name == "Drift" then
		ShouldDrift = false
		ChassisShared.HandBrake = false
	elseif Name == "Forward" then
		WASDQE[1] = 0
	elseif Name == "Backward" then
		WASDQE[3] = 0
	elseif Name == "Action" and ChassisShared.VehicleMake == "Firetruck" then
		Event:FireServer("OnAction", "FiretruckWater", false)
	end
end
m.OnAction = OnAction
function m.SetGravity(p, Gravity)
	local Mass = p.Mass
	local Force = 1 - Gravity / 196.20000000000002
	if Mass ~= Mass then
		Mass = 0
	end
	if Force ~= Force then
		Force = 0
	end
	p.Lift.Force = v3(0, Mass * Force, 0)
end
function m.UpdateStats(p)
	local Character = LocalPlayer.Character
	local Model = p.Model
	local Suspension = p.Suspension
	if Suspension ~= Suspension then
		Suspension = 4
	end
	local Bounce = p.Bounce
	if Bounce ~= Bounce then
		Bounce = 100
	end
	local Mass = (GetMass(Model) + GetMass(Character)) * 9.81 * 20
	if Mass ~= Mass then
		Mass = 1
	end
	local Force = Mass * Suspension
	if Force ~= Force then
		Force = 0
	end
	local Damping = Force / Bounce
	if Damping ~= Damping then
		Damping = 0
	end
	p.Mass, p.Force, p.Damping = Mass, Force, Damping
	m.SetGravity(p, 100)
end
function m.VehicleEnter(p)
	local IsPassenger = p.Passenger
	local Character = LocalPlayer.Character
	SetHumanoidEnabled(Character, false)
	if p.Make == "ATV" or p.Make == "Volt" then
		p.NoLook = true
		Character.Humanoid:ChangeState(Enum.HumanoidStateType.Seated)
	elseif p.Seat:FindFirstChild("Turret") then
		Character.Humanoid.Sit = true
		Character.Humanoid:ChangeState(Enum.HumanoidStateType.Seated)
		delay(0.1, function()
			for _, Track in next, Character.Humanoid:GetPlayingAnimationTracks() do
				Track:Stop()
			end
			local Idle = Character.Humanoid:LoadAnimation(Character.Animate.idle.Animation1)
			Idle:Play(0)
		end)
	else
		Character.Humanoid:ChangeState(Enum.HumanoidStateType.Seated)
	end
	local Model = p.Model
	CurrentCamera.CameraSubject = Model.Camera
	if not p.Seat:FindFirstChild("Visible") then
		local Head = Character:FindFirstChild("Head")
		if Head and Head:FindFirstChild("face") then
			Head.face.Transparency = 1
		end
	end
	ChassisShared.VehicleMake = p.Make
	if IsPassenger then
		return
	end
	WASDQE = {
		0,
		0,
		0,
		0,
		0,
		0
	}
	ShouldDrift, ShouldBrake = false, false
	ChassisShared.HandBrake = false
	Autopilot = false
	local Engine = Model.Engine
	Sirens = p.PoliceLights
	m.UpdateStats(p)
	local Rotate = Instance.new("BodyAngularVelocity")
	Rotate.AngularVelocity = v3b
	Rotate.MaxTorque = v3(p.Mass, math.huge, p.Mass)
	Rotate.Parent = Engine
	p.Rotate = Rotate
	p.Traction = 1
	p.LastForward = 0
	p.RotY = 0
	p.WheelRotation = 0
	p.LastDrift = 0
	p.vHeading = 0
	p.vGrass = 0
	p.vAsphalt = 0
	p.vSandstone = 0
	p.Gear = 1
	p.LastGear = 1
	p.LastRPM = 0
	p.t3 = 0
	if p.Make ~= "Volt" then
		local IKR = IKR15.BuildPacketArms(Character)
		p.IK = IKR
	end
	p.Sounds.DriftSqueal.Volume = 0
	for _, Sound in next, p.Sounds, nil do
		if not Sound.IsPlaying then
			Sound:Play()
		end
	end
end
function m.VehicleLeave(p)
	local IsPassenger = p.Passenger
	local Character = LocalPlayer.Character
	if Character then
		CurrentCamera.CameraSubject = Character:FindFirstChild("Humanoid")
		local Head = Character:FindFirstChild("Head")
		if Head and Head:FindFirstChild("face") then
			Head.face.Transparency = 0
		end
	end
	CurrentCamera.FieldOfView = 70
	if p.Sounds then
		local Outside = SoundValues.Outside
		for Effect, Options in next, SoundOptions, nil do
			for _, Option in next, Options, nil do
				local Value = Outside[Effect][Option]
				SoundEffects[Effect][Option] = Value
			end
		end
		for _, Sound in next, p.Sounds, nil do
			Sound.Volume = 0
		end
		p.Sounds.DriftSqueal:Stop()
	end
	if Character then
		SetHumanoidEnabled(Character, true)
		Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		local RootPart = Character:FindFirstChild("HumanoidRootPart")
		if RootPart then
			local BoundingBox = p.Model and p.Model:FindFirstChild("BoundingBox")
			if BoundingBox then
				RootPart.CFrame = cf(BoundingBox.Position) + v3(0, BoundingBox.Size.Y * 0.5 + 5, 0)
			end
		end
	end
	if IsPassenger then
		return
	end
	p.Rotate:Destroy()
	p.DriveThruster.Force = v3b
	for _, Wheel in next, p.Wheels, nil do
		Wheel.Thruster.Force = v3b
	end
end
function m.UpdateWheelLowQuality(Model, Height, Thruster, WheelRotation)
	local Engine = Model.Engine
	local EngineCF = Engine.CFrame
	local ThrusterCF = Thruster.CFrame
	local Thrusterp = ThrusterCF.p
	local ThrusterVel = Thruster.Velocity
	local Motor = Thruster.Motor
	local _, p = SmartCast(Thrusterp, vtws(ThrusterCF, v3d) * Height, workspace.Vehicles, "lq")
	local CurrentHeight = (p - Thrusterp).magnitude
	local WheelOffset = cf(0, -min(CurrentHeight, Height) + Motor.Part0.Size.Y * 0.5, 0)
	local RelativePos = ThrusterCF:toObjectSpace(EngineCF)
	if 0 < RelativePos.Z then
		WheelOffset = WheelOffset * cfa(0, Engine.RotVelocity.Y * 0.5, 0)
	end
	WheelOffset = WheelOffset * cfa(WheelRotation, 0, 0)
	Motor.C1 = WheelOffset
end
function m.UpdateSoundLowQuality(p, Gears, Velocity)
	UpdateGearsAndRPM(p, Gears, Velocity.magnitude, -Velocity.Z, 0.016666666666666666)
end
local IsNaN = function(n)
	return n ~= n
end
local S7ac3b = {
	ATV = {k = 1.5, B = 20},
	Default = {k = 1.5, B = 3.5}
}
local function of531096aa8(Y02bbe67e9c, C0085399ad3, c4b6bf3)
	local Tafb482b8 = C0085399ad3.Part
	local B9bac18647 = Y02bbe67e9c.Model
	local Z184a95f3386 = B9bac18647.Engine
	local O90a1947c132 = Z184a95f3386.CFrame
	local Jba3b7e5c = Tafb482b8.CFrame
	local r1b9f72a1 = Jba3b7e5c.p
	local a59168d9a9c = Tafb482b8.Velocity
	local hd232c9c2 = Tafb482b8.Motor
	local Fbb8a8071a58 = C0085399ad3.Thruster
	local qe8ae1b = Y02bbe67e9c.Mass
	local N91c3efc7 = Y02bbe67e9c.Force
	local A5ab93cb = tos(Jba3b7e5c, O90a1947c132)
	local o71dd3 = vtos(Jba3b7e5c, a59168d9a9c)
	local T22ee79c8 = Y02bbe67e9c.Height + Y02bbe67e9c.GarageSuspensionHeight
	local hb0caf1d, M8861d = SmartCast(r1b9f72a1, vtws(Jba3b7e5c, v3d) * T22ee79c8, workspace.Vehicles)
	local q434394f4f = (M8861d - r1b9f72a1).Magnitude
	local Aee7543c = -min(q434394f4f, T22ee79c8) + hd232c9c2.Part0.Size.Y * 0.5
	local I6c4accef = hd232c9c2.C1.Y
	local f962ba9437bb = cf(0, I6c4accef + (Aee7543c - I6c4accef) * 0.5, 0)
	if 0 < A5ab93cb.Z then
		f962ba9437bb = f962ba9437bb * cfa(0, Y02bbe67e9c.RotY * 0.4 + Z184a95f3386.RotVelocity.Y * 0.2, 0)
	elseif hb0caf1d and (ShouldDrift or Y02bbe67e9c.Drift) then
		local P74671b5 = Tafb482b8.Drift
		local d2b1981 = P74671b5.Part0.ParticleEmitter
		d2b1981:Emit(2)
	end
	f962ba9437bb = f962ba9437bb * cfa(Y02bbe67e9c.WheelRotation, 0, 0)
	if f962ba9437bb.x ~= f962ba9437bb.x or f962ba9437bb.y ~= f962ba9437bb.y or f962ba9437bb.z ~= f962ba9437bb.z or abs(f962ba9437bb.x + f962ba9437bb.y + f962ba9437bb.z) > 100 then
		f962ba9437bb = cfb
	end
	hd232c9c2.C1 = f962ba9437bb
	if hb0caf1d then
		local f9ac023cd = o71dd3 * Y02bbe67e9c.Damping
		local Ld05fe920a, t1eee16 = qe8ae1b * 0.5, -qe8ae1b * 0.5
		local Ifeb392 = (T22ee79c8 - min(q434394f4f, T22ee79c8)) ^ 2 * (N91c3efc7 / T22ee79c8 ^ 2)
		if o71dd3.magnitude > 0.01 then
			Ifeb392 = Ifeb392 - f9ac023cd.Y
		end
		if Ifeb392 ~= Ifeb392 then
			Ifeb392 = 0
		end
		Ifeb392 = Ld05fe920a < Ifeb392 and Ld05fe920a or t1eee16 > Ifeb392 and t1eee16 or Ifeb392
		local Ob471f3 = 1
		if c4b6bf3 <= 0.025 then
			Ob471f3 = 0.016666666666666666 / c4b6bf3
		end
		if Ob471f3 ~= Ob471f3 then
			Ob471f3 = 0
		end
		Ob471f3 = math.clamp(Ob471f3, 0, 1)
		Fbb8a8071a58.Force = v3(0, Ifeb392 * Ob471f3, 0)
	else
		Fbb8a8071a58.Force = v3b
	end
end
local G7cdff4e7d30 = cfb.vectorToObjectSpace
local wda2d6a74c = function(eed957105c88, R17f9fca7, Ie70b946aa1)
	if eed957105c88 then
		local D9c9c29aa, d13b48dd = nil, -99
		for I141e46a, T37b02 in next, {
			Enum.NormalId.Front,
			Enum.NormalId.Back
		}, nil do
			local Ha1e921e56f8 = eed957105c88.CFrame:vectorToWorldSpace(Vector3.FromNormalId(T37b02))
			local X601ad1 = R17f9fca7.lookVector:Dot(Ha1e921e56f8)
			if d13b48dd < X601ad1 then
				d13b48dd = X601ad1
				D9c9c29aa = Ha1e921e56f8
			end
		end
		local Sf30fb3a47c6 = eed957105c88.Position + D9c9c29aa * (R17f9fca7.p - eed957105c88.Position):Dot(D9c9c29aa) + D9c9c29aa * -Ie70b946aa1.Z
		local h217061f = (Sf30fb3a47c6 - R17f9fca7.p).unit
		return h217061f
	end
	return false
end
local function BetterCast(Origin, Direction, IgnoreList)
	local Length = Direction.magnitude
	Direction = Direction.unit
	local Position = Origin
	local Traveled = 0
	local Ignored = {IgnoreList}
	local h, p, normal = nil, v3b, v3b
	local Attempts = 0
	local CanCollide
	repeat
		Attempts = Attempts + 1
		local r = RayNew(Position, Direction * (Length - Traveled))
		h, p, normal = fporwil(workspace, r, Ignored, false, true)
		CanCollide = h and h.CanCollide and h.Material == Enum.Material.Concrete
		if not CanCollide then
			table.insert(Ignored, h)
		end
		Traveled = (Origin - p).magnitude
		Position = p
	until CanCollide or Length - Traveled <= 0.001 or Attempts > 4
	if not h then
		p, normal = Origin + Direction * Length, v3d
	end
	return h, p, normal
end
local I33abb = v3b
local z75f465230b = {
	Model3 = "Model3",
	Camaro = "Camaro",
	Lamborghini = "Lamborghini",
	Bugatti = "Bugatti",
	Torpedo = "Torpedo",
	Firetruck = "Firetruck",
	ATV = "ATV",
	Revuelto = "Revuelto",
}
local sa56af56ac06 = Vector3.new(0, 1, 0)
function m.UpdatePrePhysics(p, dt)
	local O3c0c2c50 = p.Model
	local p0ca6e870a9 = O3c0c2c50:FindFirstChild("Engine")
	if not p0ca6e870a9 then
		return
	end
	local re3cad416daf = p0ca6e870a9.CFrame
	local S00182108b = p0ca6e870a9.Size * 0.5
	local J30dca147e75 = p.Rotate
	local mc9f5c = p.Height
	local S4e4af11dd91 = p.Mass
	local K9cb291a2a = p.TurnSpeed
	local eed595 = p.Make
	local l98f8f496f4 = eed595 == z75f465230b.Model3
	local Jc331d99f = eed595 == z75f465230b.Camaro
	local d99fad = eed595 == z75f465230b.Lamborghini
	local IsRevuelto = eed595 == z75f465230b.Revuelto
	local se9574ec33 = eed595 == z75f465230b.Bugatti
	local b1ce4a = eed595 == z75f465230b.Torpedo
	local IsFiretruck = eed595 == z75f465230b.Firetruck
	local Se065d5cb18 = eed595 == z75f465230b.ATV
	local f728960b1fb5 = G7cdff4e7d30(re3cad416daf, p0ca6e870a9.Velocity)
	local P3ab5ab888 = f728960b1fb5.Magnitude
	local j848b424c8, ecb24b1 = WASDQE[1] - WASDQE[3], WASDQE[2] - WASDQE[4]
	if UserInputService.TouchEnabled then
		local Tf169d8 = LocalPlayer.Character
		if Tf169d8 then
			local kcc1f5d1 = Tf169d8:FindFirstChild("Humanoid")
			if kcc1f5d1 then
				local a1868926c310 = GetMoveVector()
				local r8994b350bb = math.clamp(a1868926c310.X, -1, 1)
				local Aac5e5c345 = math.clamp(a1868926c310.Z, -1, 1)
				j848b424c8 = -Aac5e5c345 * abs(Aac5e5c345)
				ecb24b1 = -r8994b350bb * abs(r8994b350bb)
			end
		end
	end
	if p.LockMovement then
		j848b424c8 = 0
		ecb24b1 = 0
	end
	if Autopilot then
		local Wb9e42 = re3cad416daf.lookVector:Cross(v3(0, 1, 0))
		local h32dfe88b07, T9177c5a41f6 = BetterCast(re3cad416daf * v3(0, 0, -S00182108b.Z - abs(f728960b1fb5.Z) * 16 * dt), v3(0, -1, 0) * 10, O3c0c2c50)
		if h32dfe88b07 then
			local R5268a5c8623 = h32dfe88b07.CFrame:toObjectSpace(re3cad416daf)
			local W56064f = math.floor((R5268a5c8623.X + h32dfe88b07.Size.X * 0.5) / 12)
			local gc3c89f2 = -h32dfe88b07.Size.X * 0.5 + W56064f * 12 + 6
			local Oe1e57a9 = 0 < re3cad416daf.lookVector:Dot(h32dfe88b07.CFrame.lookVector) and 1 or -1
			local q9290225e = h32dfe88b07.CFrame * v3(gc3c89f2, 0, -h32dfe88b07.Size.Z * 0.5 * Oe1e57a9)
			local t9567ade875b = (q9290225e - re3cad416daf.p).unit:Dot(Wb9e42)
			local x37f28898b1 = t9567ade875b * 4
			x37f28898b1 = x37f28898b1 < -1 and -1 or x37f28898b1 > 1 and 1 or x37f28898b1
			ecb24b1 = ecb24b1 - x37f28898b1
			local u7f7c583a = 1 - abs(t9567ade875b) ^ 0.16666666666666666
			j848b424c8 = j848b424c8 + u7f7c583a - abs(t9567ade875b) ^ 4 * 0.3
			ecb24b1 = ecb24b1 > 1 and 1 or ecb24b1 < -1 and -1 or ecb24b1
			j848b424c8 = j848b424c8 > 1 and 1 or j848b424c8 < -1 and -1 or j848b424c8
		end
	end
	local o38d5234168 = 0.16
	local ae89b51f = p.vHeading
	ae89b51f = ae89b51f + ecb24b1 - ae89b51f * (ecb24b1 == 0 and 0.3 or o38d5234168)
	p.vHeading = ae89b51f
	ae89b51f = ae89b51f * o38d5234168
	local A379929d348f, ga7e3681, w02eaf46cd = p.Cd, p.Crr, p.Cb
	local TireHealth = p.TireHealth
	if TireHealth then
		if TireHealth < 1 then
			TireHealth = TireHealth + dt * 0.1
			if TireHealth > 1 then
				TireHealth = 1
				Event:FireServer("RegenTire")
			end
			j848b424c8 = 0
		end
		p.TireHealth = TireHealth
	end
	if ecb24b1 ~= 0 then
		local oa8be1 = ecb24b1 / abs(ecb24b1)
		local c6a848d = f728960b1fb5.X / abs(f728960b1fb5.X)
		if oa8be1 ~= c6a848d and abs(f728960b1fb5.X) > 8 then
			p.LastDrift = tick()
		end
	end
	local C3c5f2e5 = 0.3 > tick() - p.LastDrift
	if eed595 == "Volt" then
		ShouldDrift = false
		C3c5f2e5 = false
	end
	p.Drift = C3c5f2e5
	local p6a8ac341 = 0
	local x946659 = p.Sounds.DriftSqueal.Volume
	if P3ab5ab888 > 30 and (C3c5f2e5 or ShouldDrift and ecb24b1 ~= 0) then
		p6a8ac341 = 0.3
		x946659 = x946659 + (p6a8ac341 - x946659) * 0.06
	else
		x946659 = x946659 + (p6a8ac341 - x946659) * 0.1
	end
	p.Sounds.DriftSqueal.Volume = x946659
	m.UpdateForces(p, dt)
	local K2acd4680 = f728960b1fb5.Z * dt
	if K2acd4680 ~= K2acd4680 then
		K2acd4680 = 0
	end
	local Y6ee3f = p.WheelRotation
	Y6ee3f = Y6ee3f + K2acd4680 / (O3c0c2c50.WheelFrontRight.Wheel.Size.Y * 0.5)
	Y6ee3f = Y6ee3f % (2 * math.pi)
	p.WheelRotation = Y6ee3f
	local xf768a57a7 = tanh(abs(f728960b1fb5.magnitude) * 0.03)
	local L56204 = p.Traction
	local F5e76d6 = (ShouldDrift or C3c5f2e5) and (1 - xf768a57a7) ^ 2 or 1
	if game:GetService("Lighting"):FindFirstChild("IsRaining") then
		F5e76d6 = F5e76d6 * 0.4
	end
	F5e76d6 = F5e76d6 < 0.07 and 0.07 or F5e76d6
	local p697190 = L56204 > F5e76d6 and 0.2 or 0.01
	L56204 = L56204 + (F5e76d6 - L56204) * p697190
	p.Traction = L56204
	local p5bf72b325b = p.Gears
	local F4e881f5fda3, n145d13 = UpdateGearsAndRPM(p, p5bf72b325b, P3ab5ab888, j848b424c8, dt)
	do
		local m977551 = p.NoGears and 1 or n145d13
		local Lca9aa63 = m977551 ^ 0.5 * (P3ab5ab888 / 120)
		if IsNaN(Lca9aa63) then
			Lca9aa63 = 0
		end
		Lca9aa63 = math.clamp(Lca9aa63, 0, 3)
		local R779c85021 = Lca9aa63 < 0.825155 and Lca9aa63 * Lca9aa63 * Lca9aa63 or 1 - exp(-Lca9aa63)
		R779c85021 = R779c85021 * 30 + 70
		local w0450f = CurrentCamera.FieldOfView
		R779c85021 = w0450f + (R779c85021 - w0450f) * 0.7
		CurrentCamera.FieldOfView = R779c85021
	end
	local Ue0634e843, G056bbe259b9, Q457b96297, f5e49c769 = SmartCast(re3cad416daf * v3(0, 0, S00182108b.Z - 1), re3cad416daf:vectorToWorldSpace(v3(0, -1, 0)) * mc9f5c * 2, O3c0c2c50)
	local q86ba3a9d788 = (se9574ec33 or b1ce4a or IsFiretruck) and 650 or (d99fad or IsRevuelto) and 400 or 120
	local c67d75732b6 = -A379929d348f * f728960b1fb5 * P3ab5ab888 * v3(q86ba3a9d788 * L56204, 0, j848b424c8 < 0 and 80 or 1)
	local X2d82c = -ga7e3681 * f728960b1fb5 * v3(q86ba3a9d788 * L56204, 0, 1)
	if Se065d5cb18 and math.abs(X2d82c.X) > S4e4af11dd91 * 0.05 then
		X2d82c = Vector3.new(math.clamp(X2d82c.X, -S4e4af11dd91 * 0.05, S4e4af11dd91 * 0.05), 0, X2d82c.Z)
	end
	local pa1cc8d37fa = -(w02eaf46cd * (1 + p.GarageBrakes)) * f728960b1fb5.Z / abs(f728960b1fb5.Z)
	if pa1cc8d37fa ~= pa1cc8d37fa then
		pa1cc8d37fa = 0
	end
	local N84e4c493d5 = pa1cc8d37fa * v3(0, 0, 1)
	local z1bd360690ac = -w02eaf46cd * 0.3 * f728960b1fb5 * v3(1, 0, 0)
	local U1bcd24 = p.Nitro
	local t4806ed00e6 = (U1bcd24 and 0.17 * S4e4af11dd91 or 0) * v3(0, -0.1, -1)
	if U1bcd24 and not p.Nitrof1 then
		p.Nitrof1 = true
		m.SetGravity(p, 20)
	elseif not U1bcd24 and p.Nitrof1 then
		p.Nitrof1 = false
		m.SetGravity(p, 100)
	end
	local i6296b31806
	local u757764f1dd5 = j848b424c8 * v3(0, 0, -1) * p5bf72b325b[1] * 1 / 0.34 * 750
	local Wedfde
	if p.NoGears then
		Wedfde = j848b424c8 > 0 and p5bf72b325b[1] or p5bf72b325b[2]
	else
		Wedfde = j848b424c8 > 0 and p5bf72b325b[2 + F4e881f5fda3] or p5bf72b325b[2]
	end
	local L3213fdac = 4.4
	if d99fad or eed595 == "Ferrari" then
		L3213fdac = 6.5
	elseif se9574ec33 then
		L3213fdac = 8
	elseif l98f8f496f4 then
		L3213fdac = 4.2
	elseif eed595 == "Monster" then
		L3213fdac = 5
	elseif IsFiretruck then
		L3213fdac = 10
	elseif Se065d5cb18 then
		L3213fdac = 1.5
	end
	L3213fdac = L3213fdac + p.GarageEngineSpeed
	if p.GarageSpoilerSpeed then
		L3213fdac = L3213fdac + 0.5
	end
	i6296b31806 = u757764f1dd5 * Wedfde * L3213fdac
	do
		local Mcc14e0cc, B80880e3f1e, E0f220, v5f86c5d40 = workspace:FindPartOnRay(Ray.new(re3cad416daf.p + sa56af56ac06 * 10, sa56af56ac06 * -20), O3c0c2c50)
		if v5f86c5d40 and v5f86c5d40 == Enum.Material.Water then
			i6296b31806 = i6296b31806 * 0.625
		end
	end
	local ea1118e = c67d75732b6 + X2d82c
	if j848b424c8 ~= 0 and j848b424c8 == j848b424c8 then
		ea1118e = ea1118e + i6296b31806
		p.LastForward = j848b424c8 / abs(j848b424c8)
	end
	if j848b424c8 == 0 then
		if P3ab5ab888 <= 1 then
			p0ca6e870a9.Velocity = v3b
		else
			ea1118e = ea1118e + N84e4c493d5
		end
	end
	if ShouldDrift and ecb24b1 == 0 and j848b424c8 == 0 then
		ea1118e = ea1118e + N84e4c493d5 * 3
		ea1118e = ea1118e + z1bd360690ac
	end
	local ya9721c, m3aaad, eb4185d686 = 0, 0, 0
	local s41a643 = p.RotY
	s41a643 = s41a643 + (ecb24b1 - s41a643) * 0.1
	p.RotY = s41a643
	local Idd975ea2b3 = v3(0, 0, -3 * s41a643)
	if Ue0634e843 then
		p.LastMaterial = f5e49c769
		if f5e49c769 == Enum.Material.Grass then
			ya9721c = 0.4
		elseif f5e49c769 == Enum.Material.Concrete or f5e49c769 == Enum.Material.Basalt or f5e49c769 == Enum.Material.Asphalt then
			m3aaad = 0.94
		elseif f5e49c769 == Enum.Material.Sandstone or f5e49c769 == Enum.Material.Sand then
			eb4185d686 = 0.5
		end
		local If8561a1d4 = math.exp(-max(f728960b1fb5.magnitude, 120) / 400) * (ShouldDrift and 1.5 or 1.2)
		local u48c6b75a1e = -f728960b1fb5.Z / abs(f728960b1fb5.Z)
		if u48c6b75a1e ~= u48c6b75a1e then
			u48c6b75a1e = 0
		end
		if p.LastForward ~= u48c6b75a1e and 2 < abs(f728960b1fb5.Z) and not ShouldDrift then
			p.LastForward = u48c6b75a1e
		end
		if ecb24b1 ~= 0 then
			J30dca147e75.MaxTorque = v3(0, p.Mass * 30, 0)
		elseif f728960b1fb5.Z < 0 and not ShouldDrift then
			J30dca147e75.MaxTorque = v3(0, p.Mass * 2, 0)
		end
		J30dca147e75.AngularVelocity = v3(0, ae89b51f * K9cb291a2a * p.LastForward * If8561a1d4 * xf768a57a7, 0)
	else
		ea1118e = v3b
		J30dca147e75.MaxTorque = v3(p.Mass * 0.5, p.Mass, p.Mass * 0.5)
	end
	ea1118e = ea1118e + t4806ed00e6
	I33abb = re3cad416daf.p
	do
		local rcb305, g8ecfc, P904cd0b = p.Sounds.Grass, p.Sounds.Asphalt, p.Sounds.Sandstone
		p.vGrass = p.vGrass + (ya9721c - p.vGrass) * 0.03
		p.vAsphalt = p.vAsphalt + (m3aaad - p.vAsphalt) * 0.03
		p.vSandstone = p.vSandstone + (eb4185d686 - p.vSandstone) * 0.03
		local a2460f9 = P3ab5ab888 < 60 and P3ab5ab888 / 60 or 1
		a2460f9 = a2460f9 * 0.7
		rcb305.Volume = p.vGrass * a2460f9
		g8ecfc.Volume = p.vAsphalt * a2460f9
		P904cd0b.Volume = p.vSandstone * a2460f9
		local Rd4d17a954b4 = P3ab5ab888 > 0 and (P3ab5ab888 / 120) ^ 0.5 or 0
		rcb305.PlaybackSpeed = Rd4d17a954b4
		g8ecfc.PlaybackSpeed = Rd4d17a954b4
		P904cd0b.PlaybackSpeed = Rd4d17a954b4
	end
	for Bc858df3c982, a82c13f09e in next, p.Model.Model:GetChildren() do
		if a82c13f09e.Name == "Headlights" then
			local W6817f1b04 = Lights
			a82c13f09e.Material = W6817f1b04 and Enum.Material.Neon or Enum.Material.Plastic
			a82c13f09e.SpotLight.Enabled = W6817f1b04
		end
	end
	local h2ac98a9d124 = O3c0c2c50.Model:FindFirstChild("Brakelights")
	if h2ac98a9d124 then
		local c429ea910 = ShouldDrift or j848b424c8 < 1.0E-6
		h2ac98a9d124.Material = c429ea910 and Enum.Material.Neon or Enum.Material.Plastic
		h2ac98a9d124.SpotLight.Enabled = c429ea910
		if p.Make == "Revuelto" then
			for _, v in next, h2ac98a9d124:GetChildren() do
				if v:IsA("Trail") then
					v.Enabled = c429ea910
				end
			end
		end
	end
	p.DriveThruster.Force = ea1118e
	if p.IK then
		local haba8605 = 0.6 * p.RotY
		local Tf61014a9 = p.IK
		p.WeldSteer.C0 = cfa(0, haba8605, 0)
		local a8018668e = O3c0c2c50.Steer.CFrame
		local g608e48e = O3c0c2c50.Steer.Size.X * 0.5 - 0.2
		local C0ee01d = p.IK
		C0ee01d.RightArm = a8018668e * v3(g608e48e, 0.1, 0)
		C0ee01d.LeftArm = a8018668e * v3(-g608e48e, 0.1, 0)
		C0ee01d.RightAngle = -haba8605 - 0.6
		C0ee01d.LeftAngle = -haba8605 + 0.6
		IKR15.Arms(C0ee01d)
	end
	local I7d52f3ec323, Yfa445a35146, Hd8e0f, ye5203a3f31, n1a38ea, c6665828bc0, B8863e1, yb7e01bc42, R7ce85cd82, f390746c2cc4, q2a6e486ce6, z5b31ee21 = re3cad416daf:components()
	if yb7e01bc42 < -0.25 then
		if not p.UpsideDownTime then
			p.UpsideDownTime = tick()
		elseif 2 < tick() - p.UpsideDownTime then
			p.UpsideDownTime = nil
			Event:FireServer("VehicleFlip", O3c0c2c50)
		end
	else
		p.UpsideDownTime = nil
	end
	local p2975267b667
	if not IsStudio or IsStudio and Settings.Test.RegionSounds then
		local P5fe22 = Settings.Prism.City
		if Region.CastPoint(P5fe22, p0ca6e870a9.Position) then
			p2975267b667 = "City"
		end
	end
	local A11d30b, lcf901 = SmartCast(re3cad416daf * v3(0, 0, S00182108b.Z - 1), re3cad416daf:vectorToWorldSpace(v3(0, 1, 0)) * 20, O3c0c2c50)
	local LastEnvironment = A11d30b and "Tunnel" or p2975267b667 or "Outside"
	if p.LastEnvironment ~= LastEnvironment then
		local zb6da5e0f2 = 4
		if LastEnvironment == "Tunnel" or p.LastEnvironment == "Tunnel" then
			zb6da5e0f2 = 0.5
		end
		p.TransitionSpeed = 1 / zb6da5e0f2
		p.EnvironmentTransition = true
		p.LastEnvironment = LastEnvironment
		Transition = 0
		for Me8c72c0fb, s0f98d in next, SoundOptions, nil do
			p[Me8c72c0fb] = {}
			for X78a4f2bb7, f83728b6048 in next, s0f98d, nil do
				p[Me8c72c0fb][f83728b6048] = SoundEffects[Me8c72c0fb][f83728b6048]
			end
		end
	end
	if p.EnvironmentTransition then
		local Values = SoundValues[LastEnvironment]
		Transition = Transition + dt * p.TransitionSpeed
		for Effect, Options in next, SoundOptions, nil do
			for _, Option in next, Options, nil do
				local Last = p[Effect][Option]
				local Value = Values[Effect][Option]
				SoundEffects[Effect][Option] = Last * (1 - Transition) + Value * Transition
			end
		end
		if Transition >= 1 then
			p.EnvironmentTransition = false
		end
	end
end
function m.UpdateForces(p, dt)
	local Wheels = p.Wheels
	of531096aa8(p, Wheels.WheelFrontRight, dt)
	of531096aa8(p, Wheels.WheelFrontLeft, dt)
	of531096aa8(p, Wheels.WheelBackRight, dt)
	of531096aa8(p, Wheels.WheelBackLeft, dt)
end
function m.UpdatePostPhysics(p, dt)
	local Wheels = p.Wheels
	for _, Wheel in next, p.Wheels, nil do
		Wheel.Thruster.Force = v3b
	end
end
function m.Halt(p)
	p.DriveThruster.Force = v3b
	p.Rotate.MaxTorque = v3b
end
local InputLookup = {
	[Enum.KeyCode.W] = 1,
	[Enum.KeyCode.A] = 2,
	[Enum.KeyCode.S] = 3,
	[Enum.KeyCode.D] = 4,
	[Enum.KeyCode.Q] = 5,
	[Enum.KeyCode.E] = 6,
	[Enum.KeyCode.ButtonR2] = 1,
	[Enum.KeyCode.ButtonL2] = 3,
	[Enum.KeyCode.Up] = 1,
	[Enum.KeyCode.Left] = 2,
	[Enum.KeyCode.Down] = 3,
	[Enum.KeyCode.Right] = 4
}
function m.InputBegan(i)
	if i.UserInputType == Enum.UserInputType.Keyboard then
		local k = i.KeyCode
		if InputLookup[k] then
			WASDQE[InputLookup[k]] = 1
		end
	end
end
function m.InputEnded(i)
	if i.UserInputType == Enum.UserInputType.Keyboard then
		local k = i.KeyCode
		if InputLookup[k] then
			WASDQE[InputLookup[k]] = 0
		end
	elseif i.UserInputType == Enum.UserInputType.Gamepad1 then
		local k = i.KeyCode
		if k == Enum.KeyCode.ButtonR2 or k == Enum.KeyCode.ButtonL2 then
			WASDQE[InputLookup[k]] = 0
		end
	end
end
function m.InputChanged(i)
	if i.UserInputType == Enum.UserInputType.Gamepad1 then
		local k = i.KeyCode
		if k == Enum.KeyCode.Thumbstick1 then
			local v = i.Position
			local x, y = v.X, v.Y
			local th = 0.24
			WASDQE[2] = x < -th and (-x) ^ 2 or 0
			WASDQE[4] = x > th and x ^ 2 or 0
		elseif k == Enum.KeyCode.ButtonR2 or k == Enum.KeyCode.ButtonL2 then
			local v = i.Position
			local z = v.Z
			local th = 0.05
			WASDQE[InputLookup[k]] = z > th and z ^ 0.5 or 0
		end
	end
end
function m.SetEvent(n)
	Event = n
end
do
	local CircleAction = UI.CircleAction
	local function Callback(Spec, Processed)
		if Processed then
			Event:FireServer("ToggleLadder", Spec.Part)
		end
		return true
	end
	local function AddedFun(Part)
		local Spec = {
			Part = Part,
			Name = "Toggle Ladder",
			NoRay = true,
			Timed = true,
			Duration = 0.5,
			Dist = 10,
			Callback = Callback
		}
		CircleAction.Add(Spec, Part)
	end
	local function RemovedFun(Part)
		CircleAction.Remove(Part)
	end
	for _, v in next, CollectionService:GetTagged("Firetruck_Ladder") do
		AddedFun(v)
	end
	CollectionService:GetInstanceAddedSignal("Firetruck_Ladder"):Connect(AddedFun)
	CollectionService:GetInstanceRemovedSignal("Firetruck_Ladder"):Connect(RemovedFun)
end
return m
