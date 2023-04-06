--[[VARIABLE DEFINITION ANOMALY DETECTED, DECOMPILATION OUTPUT POTENTIALLY INCORRECT]]--
-- Decompiled with the Synapse X Luau decompiler.

u1 = {
	GUI = {}, 
	MyInventory = {}, 
	CreateBlankInventoryTable = function()
		return {
			Weapons = {
				Current = {}, 
				Classic = {}, 
				Christmas = {}, 
				Halloween = {}
			}, 
			Effects = {
				Current = {}
			}, 
			Perks = {
				Current = {}
			}, 
			Emotes = {
				Current = {}
			}, 
			Radios = {
				Current = {}
			}, 
			Pets = {
				Current = {}
			}
		};
	end, 
	CreateBlankTradeInventoryTable = function()
		return {
			Weapons = {
				Current = {}
			}, 
			Pets = {
				Current = {}
			}
		};
	end, 
	CreateBlankInventorySort = function(p1)
		local v1 = {};
		for v2, v3 in pairs(p1) do
			v1[v2] = {};
			for v4, v5 in pairs(p1[v2]) do
				v1[v2][v4] = {};
			end;
		end;
		return v1;
	end, 
	CreateBlankInventory = function(p2)
		local v6 = {
			Data = p2 == "Trading" and u1.CreateBlankTradeInventoryTable() or u1.CreateBlankInventoryTable()
		};
		v6.Sort = u1.CreateBlankInventorySort(v6.Data);
		return v6;
	end, 
	CreateNewItemData = function(p3, p4, p5)
		local v7 = _G.Database[p5][p3];
		if v7 == nil then
			print("ERROR LOADING ITEM: " ..p5.." "..p3);
			return;
		end;
		local v8 = {};
		for v9, v10 in pairs(v7) do
			v8[v9] = v10;
		end;
		v8.Name = v7.ItemName or v7.Name;
		v8.Amount = p4;
		v8.DataID = p3;
		v8.DataType = p5;
		if v8.Rarity == nil then
			v8.Rarity = "Common";
		end;
		v8.Frame = nil;
		v8.LayoutOrder = 0;
		return v8;
	end
};
local u2 = {
	Weapons = true, 
	Pets = true
};
function u1.GenerateInventoryTables(p6, p7)
	local v11 = u1.CreateBlankInventory(p7);
	for v12, v13 in pairs(v11.Data) do
		local v14, v15, v16 = pairs(p6[v12].Owned);
		while true do
			local v17, v18 = v14(v15, v16);
			if not v17 then
				break;
			end;
			local v19 = u2[v12] and v17 or v18;
			local v20 = u1.CreateNewItemData(v19, tonumber(v18) and 1, v12);
			local v21 = nil;
			local v22 = nil
			if p7 == "Trading" then
				local v21 = "Current";
			else
				if v12 == "Weapons" then
					if not v22 then
						if v20.Season then
							v22 = "Current";
						elseif v12 == "Weapons" then
							v22 = "Classic";
						else
							v22 = "Current";
						end;
					end;
				elseif v20.Season then
					v22 = "Current";
				elseif v12 == "Weapons" then
					v22 = "Classic";
				else
					v22 = "Current";
				end;
				v21 = v22;
			end;
			v11.Data[v12][v21][v19] = v20;
			table.insert(v11.Sort[v12][v21], v19);		
		end;
	end;
	local v23, v24, v25 = pairs(p6.Uniques or {});
	while true do
		local v26, v27 = v23(v24, v25);
		if not v26 then
			break;
		end;
		local v28 = v27.BaseItem;
		if v27.EvoEquipped then
			local v29 = _G.Database.Weapons[v27.BaseItem];
			local v30 = 1;
			if v29.Evo[1].XPRequired <= v27.XP then
				v30 = 1;
			end;
			if v29.Evo[2].XPRequired <= v27.XP then
				v30 = 2;
			end;
			if v29.Evo[3].XPRequired <= v27.XP then
				v30 = 3;
			end;
			if v29.Evo[4].XPRequired <= v27.XP then
				v30 = 4;
			end;
			v28 = v29.Evo[v30].ItemName;
		end;
		local v31 = u1.CreateNewItemData(v28, 1, "Weapons");
		v31.Signature = v27.Signature and "";
		v31.Rank = v27.Rank;
		v31.EvoXP = v27.XP;
		v31.EvoEquipped = v27.EvoEquipped;
		local v32 = nil;
		if p7 == "Trading" then
			local v32 = "Current";
		else
			local v33 = v31.Event;
			if not v33 then
				if v31.Season then
					v33 = "Current";
				else
					v33 = "Classic";
				end;
			end;
			v32 = v33;
		end;
		v11.Data.Weapons[v32][v28] = v31;
		table.insert(v11.Sort.Weapons[v32], v28);	
	end;
	return v11;
