-- Decompiled with the Synapse X Luau decompiler.

local v1 = Color3.fromRGB(125, 125, 125);
local v2 = true;
if game:GetService("UserInputService"):GetLastInputType() ~= "Touch" then
	v2 = game:GetService("UserInputService").TouchEnabled and not game:GetService("UserInputService").KeyboardEnabled;
end;
local u1 = require(script.Parent.XboxModule);
local u2 = {
	VersusFrame = true, 
	Title = true, 
	LevelUp = true
};
local function u3(p1)
	local v3 = _G.PlayerIcons[p1];
	if v3 == nil then
		print("No Player Image: " .. tostring(p1));
		local v4 = game.Players:FindFirstChild(p1);
		game.Players:GetUserThumbnailAsync(math.abs(v4 and v4.userId or 0), Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size352x352);
	end;
	return v3;
end;
local u4 = {
	Sheriff = "Hero", 
	Hero = "Sheriff"
};
local u5 = require(script.Parent.ItemModule);
local u6 = require(script.Parent.LevelModule);
local u7 = {
	Commafy = function(p2)
		local v5 = p2;
		while true do
			local v6, v7 = string.gsub(v5, "^(-?%d+)(%d%d%d)", "%1,%2");
			local k = v7;
			v5 = v6;
			if k == 0 then
				break;
			end;		
		end;
		return v5;
	end
};
local l__TweenService__8 = game:GetService("TweenService");
local u9 = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0);
local u10 = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0);
function u7.DisplayScoreboard(p3)
	_G.LastRound = p3.RoundCount;
	local l__PlayerData__8 = p3.PlayerData;
	local l__TotalEarnedXP__9 = p3.Rewards.TotalEarnedXP;
	local l__WinCondition__10 = p3.WinCondition;
	local l__RoundCount__11 = p3.RoundCount;
	local v12 = v2 and game.Players.LocalPlayer.PlayerGui.Scoreboard_Phone or game.Players.LocalPlayer.PlayerGui.Scoreboard;
	local l__Container__13 = v12[p3.GameModeName].Container;
	local v14 = l__Container__13:FindFirstChild("RewardContainer") and l__Container__13;
	if v14.Name == "RewardContainer" then
		v14.Visible = false;
	end;
	local v15 = l__Container__13.VersusFrame:FindFirstChild("Title") or l__Container__13.Title;
	for v16, v17 in pairs(v12:GetChildren()) do
		v17.Visible = v17 == l__Container__13.Parent;
	end;
	if game:GetService("UserInputService").GamepadEnabled and not game:GetService("UserInputService").MouseEnabled then
		v15.Close.Visible = false;
		v15.CloseXbox.Visible = true;
	end;
	u1.Bind("CloseScoreboard", Enum.KeyCode.ButtonY, function()
		v12.Enabled = false;
		u1.Unbind("CloseScoreboard");
	end);
	for v18, v19 in pairs(v14:GetChildren()) do
		if v19:IsA("Frame") then
			v19.Visible = u2[v19.Name] ~= nil;
			if v19.Name == "LevelUp" then
				v19.Visible = l__PlayerData__8[game.Players.LocalPlayer.Name] ~= nil;
			end;
		end;
	end;
	if p3.GameModeName == "Classic" then
		local v20 = nil;
		local v21 = nil;
		for v22, v23 in pairs(p3.PlayerData) do
			if v23.Role == "Sheriff" then
				v21 = v22;
			elseif v23.Role == "Murderer" then
				v20 = v22;
			end;
		end;
		if v20 == nil or v21 == nil then
			v12.Enabled = false;
			u1.Unbind("CloseScoreboard");
			return;
		end;
		local l__Container__24 = l__Container__13.VersusFrame.Container;
		local l__Container__25 = l__Container__24.Murderer.Container;
		l__Container__25.PlayerIcon.Image = u3(v20);
		l__Container__25.PlayerName.Text = v20;
		l__Container__25.Dead.Visible = l__PlayerData__8[v20].Dead;
		local l__Container__26 = l__Container__24.Sheriff.Container;
		local v27 = p3.Shooter and v21;
		l__Container__26.PlayerIcon.Image = u3(v27);
		local l__Role__28 = l__PlayerData__8[v27].Role;
		l__Container__26[l__Role__28].Visible = true;
		l__Container__26[u4[l__Role__28]].Visible = false;
		l__Container__26.PlayerName.Text = v27;
		l__Container__26.Dead.Visible = l__PlayerData__8[v27].Dead;
		u5.DisplayItem(l__Container__24.KnifeFrame, _G.Database.Weapons[l__PlayerData__8[v20].Knife]);
		u5.DisplayItem(l__Container__24.GunFrame, _G.Database.Weapons[l__PlayerData__8[v27].Gun]);
		local v29 = nil;
		if l__WinCondition__10 == "MurdererWin" then
			v29 = "MurdererWin";
		elseif l__WinCondition__10 == "MurdererDied" and v27 and v27 == v21 then
			v29 = "Sheriff";
		elseif l__WinCondition__10 == "MurdererDied" and v27 and v27 ~= v21 then
			v29 = "Hero";
		else
			v29 = "Innocents";
		end;
		if l__WinCondition__10 == "SheriffWin" then
			v29 = "Sheriff";
		elseif v29 == "Innocents" and p3.Was1v1 == true then
			v29 = "Draw";
		end;
		for v30, v31 in pairs(v15:GetChildren()) do
			if v31.Name ~= "Close" and v31.Name ~= "CloseXbox" then
				v31.Visible = v31.Name == v29;
			end;
		end;
	elseif p3.GameModeName == "Assassin" then
		v15.Draw.Visible = l__WinCondition__10 == "TimeRanOut";
		v15.MurdererWin.Visible = l__WinCondition__10 == "PlayerWon";
		local v32 = nil;
		if l__WinCondition__10 == "PlayerWon" then
			for v33, v34 in pairs(l__PlayerData__8) do
				if v34.Dead == false then
					v32 = v33;
					break;
				end;
			end;
		else
			v32 = game.Players.LocalPlayer.Name;
		end;
		v15.MurdererWin.Text = v32 .. " has won!";
		local l__Container__35 = l__Container__13.VersusFrame.Container;
		local l__Container__36 = l__Container__35.Murderer.Container;
		l__Container__36.PlayerIcon.Image = u3(v32);
		l__Container__36.PlayerName.Text = v32;
		l__Container__36.Role.Visible = l__WinCondition__10 == "PlayerWon";
		if v32 == game.Players.LocalPlayer then
			l__Container__36.PlayerName.Text = "(You)";
		end;
		u5.DisplayItem(l__Container__35.KnifeFrame, _G.Database.Weapons[l__PlayerData__8[v32].Knife]);
	elseif p3.GameModeName == "ScaryMode" then
		local v37 = nil;
		for v38, v39 in pairs(p3.PlayerData) do
			if v39.Role == "Murderer" then
				v37 = v38;
			end;
		end;
		v15.MurdererWin.Visible = l__WinCondition__10 == "MurdererWin";
		v15.InnocentsEscaped.Visible = l__WinCondition__10 ~= "MurdererWin";
		local l__Container__40 = l__Container__13.VersusFrame.Container.Murderer.Container;
		l__Container__40.PlayerIcon.Image = u3(v37);
		l__Container__40.PlayerName.Text = v37;
		l__Container__40.Dead.Visible = l__PlayerData__8[v37].Dead or l__WinCondition__10 == "InnocentsEscaped";
	end;
	local v41 = l__PlayerData__8[game.Players.LocalPlayer.Name];
	if v41 ~= nil or p3.Was1v1 then
		local l__XP__42 = v41.XP;
		local l__XP__43 = l__Container__13.LevelUp.Level.XPBar.XP;
		local v44 = u6.GetLevel(l__XP__42);
		local v45 = u6.GetProgressToNextLevel(l__XP__42);
		l__Container__13.LevelUp.Level.Level.LevelText.Text = v44 < 100 and v44 + 1 or 100;
		local v46 = nil;
		if v45 > 1 then
			v46 = 1;
		else
			v46 = v45;
		end;
		l__XP__43.Size = UDim2.new(v46, l__XP__43.Size.X.Offset, l__XP__43.Size.Y.Scale, l__XP__43.Size.Y.Offset);
		l__Container__13.LevelUp.Coins.CoinIcon.TextLabel.Text = v41.Coins and 0;
		l__Container__13.LevelUp.TotalXP.XPIcon.TextLabel.Text = "+0";
		v12.Enabled = true;
		wait(1);
		for v47, v48 in pairs(p3.Rewards.XPRewards) do
			wait(0.5);
			local l__Container__49 = v14[v47].Container;
			l__Container__49.TextLabel.Text = v48.Text;
			l__Container__49.XPIcon.TextLabel.Text = (v48.Multiplier and "+") .. u7.Commafy(v48.XP);
			l__Container__49.Parent.Visible = true;
			v14.Visible = true;
		end;
		wait(0.5);
		local l__TweenValue__50 = l__Container__13.LevelUp.TotalXP.XPIcon.TextLabel.TweenValue;
		l__TweenValue__50.Value = 0;
		l__TweenValue__50.Changed:connect(function()
			l__Container__13.LevelUp.TotalXP.XPIcon.TextLabel.Text = "+" .. u7.Commafy(math.floor(l__TweenValue__50.Value));
		end);
		for v51, v52 in pairs({ l__TweenService__8:Create(l__TweenValue__50, u9, {
			Value = l__TotalEarnedXP__9
			}) }) do
			v52:Play();
		end;
		local v53 = u6.GetLevel(l__XP__42 + l__TotalEarnedXP__9) - u6.GetLevel(l__XP__42);
		local v54 = u6.GetLevel(l__XP__42 + l__TotalEarnedXP__9);
		print("CurrentLevel", v44);
		print("LevelsGained", v53);
		print("NewLevel", v54);
		if v54 + 1 > 100 then

		end;
		if v54 > 100 then

		end;
		if v53 > 0 then
			for v55 = 1, v53 do
				local v56 = 0.7;
				if v55 == 1 then
					v56 = v56 * (1 - v45);
				end;
				for v57, v58 in pairs({ l__TweenService__8:Create(l__XP__43, TweenInfo.new(v56, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0), {
					Size = UDim2.new(1, 0, 1, 0)
					}) }) do
					v58:Play();
				end;
				wait(v56);
				l__XP__43.Size = UDim2.new(0, 0, 1, 0);
				l__Container__13.LevelUp.Level.Level.LevelText.Text = v44 + v55 + 1;
			end;
		end;
		local v59 = l__XP__42 + l__TotalEarnedXP__9;
		if v59 > 1237500 then
			v59 = 1237500;
		end;
		local v60 = u6.GetProgressToNextLevel(v59);
		if v60 > 1 then
			v60 = 1;
		elseif v60 < 0 then
			v60 = 0;
		end;
		for v61, v62 in pairs({ l__TweenService__8:Create(l__XP__43, u10, {
			Size = UDim2.new(v60, 0, 1, 0)
			}) }) do
			v62:Play();
		end;
		wait(1.5);
	else
		l__Container__13.Enabled = true;
	end;
	wait(10);
	v12.Enabled = false;
	u1.Unbind("CloseScoreboard");
end;
return u7;
