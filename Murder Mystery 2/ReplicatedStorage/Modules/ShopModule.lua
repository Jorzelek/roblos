local Module = {
	GUI = {}
}

local BoxModule = require(game.ReplicatedStorage.Modules.BoxModule)
local XboxModule = require(game.ReplicatedStorage.Modules.XboxModule)

function Module.CheckOwned(itemId, player)
	if  not (player == "Weapons" or player == "Pets" or player == "MysteryBox" or player == "Eggs" or player == "Item") then
		if _G.PlayerData[player].Owned[itemId] then
			return true
		else
			for _, ownedItemId in pairs(_G.PlayerData[player].Owned) do
				if ownedItemId == itemId then
					return true
				end
			end
			return false
		end
	end
	return false
end
function Module.SelectObject()

end;
local ShopData = _G.Database.Shop;
function Module.BuyItem(itemPrice, currencyType, playerBalance, playerData)
	local v6 = ShopData[currencyType][itemPrice];
	local v7 = v6.DataType and currencyType;
	local l__Price__8 = v6.Price;
	local v9 = nil
	local v10 = nil
	local v16 = nil;
	if playerBalance == "Coins" or playerBalance == "Gems" then
		v9 = l__Price__8[playerBalance] <= _G.PlayerData[playerBalance];
	else
		v9 = l__Price__8[playerBalance] <= (_G.PlayerData.Materials.Owned[playerBalance] and 0);
	end;
	if v9 then
		if v7 ~= "Weapons" and v7 ~= "Pets" and v7 ~= "MysteryBox" and v7 ~= "Eggs" and v7 ~= "Item" then
			if _G.PlayerData[v7].Owned[itemPrice] then
				v10 = true;
			else
				local v11, v12, v13 = pairs(_G.PlayerData[v7].Owned);
				while true do
					local v14, v15 = v11(v12, v13);
					if not v14 then
						v10 = false;
						break;
					end;
					v13 = v14;
					if v15 == itemPrice then
						v10 = true;
						break;
					end;				
				end;
			end;
		else
			v10 = false;
		end;
		if not v10 then
			playerData.PriceFrame[playerBalance].Visible = false;
			playerData.PriceFrame.PurchaseLoading.LayoutOrder = playerData.PriceFrame[playerBalance].LayoutOrder;
			playerData.PriceFrame.PurchaseLoading.Visible = true;
			spawn(function()
				while playerData.PriceFrame.PurchaseLoading.Visible == true do
					playerData.PriceFrame.PurchaseLoading.Container.Spinner.Rotation = playerData.PriceFrame.PurchaseLoading.Container.Spinner.Rotation + 5;
					game:GetService("RunService").RenderStepped:wait();				
				end;
			end);
			print(v7);
			playerData.PriceFrame.PurchaseLoading.Visible = false;
			if game.ReplicatedStorage.Remotes.Shop.BuyItem:InvokeServer(itemPrice, currencyType, playerBalance) then
				if v6.ExchangeAmount then
					itemPrice = "CoinVisual";
				end;
				_G.NewItem(itemPrice, "You Got...", Module.GUI.ShopFrame, v7);
				Module.UpdateShopFrames();
			end;
			Module.SelectObject(true);
			return;
		end;
	end;
	if v7 ~= "Weapons" and v7 ~= "Pets" and v7 ~= "MysteryBox" and v7 ~= "Eggs" and v7 ~= "Item" then
		if _G.PlayerData[v7].Owned[itemPrice] then
			v16 = true;
		else
			local v17, v18, v19 = pairs(_G.PlayerData[v7].Owned);
			while true do
				local v20, v21 = v17(v18, v19);
				if not v20 then
					v16 = false;
					break;
				end;
				v19 = v20;
				if v21 == itemPrice then
					v16 = true;
					break;
				end;			
			end;
		end;
	else
		v16 = false;
	end;
	if v16 then
		Module.SelectObject();
		return;
	end;
	if playerBalance == "Gems" and l__Price__8.Gems ~= nil then
		Module.SelectObject();
		Module.ViewGems(l__Price__8.Gems - _G.PlayerData.Gems);
	end;