end;
local l__Rarities__3 = _G.Database.Rarities;
function u1.SortTab(p8, p9, p10)
	for v34, v35 in pairs(p8.Sort[p9][p10]) do
		if p8.Data[p9][p10][v35] == nil then
			table.remove(p8.Sort[p9][p10], v34);
		end;
	end;
	table.sort(p8.Sort[p9][p10], function(p11, p12)
		local v36 = p8.Data[p9][p10][p11];
		local v37 = p8.Data[p9][p10][p12];
		if v36.DataID == "DefaultKnife" then
			return true;
		end;
		if v37.DataID == "DefaultKnife" then
			return false;
		end;
		if v37.DataID == "DefaultGun" then
			return false;
		end;
		if v36.DataID == "DefaultGun" and v37.DataID ~= "DefaultKnife" then
			return true;
		end;
		if v36.Rarity ~= v37.Rarity then
			return l__Rarities__3[v36.Rarity].Sort < l__Rarities__3[v37.Rarity].Sort;
		end;
		if v36.SortGroup and v37.SortGroup == nil then
			return true;
		end;
		if v37.SortGroup and v36.SortGroup == nil then
			return false;
		end;
		if v36.SortGroup and v37.SortGroup and v36.SortGroup ~= v37.SortGroup then
			return v36.SortGroup < v37.SortGroup;
		end;
		if v36.SortGroup and v37.SortGroup and v36.SortGroup == v37.SortGroup then
			return v36.SortWithinGroup < v37.SortWithinGroup;
		end;
		return v36.Name < v37.Name;
	end);
	for v38, v39 in pairs(p8.Sort[p9][p10]) do
		p8.Data[p9][p10][v39].LayoutOrder = v38;
		if p8.Data[p9][p10][v39].Frame ~= nil then
			p8.Data[p9][p10][v39].Frame.LayoutOrder = v38;
		end;
	end;
	return p8;
end;
function u1.SortInventory(p13)
	for v40, v41 in pairs(p13.Sort) do
		for v42, v43 in pairs(v41) do
			p13 = u1.SortTab(p13, v40, v42);
		end;
	end;
	return p13;
end;
local u4 = {
	Christmas = true, 
	Halloween = true
};
local u5 = require(game.ReplicatedStorage.Modules.ItemModule);
function u1.GenerateNewInventoryFrames(p14, p15, p16)
	for v44, v45 in pairs(p14.Data) do
		local v46, v47, v48 = pairs(v45);
		while true do
			local v49, v50 = v46(v47, v48);
			if not v49 then
				break;
			end;
			local v51 = p15:FindFirstChild(v44).Items.Container:FindFirstChild(v49) or p15:FindFirstChild(v44).Items.Container:FindFirstChild("Holiday").Container:FindFirstChild(v49);
			local v52 = v51:FindFirstChild("ItemSizer") or v51.Parent.Parent:FindFirstChild("ItemSizer");
			local v53 = nil;
			if v52 then
				v53 = v52.AbsoluteSize.Y;
			end;
			if u4[v49] then
				local v54 = (p16 or (u1.GUI.ItemGridLayout or script.ItemGridLayout)):Clone();
				v54.Parent = v51.Container;
				v54:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					v51.Size = UDim2.new(1, 0, 0, v54.AbsoluteContentSize.Y + 5 + 44);
				end);
				if v53 then
					local l__CellSize__55 = v54.CellSize;
					v54.CellSize = UDim2.new(l__CellSize__55.X.Scale, l__CellSize__55.X.Offset, 0, v53);
				end;
			else
				local v56 = (p16 or (u1.GUI.ItemGridLayout or script.ItemGridLayout)):Clone();
				v56.Parent = v51.Container;
				v56:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					v51.CanvasSize = UDim2.new(0, 0, 0, v56.AbsoluteContentSize.Y + 5);
				end);
				if v53 then
					local l__CellSize__57 = v56.CellSize;
					v56.CellSize = UDim2.new(l__CellSize__57.X.Scale, l__CellSize__57.X.Offset, 0, v53);
				end;
			end;
			for v58, v59 in pairs(v50) do
				if v59.Frame == nil then
					local v61 = game.Players.LocalPlayer.PlayerGui:FindFirstChild("MainGUI").Game.NewItem
					local v60 = script.NewItem:Clone();
					u5.DisplayItem(v60, v59, nil, true);
					v60.Parent = v61.Container;
					v60.LayoutOrder = v59.LayoutOrder;
					p14.Data[v44][v49][v58].Frame = v60;
				end;
			end;		
		end;
	end;
	return p14;
