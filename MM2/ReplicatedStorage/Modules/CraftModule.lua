-- Decompiled with the Synapse X Luau decompiler.

local v1 = {};
local v2 = {
	Classic = 1, 
	Common = 2, 
	Uncommon = 3, 
	Rare = 4, 
	Legendary = 5, 
	Godly = 6, 
	Victim = 7, 
	Unique = 7, 
	Christmas = 1.5, 
	Halloween = 1.6, 
	Ancient = 6.5
};
v1.GUI = nil;
v1.Mode = "Craft";
local v3 = {};
for v4, v5 in pairs((game.ReplicatedStorage.GetSyncData:InvokeServer("Codes"))) do
	v3[v5.Prize] = true;
end;
local u1 = nil;
local u2 = nil;
local u3 = nil;
function v1.SetCraftGUI(p1, p2, p3, p4, p5, p6, p7, p8, p9)
	v1.GUI = p1;
	v1.RecipesFrame = p2;
	v1.NewRecipeFrame = p3;
	v1.ActionNav = p4;
	v1.SalvageInventoryFrame = p5;
	v1.NewItemFrame = p6;
	v1.SalvageConfirmFrame = p7;
	v1.SalvageGUI = p8;
	v1.SalvageConfirmButton = p9;
	u1 = nil;
	u2 = nil;
	u3 = v1.SalvageConfirmButton.MouseButton1Click:connect(v1.ActionConfirmButtonFunction);
end;
function v1.CraftConfirm()

end;
function v1.SalvageConfirm()

end;
function v1.SetCraftConfirmButton(p10)
	v1.CraftConfirm = p10;
end;
function v1.SetSalvageConfirmButton(p11)
	v1.SalvageConfirm = p11;
end;
function v1.ChangeMode(p12, p13)
	v1.Mode = p12;
	if p13 then
		local v6 = nil
		if p12 == "Salvage" then
			v6 = u1 and Enum.ButtonStyle.RobloxRoundDefaultButton or (u2 and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton);
		else
			v6 = u2 and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton;
		end;
		v1.ActionNav.Confirm.Style = v6;
	end;
end;
function v1.CheckHasRecipe(p14)
	local l__Database__7 = _G.Database;
	local v8 = 0;
	local v9 = 0;
	local v10 = 0;
	local v11 = {};
	if l__Database__7.Recipes[p14].CombinationRecipe then
		local v12 = false;
		for v13, v14 in pairs(l__Database__7.Recipes) do
			if v14.CombinedRecipe == p14 then
				local v15, v16 = v1.CheckHasRecipe(v13);
				if v15 then
					return true, true;
				end;
				if v12 then
					v12 = true;
				end;
			end;
		end;
		return false, v12;
	end;
	for v17, v18 in pairs(l__Database__7.Recipes[p14].Materials) do
		v10 = v10 + 1;
		if _G.PlayerData.Materials.Owned[v17] and _G.PlayerData.Materials.Owned[v17] > 0 then
			v8 = v8 + 1;
			v11[v17] = "Has";
			if v18 <= _G.PlayerData.Materials.Owned[v17] then
				v9 = v9 + 1;
				v11[v17] = "Completed";
			end;
		end;
	end;
	local v19 = false;
	if v8 > 0 then
		v19 = not (v10 <= v9);
	end;
	return v10 <= v9, v8 > 0, v19, v11;
end;
function v1.GetRecipes()
	local l__Database__20 = _G.Database;
	local v21 = {};
	for v22, v23 in pairs(l__Database__20.Recipes) do
		if v23.CombinedRecipe then
			if v21[v23.CombinedRecipe] then
				v21[v23.CombinedRecipe][v22] = v23;
			else
				v21[v23.CombinedRecipe] = {
					[v22] = v23
				};
			end;
		end;
	end;
	local v24 = {};
	for v25, v26 in pairs(l__Database__20.Recipes) do
		if not v26.CombinedRecipe then
			table.insert(v24, {
				ID = v25, 
				Data = v26
			});
		end;
	end;
	local v27, v28, v29 = pairs(v21);
	while true do
		local v30, v31 = v27(v28, v29);
		if not v30 then
			break;
		end;
		for v32, v33 in pairs(v24) do
			if v33.ID == v30 then
				local v34 = {};
				for v35, v36 in pairs(v31) do
					table.insert(v34, {
						ID = v35, 
						Data = v36
					});
				end;
				table.sort(v34, function(p15, p16)
					return p15.ID < p16.ID;
				end);
				v24[v32].Data.RecipeList = v34;
				break;
			end;
		end;	
	end;
	table.sort(v24, function(p17, p18)
		local v37, v38, v39 = v1.CheckHasRecipe(p17.ID);
		local v40, v41, v42 = v1.CheckHasRecipe(p18.ID);
		return p18.Data.SortPriority < p17.Data.SortPriority;
	end);
	return v24;
