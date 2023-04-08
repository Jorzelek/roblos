-- Decompiled with the Synapse X Luau decompiler.

Module = {
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
			Data = p2 == "Trading" and Module.CreateBlankTradeInventoryTable() or Module.CreateBlankInventoryTable()
		};
		v6.Sort = Module.CreateBlankInventorySort(v6.Data);
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
function Module.GenerateInventoryTables(p6, p7)
	local inventoryData = Module.CreateBlankInventory(p7)
	for itemType, itemData in pairs(inventoryData.Data) do
		local ownedItems = p6[itemType].Owned
		for itemName, itemCount in pairs(ownedItems) do
			local itemSubtype = u2[itemType] and itemName or itemCount
			local item = Module.CreateNewItemData(itemSubtype, tonumber(itemCount) and 1, itemType)

			local itemSeason = item.Season
			local itemSubcategory = "Current"
			if p7 ~= "Trading" then
				if itemType == "Weapons" then
					if not itemSeason then
						itemSubcategory = "Classic"
					end
				elseif itemSeason then
					itemSubcategory = "Current"
				else
					itemSubcategory = "Classic"
				end
			end
			itemData[itemSubcategory] = itemData[itemSubcategory] or {}
			itemData[itemSubcategory][itemSubtype] = itemData[itemSubcategory][itemSubtype] or {}
			itemData[itemSubcategory][itemSubtype] = item
			if not inventoryData.Sort[itemType][itemSubcategory] then
				inventoryData.Sort[itemType][itemSubcategory] = {}
			end
			table.insert(inventoryData.Sort[itemType][itemSubcategory], itemSubtype)
		end
	end

	for _, uniqueItem in pairs(p6.Uniques or {}) do
		local baseItem = uniqueItem.BaseItem
		if uniqueItem.EvoEquipped then
			local weaponData = _G.Database.Weapons[baseItem]
			local evoLevel = 1
			for i = 1, 4 do
				if weaponData.Evo[i].XPRequired <= uniqueItem.XP then
					evoLevel = i
				end
			end
			baseItem = weaponData.Evo[evoLevel].ItemName
		end

		local item = Module.CreateNewItemData(baseItem, 1, "Weapons")
		item.Signature = uniqueItem.Signature and ""
		item.Rank = uniqueItem.Rank
		item.EvoXP = uniqueItem.XP
		item.EvoEquipped = uniqueItem.EvoEquipped

		local itemSeason = item.Season
		local itemSubcategory = "Current"
		if p7 ~= "Trading" then
			if not item.Event and itemSeason then
				itemSubcategory = "Current"
			elseif not item.Event and not itemSeason then
				itemSubcategory = "Classic"
			elseif item.Event then
				itemSubcategory = item.Event
			end
		end

		inventoryData.Data.Weapons[itemSubcategory][baseItem] = item
		table.insert(inventoryData.Sort.Weapons[itemSubcategory], baseItem)
	end

	return inventoryData
end
local l__Rarities__3 = _G.Database.Rarities;
function Module.SortTab(p8, p9, p10)
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
function Module.SortInventory(p13)
	for v40, v41 in pairs(p13.Sort) do
		for v42, v43 in pairs(v41) do
			p13 = Module.SortTab(p13, v40, v42);
		end;
	end;
	return p13;
end;
local u4 = {
	Christmas = true, 
	Halloween = true
};
local u5 = require(game.ReplicatedStorage.Modules.ItemModule);
function Module.GenerateNewInventoryFrames(p14, p15, p16)
	local itemGridLayout = p16 or (Module.GUI.ItemGridLayout or script.ItemGridLayout)
	for category, subcategories in pairs(p14.Data) do
		for subcategory, items in pairs(subcategories) do
			local subcategoryContainer = p15:FindFirstChild(category).Items.Container:FindFirstChild(subcategory) or p15:FindFirstChild(category).Items.Container:FindFirstChild("Holiday").Container:FindFirstChild(subcategory)
			local itemSizer = subcategoryContainer:FindFirstChild("ItemSizer") or subcategoryContainer.Parent.Parent:FindFirstChild("ItemSizer")
			local itemHeight = itemSizer and itemSizer.AbsoluteSize.Y or nil
			print("1 | "..subcategoryContainer.Parent)
			if u4[subcategory] then
				local layout = itemGridLayout:Clone()
				layout.Parent = subcategoryContainer.Container

				layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					subcategoryContainer.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 5 + 44)
				end)

				if itemHeight then
					local cellSize = layout.CellSize
					layout.CellSize = UDim2.new(cellSize.X.Scale, cellSize.X.Offset, 0, itemHeight)
				end
			else
				local layout = itemGridLayout:Clone()
				print("2 | "..subcategoryContainer.Parent)
				layout.Parent = subcategoryContainer.Container

				layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					subcategoryContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 5)
				end)

				if itemHeight then
					local cellSize = layout.CellSize
					layout.CellSize = UDim2.new(cellSize.X.Scale, cellSize.X.Offset, 0, itemHeight)
				end
			end

			for _, itemData in ipairs(items) do
				if not itemData.Frame then
					local newItem = game.Players.LocalPlayer.PlayerGui:FindFirstChild("MainGUI").Game.NewItem
					local newItemFrame = script.NewItem:Clone()
					u5.DisplayItem(newItemFrame, itemData, nil, true)
					newItemFrame.Parent = newItem.Container
					newItemFrame.LayoutOrder = itemData.LayoutOrder
					itemData.Frame = newItemFrame
				end
			end
		end
	end

	return p14