end;
function u1.ConnectEquipButtons()
	for v62, v63 in pairs(u1.MyInventory.Data) do
		for v64, v65 in pairs(v63) do
			for v66, v67 in pairs(v65) do
				local l__Frame__68 = v67.Frame;
				if l__Frame__68 and v67.EquipConnection == nil then
					u1.MyInventory.Data[v62][v64][v66].EquipConnection = l__Frame__68.Container.ActionButton.MouseButton1Click:connect(function()
						if v67.ItemType == "Misc" then
							return;
						end;
						if v62 == "Weapons" then
							local v69 = _G.Database.Weapons[v67.DataID];
							local l__EvoBaseID__70 = v69.EvoBaseID;
							if l__EvoBaseID__70 then
								local l__Evo__71 = _G.Database.Weapons[l__EvoBaseID__70].Evo;
								local l__EvoMenu__72 = u1.GUI.EvoMenu;
								l__EvoMenu__72.Container.TitleFrame.TitleLabel.Text = v69.ItemName .. " Evo";
								local v73 = 1;
								if l__Evo__71[1].XPRequired <= v67.EvoXP then
									v73 = 1;
								end;
								if l__Evo__71[2].XPRequired <= v67.EvoXP then
									v73 = 2;
								end;
								if l__Evo__71[3].XPRequired <= v67.EvoXP then
									v73 = 3;
								end;
								if l__Evo__71[4].XPRequired <= v67.EvoXP then
									v73 = 4;
								end;
								local v74, v75, v76 = pairs(l__Evo__71);
								while true do
									local v77, v78 = v74(v75, v76);
									if not v77 then
										break;
									end;
									local v79 = u1.GUI.EvoMenu.Container.EvoContainer:FindFirstChild("Evo" .. v77);
									local v80 = _G.Database.Weapons[v78.ItemName];
									u5.DisplayItem(v79, v80, nil, true);
									v79.ItemName.Label.Text = v80.Rarity;
									v79.Locked.Visible = v73 < v77;
									v79:SetAttribute("ItemID", v78.ItemName);
									v79:SetAttribute("ItemType", v67.ItemType);
									v79:SetAttribute("Locked", v73 < v77);								
								end;
								local v81 = v73 + 1;
								if l__Evo__71[v81] == nil then
									v81 = v73;
								end;
								l__EvoMenu__72.Container.XPFrame.XPLabel.Text = u5.Commafy(math.floor(v67.EvoXP)) .. " / " .. u5.Commafy(l__Evo__71[v81].XPRequired);
								local v82 = v67.EvoXP / l__Evo__71[v81].XPRequired;
								if v82 < 0 then
									v82 = 0;
								elseif v82 > 1 then
									v82 = 1;
								end;
								l__EvoMenu__72.Container.XPFrame.Background.XPBar.Size = UDim2.new(v82, 0, 1, 0);
								l__EvoMenu__72.Visible = true;
								return;
							else
								_G.PlayerData.Weapons.Equipped[v67.ItemType] = v67.DataID;
							end;
						else
							for v83, v84 in pairs(_G.PlayerData[v62].Equipped) do
								if v84 == v67.DataType then
									return;
								end;
							end;
							table.insert(_G.PlayerData[v62].Equipped, 1, v67.DataID);
							local v85 = #_G.PlayerData[v62].Equipped;
							if _G.PlayerData[v62].Slots < v85 then
								table.remove(_G.PlayerData[v62].Equipped, v85);
							end;
						end;
						u1.UpdateEquip(u1.GUI.MyInventory.Main, u1.MyInventory);
						game.ReplicatedStorage.Remotes.Inventory.Equip:FireServer(v67.DataID, v67.DataType);
					end);
				end;
			end;
		end;
	end;