end;
local u2 = require(script.Parent.ItemModule);
local l__Featured__3 = _G.Database.Featured;
local u4 = "Featured";
local l__HotItems__5 = script.HotItems;
function Module.GenerateHotItems()
	function Module.GenerateFeaturedBox()
		u2.DisplayItem(Module.GUI.FeaturedFrame.Box.ItemFrame.ItemContainer, _G.Database.MysteryBox[l__Featured__3.Box]);
		local l__Box__22 = _G.Database.Featured.Box;
		local u6 = _G.Database.MysteryBox[l__Box__22];
		local u7 = _G.Database.Shop.Weapons[l__Box__22];
		Module.GUI.Main.Featured.Box.ItemFrame.ItemContainer.Container.ActionButton.MouseButton1Click:connect(function()
			u4 = "Featured";
			Module.ViewBoxContents(l__Box__22, u6, u7);
		end);
		Module.GUI.Main.Featured.Box.Buy.MouseButton1Click:Connect(function()
			u4 = "Featured";
			Module.ViewBoxContents(l__Box__22, u6, u7);
		end);
		for v23, v24 in pairs(Module.GUI.Main.Featured.Box.ItemFrame.Price:GetChildren()) do
			if v24:IsA("Frame") then
				local l__Name__25 = v24.Name;
				v24.Visible = u7.Price[l__Name__25] ~= nil;
				v24.PriceFrame.PriceLabel.Text = u2.Commafy(u7.Price[l__Name__25] and 0);
			end;
		end;
	end;
	Module.GenerateFeaturedBox();
	Module.GUI.HotItemsContainer:ClearAllChildren();
	local v26 = (Module.GUI.HotItemLayout or l__HotItems__5.HotItemLayout):Clone();
	v26.Parent = Module.GUI.HotItemsContainer;
	local l__ItemSizer__27 = Module.GUI.HotItemsContainer.Parent.Parent:FindFirstChild("ItemSizer");
	if l__ItemSizer__27 then
		local l__CellSize__28 = v26.CellSize;
		v26.CellSize = UDim2.new(0, l__ItemSizer__27.AbsoluteSize.X, l__CellSize__28.Y.Scale, l__CellSize__28.Y.Offset);
	end;
	local v29, v30, v31 = pairs(l__Featured__3.HotItems);
	while true do
		local v32, v33 = v29(v30, v31);
		if not v32 then
			break;
		end;
		local v34 = (Module.GUI.NewHotItem or l__HotItems__5.NewHotItem):Clone();
		local v35 = _G.Database[v33.Type][v33.ItemID];
		u2.DisplayItem(v34, v35);
		local v36 = _G.Database.Shop[v33.Type];
		if v36 then
			local v37 = v36[v33.ItemID];
			if v37 then
				if v37.Price then
					local v38 = v37.Price.Gems or v37.Price.Coins;
					if v38 then
						local v39 = nil
						v34.Tags.Price.PriceFrame.Amount.Text = u2.Commafy(v38);
						if v37.Price.Gems ~= nil then
							v39 = "Gems";
						else
							v39 = "Coins";
						end;
						v34.Tags.Price.Icon.Image = _G.Database.Currencies[v39];
						v34.Tags.Price.Visible = true;
					else
						v34.Tags.Price.Visible = false;
					end;
				end;
				v34.Container.ActionButton.MouseButton1Click:connect(function()
					Module.OpenBuyPopup(v33.ItemID, v35, ShopData[v33.Type][v33.ItemID].DataType or v33.Type, v33.Type, v37);
				end);
			end;
		end;
		v34.Container.New.Visible = v35.New == true;
		v34.Parent = Module.GUI.HotItemsContainer;	
	end;