end
function Module.ConnectEquipButtons()
	for _, category in pairs(Module.MyInventory.Data) do
		for _, itemData in pairs(category) do
			for _, item in pairs(itemData) do
				local frame = item.Frame
				if frame and not item.EquipConnection then
					item.EquipConnection = frame.Container.ActionButton.MouseButton1Click:connect(function()
						if item.ItemType == "Misc" then
							return
						end
						if category == "Weapons" then
							local weapon = _G.Database.Weapons[item.DataID]
							local evoBaseID = weapon.EvoBaseID
							if evoBaseID then
								local evo = _G.Database.Weapons[evoBaseID].Evo
								local evoMenu = Module.GUI.EvoMenu
								evoMenu.Container.TitleFrame.TitleLabel.Text = weapon.ItemName .. " Evo"
								local currentEvoLevel = 1
								for i, evoLevel in pairs(evo) do
									if evoLevel.XPRequired <= item.EvoXP then
										currentEvoLevel = i
									end
								end
								for i, evoLevel in pairs(evo) do
									local evoFrame = evoMenu.Container.EvoContainer:FindFirstChild("Evo" .. i)
									u5.DisplayItem(evoFrame, _G.Database.Weapons[evoLevel.ItemName], nil, true)
									evoFrame.ItemName.Label.Text = _G.Database.Weapons[evoLevel.ItemName].Rarity
									evoFrame.Locked.Visible = currentEvoLevel < i
									evoFrame:SetAttribute("ItemID", evoLevel.ItemName)
									evoFrame:SetAttribute("ItemType", item.ItemType)
									evoFrame:SetAttribute("Locked", currentEvoLevel < i)
								end
								local nextEvoLevel = evo[currentEvoLevel + 1] or evo[currentEvoLevel]
								evoMenu.Container.XPFrame.XPLabel.Text = u5.Commafy(math.floor(item.EvoXP)) .. " / " .. u5.Commafy(nextEvoLevel.XPRequired)
								local xpRatio = math.clamp(item.EvoXP / nextEvoLevel.XPRequired, 0, 1)
								evoMenu.Container.XPFrame.Background.XPBar.Size = UDim2.new(xpRatio, 0, 1, 0)
								evoMenu.Visible = true
								return
							else
								_G.PlayerData.Weapons.Equipped[item.ItemType] = item.DataID
							end
						else
							for _, equippedItem in pairs(_G.PlayerData[category].Equipped) do
								if equippedItem == item.DataType then
									return
								end
							end
							table.insert(_G.PlayerData[category].Equipped, 1, item.DataID)
							local equippedCount = #_G.PlayerData[category].Equipped
							if _G.PlayerData[category].Slots < equippedCount then
								table.remove(_G.PlayerData[category].Equipped, equippedCount)
							end
						end
						Module.UpdateEquip(Module.GUI.MyInventory.Main, Module.MyInventory);
						game.ReplicatedStorage.Remotes.Inventory.Equip:FireServer(item.DataID, item.DataType);
					end);
				end;
			end;
		end;
	end;