end;
function u1.ConnectEvoMenu()
	u1.GUI.EvoMenu.Container.Close.MouseButton1Click:connect(function()
		u1.GUI.EvoMenu.Visible = false;
	end);
	for v86, v87 in pairs(u1.GUI.EvoMenu.Container.EvoContainer:GetChildren()) do
		if v87:IsA("Frame") then
			v87.Container.Button.MouseButton1Click:connect(function()
				local v88 = v87:GetAttribute("ItemID");
				local v89 = v87:GetAttribute("ItemType");
				if v87:GetAttribute("Locked") ~= true then
					_G.PlayerData.Weapons.Equipped[v89] = v88;
					u1.UpdateEquip(u1.GUI.MyInventory.Main, u1.MyInventory);
					game.ReplicatedStorage.Remotes.Inventory.Equip:FireServer(v88, "Weapons");
				end;
			end);
		end;
	end;
end;
function u1.GenerateInventory(p17, p18, p19, p20)
	return u1.GenerateNewInventoryFrames(u1.SortInventory((u1.GenerateInventoryTables(p18, p19))), p17.Main, p20);
end;
local u6 = { "Weapons", "Effects", "Perks", "Emotes", "Radios", "Pets" };
function u1.UpdateInventory(p21, p22)
	for v90, v91 in pairs(p22.Data) do
		for v92, v93 in pairs(v91) do
			local v94, v95, v96 = pairs(v93);
			while true do
				local v97, v98 = v94(v95, v96);
				if not v97 then
					break;
				end;
				local v99 = nil
				if v98.Rarity == "Unique" or v98.EvoEquipped then
					v99 = 1;
				else
					v99 = _G.PlayerData[v90].Owned[v97];
				end;
				for v100, v101 in pairs(_G.PlayerData[v90].Owned) do
					if v101 == v97 then
						v99 = 1;
					end;
				end;
				if v99 ~= nil and v99 > 0 then
					p22.Data[v90][v92][v97].Amount = v99;
					local v102 = nil
					if v99 then
						local v102 = v99 > 1 and "x" .. v99 or "";
					else
						v102 = "";
					end;
					p22.Data[v90][v92][v97].Frame.Container.Amount.Text = v102;
					if v98.Rarity == "Unique" then
						p22.Data[v90][v92][v97].Frame.Container.Amount.Text = v98.Rank and "#" .. v98.Rank or "";
					end;
				else
					p22.Data[v90][v92][v97].Frame:Destroy();
					p22.Data[v90][v92][v97] = nil;
				end;			
			end;
		end;
	end;
	local v103 = {};
	for v104, v105 in pairs(u6) do
		local v106, v107, v108 = pairs(_G.PlayerData[v105].Owned);
		while true do
			local v109, v110 = v106(v107, v108);
			if not v109 then
				break;
			end;
			local v111 = u2[v105] and v109 or v110;
			local v112 = tonumber(v110) and 1;
			local v113 = _G.Database[v105][v111];
			local v114 = nil
			if v105 == "Weapons" then
				v114 = v113.Event;
				if not v114 then
					if v113.Season then
						v114 = "Current";
					elseif v105 == "Weapons" then
						v114 = "Classic";
					else
						v114 = "Current";
					end;
				end;
			elseif v113.Season then
				v114 = "Current";
			elseif v105 == "Weapons" then
				v114 = "Classic";
			else
				v114 = "Current";
			end;
			if p22.Data[v105][v114][v111] == nil and v113.Rarity ~= "Unique" then
				local v115 = nil
				if v105 == "Weapons" then
					v115 = v113.Event;
					if not v115 then
						if v113.Season then
							v115 = "Current";
						elseif v105 == "Weapons" then
							v115 = "Classic";
						else
							v115 = "Current";
						end;
					end;
				elseif v113.Season then
					v115 = "Current";
				elseif v105 == "Weapons" then
					v115 = "Classic";
				else
					v115 = "Current";
				end;
				p22.Data[v105][v115][v111] = u1.CreateNewItemData(v111, v112, v105);
				table.insert(p22.Sort[v105][v114], v111);
				v103[v105] = v114;
			end;		
		end;
	end;
	if v103 then
		p22 = u1.SortInventory(p22);
		u1.GenerateNewInventoryFrames(p22, p21.Main);
		u1.ConnectEquipButtons();
	end;