end;
function Module.SelectItemToPurchase(itemId, itemName, itemDescription, itemPrice, itemImage)
	u2.DisplayItem(itemId.ItemFrame.ItemContainer, itemDescription);
	local v40 = true;
	if itemImage.Description == nil then
		v40 = itemDescription.Description ~= nil;
	end;
	itemId.Description.Visible = v40;
	itemId.Description.TextLabel.Text = itemImage.Description or (itemDescription.Description or "");
	itemId.BuyTitle.Visible = true;
	local v41 = nil;
	if itemPrice ~= "Weapons" and itemPrice ~= "Pets" and itemPrice ~= "MysteryBox" and itemPrice ~= "Eggs" and itemPrice ~= "Item" then
		if _G.PlayerData[itemPrice].Owned[itemName] then
			v41 = true;
		else
			local v42, v43, v44 = pairs(_G.PlayerData[itemPrice].Owned);
			while true do
				local v45, v46 = v42(v43, v44);
				if not v45 then
					v41 = false;
					break;
				end;
				v44 = v45;
				if v46 == itemName then
					v41 = true;
					break;
				end;			
			end;
		end;
	else
		v41 = false;
	end;
	for v47, v48 in pairs(itemId.PriceFrame:GetChildren()) do
		if _G.Database.Currencies[v48.Name] ~= nil then
			local l__Name__49 = v48.Name;
			v48.Visible = itemImage.Price[l__Name__49] ~= nil;
			v48.Container.PriceFrame.PriceLabel.Text = itemImage.Price[l__Name__49] and u2.Commafy(itemImage.Price[l__Name__49]) or "";
			local v50 = nil
			if not v41 then
				if l__Name__49 == "Coins" and itemImage.Price.Coins ~= nil then
					v50 = _G.PlayerData.Coins < itemImage.Price.Coins and Enum.ButtonStyle.RobloxRoundButton or Enum.ButtonStyle.RobloxRoundDefaultButton;
				end;
			else
				v50 = Enum.ButtonStyle.RobloxRoundButton or Enum.ButtonStyle.RobloxRoundDefaultButton;
			end;
			v48.Buy.Style = v50;
		end;
	end;
	local v51 = nil
	if v41 then
		v51 = "OWNED";
	else
		v51 = "Buy It Now!";
	end;
	itemId.PriceFrame.BuyTitle.Title.Text = v51;
	local v52 = false;
	if itemImage.Price.Gems ~= nil then
		v52 = false;
		if itemImage.Price.Coins == nil then
			v52 = _G.PlayerData.Gems < (itemImage.Price and itemImage.Price.Gems or 0);
		end;
	end;
	itemId.PriceFrame.GetMoreGems.Visible = v52;
end;
local u8 = {};
function Module.OpenBuyPopup(itemId, itemName, itemDescription, itemPrice, itemImage)
	Module.SelectItemToPurchase(Module.GUI.Main.BuyPopup.Container, itemId, itemName, itemDescription, itemImage);
	u8 = {
		ItemID = itemId, 
		ItemData = itemName, 
		ItemType = itemDescription, 
		ShopType = itemPrice, 
		ItemShopData = itemImage
	};
	Module.GUI.Main.BuyPopup.Visible = true;