end;
function v1.MakeMaterialFrame(p19, p20, p21, p22, p23)
	p21.Visible = true;
	local v43 = p21:FindFirstChild("Container") and p21;
	v43.Icon.Image = p20.Image;
	if not p23 then
		if tonumber(p22) then
			v43.Amount.Text = "x" .. p22;
			return;
		else
			v43.Amount.Text = p22[1] ~= p22[2] and p22[1] .. "-" .. p22[2] or p22[1];
			return;
		end;
	end;
	local v44, v45, v46, v47 = v1.CheckHasRecipe(p23);
	v43.Amount.Text = _G.PlayerData.Materials.Owned[p19] and _G.PlayerData.Materials.Owned[p19] > 0 and _G.PlayerData.Materials.Owned[p19] .. "/" .. p22 or "x" .. p22;
	v43.BorderColor3 = v47[p19] == "Completed" and Color3.new(0, 140, 0) or (v47[p19] == "Has" and Color3.new(1, 1, 0) or Color3.new(0, 0, 0));
	local v48 = nil
	if v47[p19] then
		v48 = 2;
	else
		v48 = 0;
	end;
	v43.BorderSizePixel = v48;
end;
function v1.MakeMaterialFrames(p24, p25, p26)
	local v49 = 1;
	for v50, v51 in pairs(_G.Database.Recipes[p24].Materials) do
		v1.MakeMaterialFrame(v50, _G.Database.Materials[v50], p25["Material" .. v49], v51, p26 and p24 or nil);
		v49 = v49 + 1;
	end;
end;
function v1.ActionConfirmButtonFunction()
	print("pressed");
	local v52 = nil
	if v1.Mode == "Craft" then
		v52 = u2;
	else
		v52 = u1;
	end;
	print(v52, u2, u1, v1.Mode);
	if v52 then
		v1[v1.Mode](v52);
	end;
end;
local u4 = require(game.ReplicatedStorage.Modules.GridCreator);
function v1.UpdateCraftConfirm(p27, p28, p29)
	local l__Action__53 = v1.GUI.Action;
	local l__Craft__54 = l__Action__53.Craft;
	if p27 and not p29 then
		local v55 = _G.Database.Recipes[p27];
		local v56 = v1.CheckHasRecipe(p27);
		v1.MakeMaterialFrames(p27, l__Craft__54.Recipe);
		u4.MakeItemFrame(l__Craft__54.Reward.Container, {
			ItemID = v55.RewardItem and v55
		});
		l__Action__53.Confirm.Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
		u2 = p27;
		return;
	end;
	for v57, v58 in pairs(l__Craft__54.Recipe:GetChildren()) do
		v58.Container.Icon.Image = "";
		v58.Container.Amount.Text = "";
	end;
	l__Craft__54.Reward.Container.Icon.Image = "";
	l__Craft__54.Reward.Container.Amount.Text = "";
	l__Craft__54.Reward.Container.ItemName.Text = "";
	l__Action__53.Confirm.Style = Enum.ButtonStyle.RobloxRoundButton;
	u2 = nil;
end;
local v59 = {};
function v1.UpdateCraftConfirmMobile(p30, p31, p32)
	if p32 == nil then
		p32 = not p31.Result.Confirm.Visible;
	end;
	if p32 == true then
		for v60, v61 in pairs(v1.RecipesFrame.Container:GetChildren()) do
			if v61 ~= p31 then
				v1.UpdateCraftConfirmMobile(nil, v61, false);
			end;
		end;
	end;
	if p31 then
		p31.Result.Confirm.Visible = p32;
		local v62 = nil
		if p32 then
			v62 = "Cancel";
		else
			v62 = "Craft";
		end;
		p31.Result.Container.Craft.Text = v62;
		p31.Result.Container.Craft.TextColor3 = p32 and Color3.new(1, 1, 1) or Color3.fromRGB(159, 255, 130);
	end;
