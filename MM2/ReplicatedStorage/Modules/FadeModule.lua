-- Decompiled with the Synapse X Luau decompiler.

local v1 = {};
local v2 = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
local u1 = {
	In = false, 
	Out = true
};
local l__TweenService__2 = game:GetService("TweenService");
local u3 = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false);
local u4 = {
	In = 0, 
	Out = 1
};
function v1.PlayCameraFade(p1)
	local l__Fade__3 = game.Players.LocalPlayer.PlayerGui:WaitForChild("CameraFade").Fade;
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, u1[p1]);
	for v4, v5 in pairs({ l__TweenService__2:Create(l__Fade__3, u3, {
			BackgroundTransparency = u4[p1]
		}) }) do
		v5:Play();
	end;
end;
function v1.DeathFlash()
	local l__Fade__6 = game.Players.LocalPlayer.PlayerGui:FindFirstChild("SpawnFade").Fade;
	l__Fade__6.BackgroundTransparency = 0;
	l__Fade__6.BackgroundColor3 = Color3.new(1, 1, 1);
	wait(0.1);
	l__Fade__6.BackgroundColor3 = Color3.new(0, 0, 0);
end;
local function u5(p2)
	local l__Fade__7 = game.Players.LocalPlayer.PlayerGui:FindFirstChild("SpawnFade").Fade;
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, u1[p2]);
	for v8, v9 in pairs({ l__TweenService__2:Create(l__Fade__7, u3, {
			BackgroundTransparency = u4[p2]
		}) }) do
		v9:Play();
	end;
end;
function v1.FadeToWinner(p3, p4)
	if p4 then
		v1.PlayCameraFade("In");
		wait(0.3);
	end;
	game.Workspace.CurrentCamera.CameraSubject = p3.Character.Humanoid;
	v1.PlayCameraFade("Out");
	u5("Out");
	wait(0.4);
end;
function v1.SpawnFade()
	wait(0.5);
	local l__Fade__10 = game.Players.LocalPlayer.PlayerGui:FindFirstChild("SpawnFade").Fade;
	l__Fade__10.BackgroundTransparency = 0;
	l__Fade__10.BackgroundColor3 = Color3.new(0, 0, 0);
	u5("Out");
	v1.PlayCameraFade("Out");
	game.Workspace.CurrentCamera.CameraType = "Custom";
	game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid;
end;
function v1.CameraFadeToLocalPlayer()
	if game.Players.LocalPlayer.Character ~= nil then
		game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid;
	end;
	v1.PlayCameraFade("Out");
end;
return v1;