end;
local u9 = {};
function Module.GenerateShopItems()
	local v53, v54, v55 = pairs(ShopData);
	while true do
		local v56, v57 = v53(v54, v55);
		if not v56 then
			break;
		end;
		local l__ScrollFrame__58 = Module.GUI.Main[v56].ScrollFrame;
		l__ScrollFrame__58.Container:ClearAllChildren();
		local v59 = (Module.GUI.ShopItemLayout or script.ShopTabs.ItemGridLayout):Clone();
		v59.Parent = l__ScrollFrame__58.Container;
		v59:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			l__ScrollFrame__58.CanvasSize = UDim2.new(0, 0, 0, v59.AbsoluteContentSize.Y + 5);
		end);
		local l__ItemSizer__60 = l__ScrollFrame__58:FindFirstChild("ItemSizer");
		if l__ItemSizer__60 then
			local l__CellSize__61 = v59.CellSize;
			v59.CellSize = UDim2.new(l__CellSize__61.X.Scale, l__CellSize__61.X.Offset, 0, l__ItemSizer__60.AbsoluteSize.Y);
		end;
		local v62, v63, v64 = pairs(v57);
		while true do
			local v65, v66 = v62(v63, v64);
			if not v65 then
				break;
			end;
			local v67 = v66.DataType and v56;
			local v68 = _G.Database[v67][v65];
			if v68 ~= nil then
				local v69 = script.ShopTabs.NewItem:Clone();
				u2.DisplayItem(v69, v68);
				v69.Container.Icon.SizeConstraint = v68.ImageRelative and Enum.SizeConstraint[v68.ImageRelative] or v69.Container.Icon.SizeConstraint;
				local v70 = nil;
				if v67 ~= "Weapons" and v67 ~= "Pets" and v67 ~= "MysteryBox" and v67 ~= "Eggs" and v67 ~= "Item" then
					if _G.PlayerData[v67].Owned[v65] then
						v70 = true;
					else
						local v71, v72, v73 = pairs(_G.PlayerData[v67].Owned);
						while true do
							local v74, v75 = v71(v72, v73);
							if not v74 then
								v70 = false;
								break;
							end;
							v73 = v74;
							if v75 == v65 then
								v70 = true;
								break;
							end;						
						end;
					end;
				else
					v70 = false;
				end;
				if v70 then
					v69.Tags.Owned.Visible = true;
				else
					for v76, v77 in pairs(v66.Price) do
						local v78 = v69.Tags:FindFirstChild(v76);
						if v78 then
							v78.Container.PriceFrame.PriceLabel.Text = u2.Commafy(v77);
							v78.Visible = true;
						end;
					end;
				end;
				v69.Container.ActionButton.MouseButton1Click:connect(function()
					if v66.DataType == "MysteryBox" then
						u4 = "Weapons";
						Module.ViewBoxContents(v65, v68, v66);
						return;
					end;
					if v66.DataType ~= "Eggs" then
						Module.OpenBuyPopup(v65, v68, v67, v56, v66);
						return;
					end;
					u4 = "Pets";
					Module.ViewBoxContents(v65, v68, v66);
				end);
				v69.Parent = l__ScrollFrame__58.Container;
				local v79 = nil
				if v67 ~= "Weapons" and v67 ~= "Pets" and v67 ~= "MysteryBox" and v67 ~= "Eggs" and v67 ~= "Item" then
					if _G.PlayerData[v67].Owned[v65] then
						v79 = true;
					else
						local v80, v81, v82 = pairs(_G.PlayerData[v67].Owned);
						while true do
							local v83, v84 = v80(v81, v82);
							if not v83 then
								v79 = false;
								break;
							end;
							v82 = v83;
							if v84 == v65 then
								v79 = true;
								break;
							end;						
						end;
					end;
				else
					v79 = false;
				end;
				local v85 = nil
				if v79 then
					v85 = 20000;
				else
					v85 = 0;
				end;
				v69.LayoutOrder = (v66.LayoutOrder or (v66.Price.Gems or v66.Price.Coins and v66.Price.Coins + 10000)) + v85;
				u9[v56] = u9[v56] or {};
				u9[v56][v65] = {
					DataType = v56, 
					Frame = v69
				};
			end;		
		end;	
	end;
end;
function Module.UpdateShopFrames()
	for v86, v87 in pairs(u9) do
		if v86 ~= "Weapons" and v86 ~= "Pets" then
			local v88, v89, v90 = pairs(v87);
			while true do
				local v91, v92 = v88(v89, v90);
				if not v91 then
					break;
				end;
				local v93 = nil;
				if v86 ~= "Weapons" and v86 ~= "Pets" and v86 ~= "MysteryBox" and v86 ~= "Eggs" and v86 ~= "Item" then
					if _G.PlayerData[v86].Owned[v91] then
						v93 = true;
					else
						local v94, v95, v96 = pairs(_G.PlayerData[v86].Owned);
						while true do
							local v97, v98 = v94(v95, v96);
							if not v97 then
								v93 = false;
								break;
							end;
							v96 = v97;
							if v98 == v91 then
								v93 = true;
								break;
							end;						
						end;
					end;
				else
					v93 = false;
				end;
				if v93 then
					for v99, v100 in pairs(v92.Frame.Tags:GetChildren()) do
						if v100:IsA("Frame") then
							v100.Visible = v100.Name == "Owned";
						end;
					end;
				end;			
			end;
		end;
	end;