end;
function Module.ConnectEvoMenu()
	Module.GUI.EvoMenu.Container.Close.MouseButton1Click:connect(function()
		Module.GUI.EvoMenu.Visible = false;
	end);
	for v86, v87 in pairs(Module.GUI.EvoMenu.Container.EvoContainer:GetChildren()) do
		if v87:IsA("Frame") then
			v87.Container.Button.MouseButton1Click:connect(function()
				local v88 = v87:GetAttribute("ItemID");	
				local v89 = v87:GetAttribute("ItemType");
				if v87:GetAttribute("Locked") ~= true then
					_G.PlayerData.Weapons.Equipped[v89] = v88;
					Module.UpdateEquip(Module.GUI.MyInventory.Main, Module.MyInventory);
					game.ReplicatedStorage.Remotes.Inventory.Equip:FireServer(v88, "Weapons");
				end;
			end);
		end;
	end;
end;
function Module.GenerateInventory(p17, p18, p19, p20)
	return Module.GenerateNewInventoryFrames(Module.SortInventory((Module.GenerateInventoryTables(p18, p19))), p17.Main, p20);
end;
local u6 = { "Weapons", "Effects", "Perks", "Emotes", "Radios", "Pets" };
function Module.UpdateInventory(p21, p22)
	for v90 = 1, #p22.Data do
		local pData = p22.Data[v90]
		for v92 = 1, #pData do
			local v93 = pData[v92]
			for v97, v98 in pairs(v93) do
				local v99 = nil
				if v98.Rarity == "Unique" or v98.EvoEquipped then
					v99 = 1
				else
					v99 = _G.PlayerData[v90].Owned[v97]
				end
				if v99 and v99 > 0 then
					pData[v92][v97].Amount = v99
					local v102 = v99 > 1 and "x" .. v99 or ""
					pData[v92][v97].Frame.Container.Amount.Text = v102
					if v98.Rarity == "Unique" then
						pData[v92][v97].Frame.Container.Amount.Text = v98.Rank and "#" .. v98.Rank or ""
					end
				else
					pData[v92][v97].Frame:Destroy()
					pData[v92][v97] = nil
				end
			end
		end
	end
	local v103 = {};
	for itemKey, itemValue in pairs(u6) do
		local playerdata = _G.PlayerData[itemValue].Owned
		local databaseItem = _G.Database[itemValue]
		local p22Data = p22.Data[itemValue]
		local p22Sort = p22.Sort[itemValue]
		local v103 = {}
		for ownedItemKey, ownedItemValue in pairs(_G.PlayerData) do
			local itemName = u2[itemValue] and ownedItemKey or ownedItemValue
			local itemQuantity = tonumber(ownedItemValue) and 1
			local databaseItemData = databaseItem[itemName]

			if not p22Data[itemName] and databaseItemData.Rarity ~= "Unique" then
				local itemEvent = nil
				if itemValue == "Weapons" then
					itemEvent = databaseItemData.Event or databaseItemData.Season and "Current" or "Classic"
				end

				p22Data[itemName] = Module.CreateNewItemData(itemName, itemQuantity, itemValue)
				table.insert(p22Sort[itemEvent or itemValue], itemName)
				v103[itemValue] = itemEvent or itemValue
			end
		end
	end
	if v103 then
		p22 = Module.SortInventory(p22);
		Module.GenerateNewInventoryFrames(p22, p21.Main);
		Module.ConnectEquipButtons();
	end;
end;
local u7 = {};
function Module.UpdateEquip(p23, p24)
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
				if p24 == Module.MyInventory and v125.Container:FindFirstChild("Unequip") then
					if u7[v125] then
						u7[v125]:disconnect();
						u7[v125] = nil;
					end;
					u7[v125] = v125.Container.Unequip.Button.MouseButton1Click:connect(function()
						table.remove(_G.PlayerData[v116].Equipped, v123);
						Module.UpdateMyEquip();
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
function Module.UpdateMyEquip()
	Module.UpdateEquip(Module.GUI.MyInventory.Main, Module.MyInventory);
end;
function Module.ConnectNavButtons(p25, p26)
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
function Module.ConnectTabButtons(p27, p28, p29, p30, p31)
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
function Module.ConnectCodeFrame(p32)
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
		Module.Redeem(p32);
	end);
end;
function Module.Redeem(p33)
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
function Module.ConnectPetNaming(p34)
	p34.PetNameBox.Text = _G.PlayerData.PetName;
	p34.Confirm.MouseButton1Click:connect(function()
		local l__Text__163 = p34.PetNameBox.Text;
		if not (string.len(l__Text__163) <= 20) then
			p34.PetNameBox.Text = "Name too long";
			return;
		end;
		_G.PlayerData.PetName = l__Text__163;
		game.ReplicatedStorage.Remotes.Inventory.RenamePet:FireServer(l__Text__163);
	end);
end;
return Module;