end;
function v1.CheckSalvageable(p33)
	if not p33 then
		return false;
	end;
	local v63 = _G.Database.SalvageRewards[p33] or _G.Database.SalvageRewards[_G.Database.Item[p33].Rarity];
	local v64 = v63 and v63.Rewards;
	local v65 = not v3[p33];
	if v65 then
		if _G.Database.Item[p33].Event ~= nil then
			v65 = false;
			if _G.Database.SalvageRewards[p33] ~= nil then
				v65 = false;
				if _G.Database.Item[p33].Season == nil then
					v65 = false;
					if _G.Database.Item[p33].ItemType ~= "Misc" then
						v65 = v64;
					end;
				end;
			end;
		else
			v65 = false;
			if _G.Database.Item[p33].Season == nil then
				v65 = false;
				if _G.Database.Item[p33].ItemType ~= "Misc" then
					v65 = v64;
				end;
			end;
		end;
	end;
	return v65 and v64 or false;
end;
local u5 = game.ReplicatedStorage.GetSyncData:InvokeServer("Rarity");
function v1.ShowSalvageRewards(p34	)
	local v66 = v1.CheckSalvageable(p34);
	u4.MakeItemFrame(v1.SalvageConfirmFrame, {
		ItemID = p34
	});
	v1.SalvageConfirmFrame.Icon.ItemName.TextColor3 = v66 and u5[_G.Database.Item[p34].Rarity] or Color3.new(0.5, 0.5, 0.5);
	v1.SalvageConfirmFrame.Icon.ImageColor3 = v66 and Color3.new(1, 1, 1) or Color3.new(0.2, 0.2, 0.2);
	local v67 = v1.SalvageConfirmFrame:FindFirstChild("Rewards") or v1.SalvageConfirmFrame;
	for v68, v69 in pairs(v67:GetChildren()) do
		v69.Visible = false;
	end;
	print(tostring(v66));
	if v66 then
		u1 = p34;
		local v70 = 1;
		for v71, v72 in pairs(v66) do
			v1.MakeMaterialFrame(v71, _G.Database.Materials[v71], v67["Material" .. v70], v72.Amount);
			v70 = v70 + 1;
		end;
		print(tostring(u1));
	else
		u1 = nil;
	end;
	v1.SalvageConfirmButton.Style = u1 and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton;
end;
function v1.SalvageConfirmMobile(p35, p36)
	local v73 = not p36.Cancel.Visible;
	for v74, v75 in pairs(v1.SalvageInventoryFrame.Container:GetChildren()) do
		v75.Container.Cancel.Visible = false;
		v75.Container.BackgroundColor3 = Color3.fromRGB(54, 54, 54);
	end;
	p36.Cancel.Visible = v73;
	p36.BackgroundColor3 = v73 and Color3.fromRGB(130, 130, 130) or Color3.fromRGB(54, 54, 54);
	if v73 then
		v1.ShowSalvageRewards(p35);
	else
		v1.ShowSalvageRewards(nil);
	end;
	v1.SalvageConfirmFrame.Visible = v73;
end;
function v1.MakeSalvageItemFrame(p37, p38)
	u4.MakeItemFrame(p37, p38);
	local l__ItemID__76 = p38.ItemID;
	p37.Container.Cover.Visible = not v1.CheckSalvageable(l__ItemID__76);
	if p37.Container:FindFirstChild("Cancel") then
		p37.Container.Cancel.MouseButton1Click:connect(function()
			p37.Container.Cancel.Visible = false;
			p37.Container.BackgroundColor3 = Color3.fromRGB(54, 54, 54);
			v1.SalvageConfirmFrame.Visible = false;
		end);
	end;
	p37.Container.Button.MouseButton1Click:connect(function()
		v1.SalvageConfirm(l__ItemID__76, p37.Container);
	end);
end;
function v1.CreateRecipeFrame(p39, p40, p41)
	local l__Data__77 = p40.Data;
	local l__ID__78 = p40.ID;
	local l__Materials__79 = _G.Database.Materials;
	if not l__Data__77.CombinationRecipe then
		p39.RecipeName.Text = l__Data__77.Name;
		p39.RecipeName.TextColor3 = u5[l__Data__77.Rarity];
		p39.Result.Container.Icon.Image = l__Data__77.Image;
		v1.MakeMaterialFrames(l__ID__78, p39.Materials, true);
		local v80, v81, v82 = v1.CheckHasRecipe(l__ID__78);
		if v80 then
			p39.Complete.Visible = true;
			p39.Result.Container.Craft.Visible = true;
			p39.Result.Container.Craft.MouseButton1Click:connect(function()
				v1.CraftConfirm(l__ID__78, p39);
			end);
		elseif v81 then
			p39.InProgress.Visible = true;
		end;
		if p39.Result:FindFirstChild("Confirm") then
			p39.Result.Confirm.MouseButton1Click:connect(function()
				v1.Craft(l__ID__78, true);
			end);
		end;
		p39.Missing.Visible = not v81;
	end;