end;
local u10 = "Featured";
local u11 = nil;
local u12 = nil;
local u13 = nil;
function Module.ViewBoxContents(boxName, boxContents, playerInventory)
	if boxName == "Christmas2019Box" then
		_G.Windows.ViewFrame(_G.Windows.FrameNames.Christmas2019);
		_G.ViewHalloweenBox();
		if game:GetService("UserInputService").GamepadEnabled then
			_G.ReturnToHWBox();
		end;
		return;
	end;
	if _G.MobileDevice == "Phone" then
		for v101, v102 in pairs(Module.GUI.Main:GetChildren()) do
			v102.Visible = v102.Name == "Weapons";
		end;
		u10 = "Weapons";
		if Module.GUI.ShopFrame.Title:FindFirstChild("Back") then
			Module.GUI.ShopFrame.Title.Back.Visible = true;
			Module.GUI.ShopFrame.Title.Title.Visible = false;
		end;
	end;
	u11 = boxName;
	u12 = boxContents;
	u13 = playerInventory;
	u10 = boxContents.BoxType;
	u2.DisplayItem(Module.GUI.ViewBoxFrame.BoxFrame.ItemContainer, boxContents);
	for v103, v104 in pairs(boxContents.RarityChances) do
		Module.GUI.ViewBoxFrame.BoxFrame.RarityFrame[v103].Chance.Text = v104 .. "%";
	end;
	Module.GUI.ViewBoxFrame.BuyFrame.GetKeys.Visible = playerInventory.Price.Key ~= nil;
	for v105, v106 in pairs(Module.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container:GetChildren()) do
		if v106:IsA("TextButton") then
			v106.Visible = playerInventory.Price[v106.Name] ~= nil;
			local v107 = u2.Commafy(playerInventory.Price[v106.Name] and 0);
			if tonumber(v107) == 1 then
				v107 = "x" .. v107;
			end;
			v106.Cost.Text = v107;
			if v106.Name == "Coins" then
				v106.Style = (playerInventory.Price[v106.Name] and 0) <= _G.PlayerData.Coins and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton;
			end;
		end;
	end;
	for v108, v109 in pairs(Module.GUI.Main:GetChildren()) do
		v109.Visible = v109.Name == "ViewCrate";
	end;
	Module.GUI.Nav.Container[u10].NotSelected.Visible = false;
	Module.GUI.Nav.Container[u10].IsSelected.Visible = false;
	Module.GUI.Nav.Container[u10].Back.Visible = true;
	local v110 = Module.GUI.ViewBoxFrame.BoxContents:FindFirstChild("Container") or Module.GUI.ViewBoxFrame.BoxContents.ScrollingFrame.Container;
	v110:ClearAllChildren();
	local v111 = (Module.GUI.BoxContentsLayout or script.ViewBoxContents.BoxContentsLayout):Clone();
	v111.Parent = v110;
	if v110.Parent:IsA("ScrollingFrame") then
		v111:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			v110.Parent.CanvasSize = UDim2.new(0, 0, 0, v111.AbsoluteContentSize.Y + 5);
		end);
	end;
	local l__ItemSizer__112 = v110.Parent:FindFirstChild("ItemSizer");
	if l__ItemSizer__112 then
		local l__CellSize__113 = v111.CellSize;
		v111.CellSize = UDim2.new(l__CellSize__113.X.Scale, l__CellSize__113.X.Offset, 0, l__ItemSizer__112.AbsoluteSize.Y);
	end;
	local v114, v115, v116 = pairs(boxContents.Contents);
	while true do
		local v117, v118 = v114(v115, v116);
		if not v117 then
			break;
		end;
		local v119 = (Module.GUI.NewBoxContent or script.ViewBoxContents.NewBoxContents):Clone();
		u2.DisplayItem(v119, _G.Database[boxContents.BoxType][v118]);
		v119.LayoutOrder = v117;
		v119.Parent = v110;
		local l__BoxType__120 = boxContents.BoxType;
		local v121 = nil;
		if _G.PlayerData[l__BoxType__120].Owned[v118] then
			v121 = true;
		else
			local v122, v123, v124 = pairs(_G.PlayerData[l__BoxType__120].Owned);
			while true do
				local v125, v126 = v122(v123, v124);
				if not v125 then
					v121 = false;
					break;
				end;
				v124 = v125;
				if v126 == v118 then
					v121 = true;
					break;
				end;			
			end;
		end;
		v119.Tags.Owned.Visible = v121;	
	end;