end;
local u7 = {};
function u1.UpdateEquip(p23, p24)
	for v116, v117 in pairs(p24.Data) do
		if p23[v116]:FindFirstChild("Equipped") then
			for v118, v119 in pairs(p23[v116].Equipped.Container:GetChildren()) do
				if v119:FindFirstChild("Container") then
					v119.Container.Visible = false;
				end;
			end;
			if v116 == "Effects" and _G.PlayerData[v116].Equipped[1] == nil then
				p23[v116].Equipped.Container.DeathEffect.Visible = false;
			end;
			local v120, v121, v122 = pairs(_G.PlayerData[v116].Equipped);
			while true do
				local v123, v124 = v120(v121, v122);
				if not v123 then
					break;
				end;
				local v125 = p23[v116].Equipped.Container[tonumber(v123) and "Item" .. v123 or v123];
				local v126 = _G.Database[v116][v124];
				if v116 == "Effects" then
					p23[v116].Equipped.Container.DeathEffect.Visible = v126.DeathModule ~= nil;
					p23[v116].Equipped.Container.DeathEffect.Container2.EffectEnabled.Visible = _G.PlayerData.DeathEffect == true;
					p23[v116].Equipped.Container.DeathEffect.Container2.EffectDisabled.Visible = _G.PlayerData.DeathEffect == false;
				end;
				if v126 ~= nil then
					u5.DisplayItem(v125.Container, v126);
				end;
				v125.Container.Visible = v126 ~= nil;
				if p24 == u1.MyInventory and v125.Container:FindFirstChild("Unequip") then
					if u7[v125] then
						u7[v125]:disconnect();
						u7[v125] = nil;
					end;
					u7[v125] = v125.Container.Unequip.Button.MouseButton1Click:connect(function()
						table.remove(_G.PlayerData[v116].Equipped, v123);
						u1.UpdateMyEquip();
						game.ReplicatedStorage.Remotes.Inventory.Unequip:FireServer(v123, v116);
					end);
				end;			
			end;
		end;
	end;
	local u8 = time();
	p23.Effects.Equipped.Container.DeathEffect.Container2.EffectEnabled.MouseButton1Click:connect(function()
		if time() - u8 < 1 then
			return;
		end;
		game.ReplicatedStorage.Remotes.Inventory.ToggleDeathEffects:FireServer(false);
		_G.PlayerData.DeathEffect = false;
		p23.Effects.Equipped.Container.DeathEffect.Container2.EffectEnabled.Visible = false;
		p23.Effects.Equipped.Container.DeathEffect.Container2.EffectDisabled.Visible = true;
		u8 = time();
	end);
	p23.Effects.Equipped.Container.DeathEffect.Container2.EffectDisabled.MouseButton1Click:connect(function()
		if time() - u8 < 1 then
			return;
		end;
		game.ReplicatedStorage.Remotes.Inventory.ToggleDeathEffects:FireServer(true);
		_G.PlayerData.DeathEffect = true;
		p23.Effects.Equipped.Container.DeathEffect.Container2.EffectDisabled.Visible = false;
		p23.Effects.Equipped.Container.DeathEffect.Container2.EffectEnabled.Visible = true;
		u8 = time();
	end);
end;
function u1.UpdateMyEquip()
	u1.UpdateEquip(u1.GUI.MyInventory.Main, u1.MyInventory);