end;
function v1.GenerateSalvageInventory()
	u4.CreateGrid(v1.MakeSalvageItemFrame, v1.NewItemFrame, u4.GetSortedInventory(), v1.SalvageInventoryFrame);
end;
function v1.GenerateRecipes()
	u4.CreateList(v1.CreateRecipeFrame, v1.NewRecipeFrame, v1.GetRecipes(), v1.RecipesFrame);
end;
game.ReplicatedStorage.UpdateSalvageClient.Event:connect(function()
	v1.GenerateSalvageInventory();
end);
function v1.Salvage()
	local l__SalvageGUI__83 = v1.SalvageGUI;
	l__SalvageGUI__83.Claim.Style = Enum.ButtonStyle.RobloxRoundButton;
	l__SalvageGUI__83.Claim.Text = "Salvaging...";
	v1.GUI.Visible = false;
	_G.Process("Salvaging");
	local v84 = time();
	local v85 = game.ReplicatedStorage.Remotes.Inventory.Salvage:InvokeServer(u1);
	u1 = nil;
	v1.ShowSalvageRewards(nil);
	v1.GenerateSalvageInventory();
	v1.GenerateRecipes();
	local l__Container__86 = l__SalvageGUI__83.Main.Item1.Container;
	local l__Container__87 = l__SalvageGUI__83.Main.Item2.Container;
	local l__Container__88 = l__SalvageGUI__83.Main.Item3.Container;
	l__Container__86.Icon.Image = "";
	l__Container__86.ItemName.Text = "";
	l__Container__87.Icon.Image = "";
	l__Container__87.ItemName.Text = "";
	l__Container__88.Icon.Image = "";
	l__Container__88.ItemName.Text = "";
	wait(0.75 - (time() - v84));
	if v85 then
		_G.Process(nil);
		l__Container__86.Icon.Image = u4.GetImage(_G.Database.Item[u1].Image);
		l__Container__86.ItemName.Text = _G.Database.Item[u1].ItemName;
		l__Container__86.ItemName.TextColor3 = u5[_G.Database.Item[u1].Rarity];
		l__SalvageGUI__83.Visible = true;
		wait(0.5);
		l__Container__86.Slider:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.2);
		l__Container__87.Slider:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.2);
		l__Container__88.Slider:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.2);
		wait(0.5);
		for v89, v90 in pairs(v85) do
			local l__Container__91 = l__SalvageGUI__83.Main["Item" .. v89].Container;
			l__Container__91.Icon.Image = _G.Database.Materials[v90.ID].Image;
			l__Container__91.ItemName.Text = _G.Database.Materials[v90.ID].Name .. " [x" .. v90.Amount .. "]";
			l__Container__91.ItemName.TextColor3 = u5[_G.Database.Materials[v90.ID].Rarity];
		end;
		l__Container__86.Slider:TweenPosition(UDim2.new(0, 0, -1, 0), "Out", "Quad", 0.2);
		l__Container__87.Slider:TweenPosition(UDim2.new(0, 0, -1, 0), "Out", "Quad", 0.2);
		l__Container__88.Slider:TweenPosition(UDim2.new(0, 0, -1, 0), "Out", "Quad", 0.2);
		wait(0.4);
		l__SalvageGUI__83.Claim.Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
		l__SalvageGUI__83.Claim.Text = "Claim!";
		require(script.Parent.Christmas2018).GenerateInventory();
	end;
end;
function v1.Craft(p42, p43)
	v1.GUI.Visible = false;
	_G.Process("Crafting");
	local v92 = time();
	local v93, v94, v95 = game.ReplicatedStorage.Remotes.Inventory.Craft:InvokeServer(p42);
	v1.GenerateRecipes();
	if not v1.CheckHasRecipe(p42) then
		v1.CraftConfirm(nil, nil, true);
	end;
	wait(0.75 - (time() - v92));
	_G.Process(nil);
	v1.GUI.Visible = true;
	if _G.ViewLobbyFrame ~= nil then
		_G.ViewLobbyFrame("Inventory");
	end;
	if v93 then
		_G.NewItem(v93, "You Crafted...", v1.GUI, v95);
	end;
	game.ReplicatedStorage.UpdateSalvageClient:Fire();
end;
return v1;