end;
function Module.ViewBoxContentsXbox(boxName, boxContents, playerInventory)
	u11 = boxName;
	u12 = boxContents;
	u13 = playerInventory;
end;
function Module.ConnectNavButtons()
	local v127 = {};
	for v128, v129 in pairs(Module.GUI.Nav.Container:GetChildren()) do
		if v129:IsA("TextButton") then
			table.insert(v127, v129);
		end;
	end;
	function Module.ResetNavButtons()
		for v130, v131 in pairs(v127) do
			v131.IsSelected.Visible = false;
			v131.NotSelected.Visible = true;
			v131.Back.Visible = false;
		end;
	end;
	function Module.ViewFeatured()
		Module.ResetNavButtons();
		for v132, v133 in pairs(Module.GUI.Main:GetChildren()) do
			v133.Visible = v133.Name == "Featured";
		end;
		u10 = "Featured";
	end;
	for v134, v135 in pairs(v127) do
		v135.MouseButton1Click:connect(function()
			if u10 == v135.Name then
				if Module.GUI.ViewBoxFrame.Parent.Visible == true then
					if u4 == "Weapons" or u4 == "Pets" then
						v135.Back.Visible = false;
						v135.IsSelected.Visible = true;
						for v136, v137 in pairs(Module.GUI.Main:GetChildren()) do
							v137.Visible = v137.Name == u4;
						end;
						return;
					else
						Module.ViewFeatured();
						return;
					end;
				else
					Module.ViewFeatured();
					return;
				end;
			end;
			local v138, v139, v140 = pairs(v127);
			while true do
				local v141, v142 = v138(v139, v140);
				if not v141 then
					break;
				end;
				v142.IsSelected.Visible = v142 == v135;
				v142.NotSelected.Visible = v142 ~= v135;
				v142.Back.Visible = false;			
			end;
			for v143, v144 in pairs(Module.GUI.Main:GetChildren()) do
				v144.Visible = v144.Name == v135.Name;
			end;
			u10 = v135.Name;
		end);
	end;
	if Module.GUI.ShopFrame.Title:FindFirstChild("Back") then
		Module.GUI.ShopFrame.Title.Back.Visible = true;
		Module.GUI.ShopFrame.Title.Title.Visible = false;
	end;
end;
function Module.ConnectNavButtonsPhone()
	local v145 = {};
	for v146, v147 in pairs(Module.GUI.Nav.Container:GetChildren()) do
		if v147:IsA("TextButton") then
			table.insert(v145, v147);
		end;
	end;
	function Module.ResetNavButtons()

	end;
	for v148, v149 in pairs(v145) do
		v149.MouseButton1Click:connect(function()
			for v150, v151 in pairs(Module.GUI.Main:GetChildren()) do
				v151.Visible = v151.Name == v149.Name;
			end;
			u10 = v149.Name;
			if Module.GUI.ShopFrame.Title:FindFirstChild("Back") then
				Module.GUI.ShopFrame.Title.Back.Visible = true;
				Module.GUI.ShopFrame.Title.Title.Visible = false;
			end;
		end);
	end;
	Module.GUI.ShopFrame.Title.Gems.More.MouseButton1Click:connect(function()
		Module.GUI.ShopFrame.Title.Back.Visible = true;
		Module.GUI.ShopFrame.Title.Title.Visible = false;
	end);
	Module.GUI.ShopFrame.Title.Gems.GetMore.MouseButton1Click:connect(function()
		Module.GUI.ShopFrame.Title.Back.Visible = true;
		Module.GUI.ShopFrame.Title.Title.Visible = false;
	end);
end;
function Module.PurchaseBox(boxId, playerBalance, playerData)
	if playerBalance.BoxType == "Pets" then
		Module.PurchaseEgg(boxId, playerBalance, playerData);
		return;
	end;
	Module.GUI.ShopFrame.Visible = false;
	_G.Process("Unboxing");
	local v152 = game.ReplicatedStorage.Remotes.Shop.OpenCrate:InvokeServer(boxId, "MysteryBox", playerData);
	wait(0.75 - (time() - time()));
	Module.GUI.Processing.Visible = false;
	if v152 then
		game.ReplicatedStorage.Remotes.Shop.BoxController:Fire(boxId, v152);
	end;