end;
function u1.ConnectNavButtons(p25, p26)
	local v127 = p25:GetChildren();
	for v128, v129 in pairs(v127) do
		if v129:IsA("TextButton") then
			v129.MouseButton1Click:connect(function()
				if v129.Name ~= "Close" then
					for v130, v131 in pairs(v127) do
						if v131:IsA("TextButton") then
							v131.Style = v131.Name == v129.Name and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton;
						end;
					end;
					for v132, v133 in pairs(p26:GetChildren()) do
						v133.Visible = v133.Name == v129.Name;
					end;
				end;
			end);
		end;
	end;
end;
function u1.ConnectTabButtons(p27, p28, p29, p30, p31)
	local v134 = p29 or p27.Main[p28];
	local v135 = p30 or v134.Items.Container;
	local v136 = v134:FindFirstChild("TitleBar") and v134.TitleBar.Container or (v134:FindFirstChild("Tabs") or v134.Items.Tabs);
	local l__SearchText__137 = v136.Search.Container.SearchText;
	local v138 = v136:GetChildren();
	for v139, v140 in pairs(v138) do
		if not v140:FindFirstChild("View") then
			v138[v139] = nil;
		end;
	end;
	for v141, v142 in pairs(v138) do
		local l__Name__9 = v142.Name;
		v142.View.MouseButton1Click:connect(function()
			l__SearchText__137.Text = "";
			local v143, v144, v145 = pairs(v138);
			while true do
				local v146, v147 = v143(v144, v145);
				if not v146 then
					break;
				end;
				v147.ViewBorder.Visible = v147.Name == l__Name__9;
				local v148 = nil
				if v147.Name == l__Name__9 then
					local v148 = 0.8;
				else
					v148 = 0.9;
				end;
				v147.BackgroundTransparency = v148;			
			end;
			for v149, v150 in pairs(v135:GetChildren()) do
				v150.Visible = v150.Name == l__Name__9;
			end;
		end);
	end;
end;
local u10 = nil;
function u1.ConnectCodeFrame(p32)
	p32.CodeBox.Changed:connect(function()
		local v151, v152, v153 = pairs(_G.Database.Codes);
		while true do
			local v154, v155 = v151(v152, v153);
			if not v154 then
				break;
			end;
			local v156 = p32.CodeBox.Text == v154;
			p32.Redeem.Style = v156 and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton;
			if v156 then
				u10 = "Normal";
				return;
			end;		
		end;
		p32.CodeBox.Text = string.gsub(p32.CodeBox.Text, "%s+", "");
		p32.CodeBox.Text = string.gsub(p32.CodeBox.Text, "~", "");
		local v157 = false;
		if string.len(p32.CodeBox.Text) == 7 then
			v157 = string.sub(p32.CodeBox.Text, 4, 4) == "-";
		end;
		p32.Redeem.Style = v157 and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton;
		local v158 = nil
		if v157 then
			local v158 = "Shirt";
		else
			v158 = nil;
		end;
		u10 = v158;
	end);
	p32.Redeem.MouseButton1Click:connect(function()
		u1.Redeem(p32);
	end);
end;
function u1.Redeem(p33)
	if u10 ~= nil then
		p33.CodeBox.Text = "Redeeming...";
		p33.Redeem.Style = Enum.ButtonStyle.RobloxRoundButton;
		local v159, v160 = game.ReplicatedStorage.Remotes.Extras.RedeemCode:InvokeServer(p33.CodeBox.Text, (tostring(u10)));
		p33.CodeBox.Text = v159;
		if v160 then
			for v161, v162 in pairs(v160) do
				_G.NewItem(v162.ID, "You Got...", _G.Windows.FrameNames.Inventory, v162.Type);
			end;
			game.ReplicatedStorage.UpdateDataClient:Fire();
		end;
	end;
end;
function u1.ConnectPetNaming(p34)
	p34.PetNameBox.Text = _G.PlayerData.PetName;
	p34.Confirm.MouseButton1Click:connect(function()
		local l__Text__163 = p34.PetNameBox.Text;
		if not (string.len(l__Text__163) <= 20) then
			p34.PetNameBox.Text = "Name too long";
			return;
		end;
		_G.PlayerData.PetName = l__Text__163;
		game.ReplicatedStorage.RenamePet:FireServer(l__Text__163);
	end);
end;
return u1;
