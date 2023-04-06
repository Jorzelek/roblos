-- Decompiled with the Synapse X Luau decompiler.

local u1 = {
	GUI = {}, 
	PlayerInventories = {}
};
local u2 = require(game.ReplicatedStorage.RankIconsEmpty);
local u3 = {
	[0] = "",
	"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"
};
local u4 = require(script.Parent.ItemModule);
local u5 = { Color3.fromRGB(255, 170, 0), Color3.fromRGB(193, 218, 216), (Color3.fromRGB(139, 58, 0)) };
function u1.GenerateProfile(p1, p2, p3, p4)
	local l__ProfileContainer__1 = u1.GUI.ProfileContainer;
	local l__Character__2 = l__ProfileContainer__1.Character;
	local l__Container__3 = l__ProfileContainer__1.Profile.Season1Stats.Container;
	local l__Trophies__4 = l__ProfileContainer__1.Profile.Trophies;
	local v5 = nil
	if p2 == game.Players.LocalPlayer.Name then
		v5 = " (You)";
	else
		v5 = "";
	end;
	(l__ProfileContainer__1:FindFirstChild("Username") or l__ProfileContainer__1.Parent:FindFirstChild("Username")).Text = p2 .. v5;
	local v6 = game.Players:GetUserThumbnailAsync(math.abs(game.Players[p2].userId), Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size352x352);
	l__Character__2.CharacterIcon.Image = v6;
	p1.Nav.Profile.Icon.Image = v6;
	l__Character__2.CharacterIcon.LevelFrame.LevelContainer.Icon.Level.Text = p3.Level;
	l__Character__2.CharacterIcon.LevelFrame.LevelContainer.Icon.Image = u2[p3.Level];
	l__Character__2.CharacterIcon.LevelFrame.LevelContainer.Prestige.Visible = p3.Prestige > 0;
	if p3.Prestige > 0 then
		l__Character__2.CharacterIcon.LevelFrame.LevelContainer.Prestige.Text = u3[p3.Prestige];
	end;
	l__Character__2.Elite.Visible = p3.Elite == true;
	l__Character__2.Builder.Visible = p3.MapBuilder == true;
	l__Character__2.WeaponDesigner.Visible = p3.WeaponDesigner == true;
	l__Character__2.MM2Creator.Visible = p3.Nikilis == true;
	l__Character__2.BetaTester.Visible = p3.BetaTester == true;
	l__Character__2.Clown.Visible = p3.Clown == true;
	l__Container__3.Eliminations.Amount.Text = p3.Eliminations;
	l__Container__3.Saves.Amount.Text = p3.Victories;
	l__Container__3.Survivals.Amount.Text = p3.Survivals;
	l__Trophies__4.Visible = p3.Trophies ~= nil;
	l__Trophies__4.Container:ClearAllChildren();
	if p3.Trophies then
		script.TrophyGridLayout:Clone().Parent = l__Trophies__4.Container;
		local v7, v8, v9 = pairs(p3.Trophies);
		while true do
			local v10, v11 = v7(v8, v9);
			if not v10 then
				break;
			end;
			local v12 = script.TrophyItem:Clone();
			local l__ItemID__13 = v11.ItemID;
			local l__Rank__14 = v11.Rank;
			v12.Container.Icon.Image = u4.GetImage(_G.Database.Weapons[l__ItemID__13].Image);
			v12.Container.Year.YearText.Text = _G.Database.Weapons[l__ItemID__13].Year;
			v12.ItemName.Label.Text = v11.Rank and "Rank #" .. v11.Rank or _G.Database.Weapons[l__ItemID__13].ItemName;
			if u5[l__Rank__14] then
				v12.ItemName.BackgroundColor3 = u5[l__Rank__14];
			end;
			v12.Parent = l__Trophies__4.Container;		
		end;
	end;
	u1.DisplayInventory(p1, p2, p4);
end;
local u6 = require(game.ReplicatedStorage.Modules.InventoryModule);
local u7 = nil;
function u1.DisplayInventory(p5, p6, p7)
	local v15, v16, v17 = pairs({ "Weapons", "Effects", "Perks", "Emotes", "Radios", "Pets" });
	while true do
		local v18, v19 = v15(v16, v17);
		if not v18 then
			break;
		end;
		local l__Title__20 = p5.Main:FindFirstChild(v19):FindFirstChild("Title");
		if l__Title__20 then
			l__Title__20.Username.Text = p6 .. "'s " .. v19;
		end;
		for v21, v22 in pairs(u6.CreateBlankInventoryTable()[v19]) do
			(p5.Main:FindFirstChild(v19).Items.Container:FindFirstChild(v21) or p5.Main:FindFirstChild(v19).Items.Container:FindFirstChild("Holiday").Container:FindFirstChild(v21)).Container:ClearAllChildren();
		end;	
	end;
	local v23 = u6.GenerateInventory(p5, game.ReplicatedStorage.Remotes.Extras.GetFullInventory:InvokeServer(p6), nil, p7);
	u1.PlayerInventories[p6] = v23;
	if u7 then
		u7:disconnect();
	end;
	local l__SearchFrameTextBox__24 = u1.GUI.SearchFrameTextBox;
	u7 = l__SearchFrameTextBox__24:GetPropertyChangedSignal("Text"):connect(function()
		local v25 = string.gsub(l__SearchFrameTextBox__24.Text, "S", "");
		for v26, v27 in pairs(v23.Data.Weapons) do
			for v28, v29 in pairs(v27) do
				v29.Frame.Visible = string.find(string.lower(v29.Name), string.lower(v25));
				if v29.Frame.Parent.Parent:IsA("ScrollingFrame") then
					v29.Frame.Parent.Parent.CanvasPosition = Vector2.new(0, 0);
				else
					v29.Frame.Parent.Parent.Parent.Parent.CanvasPosition = Vector2.new(0, 0);
				end;
			end;
		end;
	end);
end;
function u1.DisplayInventoryFromData(p8, p9, p10)
	local v30, v31, v32 = pairs({ "Weapons", "Effects", "Perks", "Emotes", "Radios", "Pets" });
	while true do
		local v33, v34 = v30(v31, v32);
		if not v33 then
			break;
		end;
		local l__Title__35 = p8.Main:FindFirstChild(v34):FindFirstChild("Title");
		if l__Title__35 then
			l__Title__35.Username.Text = p9 .. "'s " .. v34;
		end;
		for v36, v37 in pairs(u6.CreateBlankInventoryTable()[v34]) do
			(p8.Main:FindFirstChild(v34).Items.Container:FindFirstChild(v36) or p8.Main:FindFirstChild(v34).Items.Container:FindFirstChild("Holiday").Container:FindFirstChild(v36)).Container:ClearAllChildren();
		end;	
	end;
	u1.PlayerInventories[p9] = u6.GenerateInventory(p8, p10);
end;
function u1.DisplayInventoryFromProfile()

end;
function u1.ConnectViewProfile(p11)
	u6.ConnectNavButtons(p11.Nav, p11.Main);
	u6.ConnectTabButtons(p11, "Weapons");
end;
return u1;