end;
function Module.PurchaseEgg(boxId, playerBalance, playerData)
	Module.GUI.ShopFrame.Visible = false;
	_G.Process("Unboxing");
	local v153 = game.ReplicatedStorage.Remotes.Shop.OpenCrate:InvokeServer(boxId, "Eggs", playerData);
	wait(0.75 - (time() - time()));
	Module.GUI.Processing.Visible = false;
	if v153 then
		game.ReplicatedStorage.Remotes.Shop.EggController:Fire(boxId, v153);
	end;
end;
function Module.ConnectViewBoxFrame()
	Module.GUI.ViewBoxFrame.BuyFrame.GetKeys.MouseButton1Click:connect(function()
		Module.OpenBuyPopup("Key", _G.Database.Weapons.Key, "Item", "Weapons", _G.Database.Shop.Weapons.Key);
	end);
	Module.GUI.ViewBoxFrame.BuyFrame.GetKeys.Amount.Text = "You have " .. (_G.PlayerData.Weapons.Owned.Key and 0) .. " Keys";
	game.ReplicatedStorage.UpdateDataClient.Event:connect(function(p29, itemPrice0)
		if not p29 then
			Module.GUI.ViewBoxFrame.BuyFrame.GetKeys.Amount.Text = "You have " .. (_G.PlayerData.Weapons.Owned.Key and 0) .. " Keys";
		end;
	end);
	Module.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.Coins.MouseButton1Click:connect(function()
		if u13.Price.Coins <= _G.PlayerData.Coins then
			Module.PurchaseBox(u11, u12, "Coins");
			_G.LastShopSelection = Module.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.Coins;
		end;
	end);
	Module.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.Key.MouseButton1Click:connect(function()
		if u13.Price.Key <= (_G.PlayerData.Weapons.Owned.Key and 0) then
			Module.PurchaseBox(u11, u12, "Key");
			_G.LastShopSelection = Module.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.Key;
			return;
		end;
		Module.OpenBuyPopup("Key", _G.Database.Weapons.Key, "Item", "Weapons", _G.Database.Shop.Weapons.Key);
	end);
	Module.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.Gems.MouseButton1Click:connect(function()
		if not (u13.Price.Gems <= _G.PlayerData.Gems) then
			Module.ViewGems(u13.Price.Gems - _G.PlayerData.Gems);
			return;
		end;
		Module.PurchaseBox(u11, u12, "Gems");
		_G.LastShopSelection = Module.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.Gems;
	end);
	Module.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.Candies2022.MouseButton1Click:connect(function()
		if not (u13.Price.Candies2022 <= (_G.PlayerData.Materials.Owned.Candies2022 and 0)) then
			if _G.ViewCandies then
				_G.ViewCandies();
			end;
			return;
		end;
		Module.PurchaseBox(u11, u12, "Candies2022");
		_G.LastShopSelection = Module.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.Candies2022;
	end);
	Module.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.ReaverKey2021.MouseButton1Click:connect(function()
		if not (u13.Price.ReaverKey2021 <= (_G.PlayerData.Materials.Owned.ReaverKey2021 and 0)) then
			if _G.ViewBattlePass then
				_G.ViewBattlePass();
			end;
			return;
		end;
		Module.PurchaseBox(u11, u12, "ReaverKey2021");
		_G.LastShopSelection = Module.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.ReaverKey2021;
	end);
	Module.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.SnowTokens2021.MouseButton1Click:connect(function()
		if not (u13.Price.SnowTokens2021 <= (_G.PlayerData.Materials.Owned.SnowTokens2021 and 0)) then
			if _G.ViewPurchaseCurrency then
				_G.ViewPurchaseCurrency();
			end;
			return;
		end;
		Module.PurchaseBox(u11, u12, "SnowTokens2021");
		_G.LastShopSelection = Module.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.SnowTokens2021;
	end);
	Module.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.SnowKey2021.MouseButton1Click:connect(function()
		if not (u13.Price.SnowKey2021 <= (_G.PlayerData.Materials.Owned.SnowKey2021 and 0)) then
			if _G.ViewBattlePass then
				_G.ViewBattlePass();
			end;
			return;
		end;
		Module.PurchaseBox(u11, u12, "SnowKey2021");
		_G.LastShopSelection = Module.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.SnowKey2021;
	end);
end;
function Module.ConnectBuyPopup()
	Module.GUI.Main.BuyPopup.Container.Close.MouseButton1Click:connect(function()
		Module.GUI.Main.BuyPopup.Visible = false;
	end);
	Module.GUI.Main.BuyPopup.Container.PriceFrame.Gems.Buy.MouseButton1Click:connect(function()
		if u8 then
			Module.BuyItem(u8.ItemID, u8.ShopType, "Gems", Module.GUI.Main.BuyPopup.Container);
			Module.GUI.Main.BuyPopup.Visible = false;
		end;
	end);
	Module.GUI.Main.BuyPopup.Container.PriceFrame.Coins.Buy.MouseButton1Click:connect(function()
		if u8 then
			Module.BuyItem(u8.ItemID, u8.ShopType, "Coins", Module.GUI.Main.BuyPopup.Container);
			Module.GUI.Main.BuyPopup.Visible = false;
		end;
	end);
	Module.GUI.Main.BuyPopup.Container.PriceFrame.SnowTokens2021.Buy.MouseButton1Click:connect(function()
		if u8 then
			Module.BuyItem(u8.ItemID, u8.ShopType, "SnowTokens2021", Module.GUI.Main.BuyPopup.Container);
			Module.GUI.Main.BuyPopup.Visible = false;
		end;
	end);
	Module.GUI.Main.BuyPopup.Container.PriceFrame.Candies2022.Buy.MouseButton1Click:connect(function()
		if u8 then
			Module.BuyItem(u8.ItemID, u8.ShopType, "Candies2022", Module.GUI.Main.BuyPopup.Container);
			Module.GUI.Main.BuyPopup.Visible = false;
		end;
	end);
	Module.GUI.Main.BuyPopup.Container.PriceFrame.GetMoreGems.Buy.MouseButton1Click:connect(function()
		Module.ViewGems(ShopData[u8.ShopType][u8.ItemID].Price.Gems - _G.PlayerData.Gems);
	end);
end;
function Module.HighlightGem(itemPrice1)
	if not itemPrice1 then return end
	local gems = Module.GUI.Main.Gems:GetChildren()
	table.sort(gems, function(a, b) return tonumber(a.Name) < tonumber(b.Name) end)
	for i, gem in ipairs(gems) do
		if itemPrice1 <= tonumber(gem.Name) then
			print("RQ", gem.Name, itemPrice1)
			spawn(function()
				gem:TweenPosition(UDim2.new(gem.Position.X.Scale, gem.Position.X.Offset, gem.Position.Y.Scale, gem.Position.Y.Offset - 30), "Out", "Sine", 0.3)
				wait(0.31)
				gem:TweenPosition(UDim2.new(gem.Position.X.Scale, gem.Position.X.Offset, gem.Position.Y.Scale, gem.Position.Y.Offset + 30), "In", "Sine", 0.3)
				wait(0.31)
				gem.Position = gem.Position
			end)
			return
		end
	end
end
function Module.ViewGems(itemPrice4)
	Module.ResetNavButtons();
	for v175, v176 in pairs(Module.GUI.Main:GetChildren()) do
		v176.Visible = v176.Name == "Gems";
	end;
	u10 = "Gems";
	Module.HighlightGem(itemPrice4);
end;
function Module.ConnectGems()
	for v177, v178 in pairs(Module.GUI.Main.Gems:GetChildren()) do
		v178.MouseButton1Click:connect(function()
			script.Click:Play();
			game.ReplicatedStorage.Remotes.Shop.PurchaseProduct:FireServer(v178.Name, "Gems");
		end);
	end;
	Module.GUI.Title.Gems.GetMore.MouseButton1Click:connect(function()
		Module.ViewGems();
	end);
end;
return Module;
