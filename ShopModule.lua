-- Decompiled with the Synapse X Luau decompiler.

local v1 = {
	GUI = {}
};
local v2 = require(game.ReplicatedStorage.Modules.BoxModule);
local v3 = require(game.ReplicatedStorage.Modules.XboxModule);
function v1.CheckOwned(p1, p2)
	if p2 ~= "Weapons" and p2 ~= "Pets" and p2 ~= "MysteryBox" and p2 ~= "Eggs" and p2 ~= "Item" then
		if _G.PlayerData[p2].Owned[p1] then
			return true;
		else
			for v4, v5 in pairs(_G.PlayerData[p2].Owned) do
				if v5 == p1 then
					return true;
				end;
			end;
			return false;
		end;
	end;
	return false;
end;
function v1.SelectObject()

end;
local l__Shop__1 = _G.Database.Shop;
function v1.BuyItem(p3, p4, p5, p6)
	local v6 = l__Shop__1[p4][p3];
	local v7 = v6.DataType and p4;
	local l__Price__8 = v6.Price;
	local v9 = nil
	local v10 = nil
	local v16 = nil;
	if p5 == "Coins" or p5 == "Gems" then
		v9 = l__Price__8[p5] <= _G.PlayerData[p5];
	else
		v9 = l__Price__8[p5] <= (_G.PlayerData.Materials.Owned[p5] and 0);
	end;
	if v9 then
		if v7 ~= "Weapons" and v7 ~= "Pets" and v7 ~= "MysteryBox" and v7 ~= "Eggs" and v7 ~= "Item" then
			if _G.PlayerData[v7].Owned[p3] then
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
					if v15 == p3 then
						v10 = true;
						break;
					end;				
				end;
			end;
		else
			v10 = false;
		end;
		if not v10 then
			p6.PriceFrame[p5].Visible = false;
			p6.PriceFrame.PurchaseLoading.LayoutOrder = p6.PriceFrame[p5].LayoutOrder;
			p6.PriceFrame.PurchaseLoading.Visible = true;
			spawn(function()
				while p6.PriceFrame.PurchaseLoading.Visible == true do
					p6.PriceFrame.PurchaseLoading.Container.Spinner.Rotation = p6.PriceFrame.PurchaseLoading.Container.Spinner.Rotation + 5;
					game:GetService("RunService").RenderStepped:wait();				
				end;
			end);
			print(v7);
			p6.PriceFrame.PurchaseLoading.Visible = false;
			if game.ReplicatedStorage.Remotes.Shop.BuyItem:InvokeServer(p3, p4, p5) then
				if v6.ExchangeAmount then
					p3 = "CoinVisual";
				end;
				_G.NewItem(p3, "You Got...", v1.GUI.ShopFrame, v7);
				v1.UpdateShopFrames();
			end;
			v1.SelectObject(true);
			return;
		end;
	end;
	if v7 ~= "Weapons" and v7 ~= "Pets" and v7 ~= "MysteryBox" and v7 ~= "Eggs" and v7 ~= "Item" then
		if _G.PlayerData[v7].Owned[p3] then
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
				if v21 == p3 then
					v16 = true;
					break;
				end;			
			end;
		end;
	else
		v16 = false;
	end;
	if v16 then
		v1.SelectObject();
		return;
	end;
	if p5 == "Gems" and l__Price__8.Gems ~= nil then
		v1.SelectObject();
		v1.ViewGems(l__Price__8.Gems - _G.PlayerData.Gems);
	end;
end;
local u2 = require(script.Parent.ItemModule);
local l__Featured__3 = _G.Database.Featured;
local u4 = "Featured";
local l__HotItems__5 = script.HotItems;
function v1.GenerateHotItems()
	function v1.GenerateFeaturedBox()
		u2.DisplayItem(v1.GUI.FeaturedFrame.Box.ItemFrame.ItemContainer, _G.Database.MysteryBox[l__Featured__3.Box]);
		local l__Box__22 = _G.Database.Featured.Box;
		local u6 = _G.Database.MysteryBox[l__Box__22];
		local u7 = _G.Database.Shop.Weapons[l__Box__22];
		v1.GUI.Main.Featured.Box.ItemFrame.ItemContainer.Container.ActionButton.MouseButton1Click:connect(function()
			u4 = "Featured";
			v1.ViewBoxContents(l__Box__22, u6, u7);
		end);
		v1.GUI.Main.Featured.Box.Buy.MouseButton1Click:Connect(function()
			u4 = "Featured";
			v1.ViewBoxContents(l__Box__22, u6, u7);
		end);
		for v23, v24 in pairs(v1.GUI.Main.Featured.Box.ItemFrame.Price:GetChildren()) do
			if v24:IsA("Frame") then
				local l__Name__25 = v24.Name;
				v24.Visible = u7.Price[l__Name__25] ~= nil;
				v24.PriceFrame.PriceLabel.Text = u2.Commafy(u7.Price[l__Name__25] and 0);
			end;
		end;
	end;
	v1.GenerateFeaturedBox();
	v1.GUI.HotItemsContainer:ClearAllChildren();
	local v26 = (v1.GUI.HotItemLayout or l__HotItems__5.HotItemLayout):Clone();
	v26.Parent = v1.GUI.HotItemsContainer;
	local l__ItemSizer__27 = v1.GUI.HotItemsContainer.Parent.Parent:FindFirstChild("ItemSizer");
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
		local v34 = (v1.GUI.NewHotItem or l__HotItems__5.NewHotItem):Clone();
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
					v1.OpenBuyPopup(v33.ItemID, v35, l__Shop__1[v33.Type][v33.ItemID].DataType or v33.Type, v33.Type, v37);
				end);
			end;
		end;
		v34.Container.New.Visible = v35.New == true;
		v34.Parent = v1.GUI.HotItemsContainer;	
	end;
end;
function v1.SelectItemToPurchase(p7, p8, p9, p10, p11)
	u2.DisplayItem(p7.ItemFrame.ItemContainer, p9);
	local v40 = true;
	if p11.Description == nil then
		v40 = p9.Description ~= nil;
	end;
	p7.Description.Visible = v40;
	p7.Description.TextLabel.Text = p11.Description or (p9.Description or "");
	p7.BuyTitle.Visible = true;
	local v41 = nil;
	if p10 ~= "Weapons" and p10 ~= "Pets" and p10 ~= "MysteryBox" and p10 ~= "Eggs" and p10 ~= "Item" then
		if _G.PlayerData[p10].Owned[p8] then
			v41 = true;
		else
			local v42, v43, v44 = pairs(_G.PlayerData[p10].Owned);
			while true do
				local v45, v46 = v42(v43, v44);
				if not v45 then
					v41 = false;
					break;
				end;
				v44 = v45;
				if v46 == p8 then
					v41 = true;
					break;
				end;			
			end;
		end;
	else
		v41 = false;
	end;
	for v47, v48 in pairs(p7.PriceFrame:GetChildren()) do
		if _G.Database.Currencies[v48.Name] ~= nil then
			local l__Name__49 = v48.Name;
			v48.Visible = p11.Price[l__Name__49] ~= nil;
			v48.Container.PriceFrame.PriceLabel.Text = p11.Price[l__Name__49] and u2.Commafy(p11.Price[l__Name__49]) or "";
			local v50 = nil
			if not v41 then
				if l__Name__49 == "Coins" and p11.Price.Coins ~= nil then
					v50 = _G.PlayerData.Coins < p11.Price.Coins and Enum.ButtonStyle.RobloxRoundButton or Enum.ButtonStyle.RobloxRoundDefaultButton;
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
	p7.PriceFrame.BuyTitle.Title.Text = v51;
	local v52 = false;
	if p11.Price.Gems ~= nil then
		v52 = false;
		if p11.Price.Coins == nil then
			v52 = _G.PlayerData.Gems < (p11.Price and p11.Price.Gems or 0);
		end;
	end;
	p7.PriceFrame.GetMoreGems.Visible = v52;
end;
local u8 = {};
function v1.OpenBuyPopup(p12, p13, p14, p15, p16)
	v1.SelectItemToPurchase(v1.GUI.Main.BuyPopup.Container, p12, p13, p14, p16);
	u8 = {
		ItemID = p12, 
		ItemData = p13, 
		ItemType = p14, 
		ShopType = p15, 
		ItemShopData = p16
	};
	v1.GUI.Main.BuyPopup.Visible = true;
end;
local u9 = {};
function v1.GenerateShopItems()
	local v53, v54, v55 = pairs(l__Shop__1);
	while true do
		local v56, v57 = v53(v54, v55);
		if not v56 then
			break;
		end;
		local l__ScrollFrame__58 = v1.GUI.Main[v56].ScrollFrame;
		l__ScrollFrame__58.Container:ClearAllChildren();
		local v59 = (v1.GUI.ShopItemLayout or script.ShopTabs.ItemGridLayout):Clone();
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
						v1.ViewBoxContents(v65, v68, v66);
						return;
					end;
					if v66.DataType ~= "Eggs" then
						v1.OpenBuyPopup(v65, v68, v67, v56, v66);
						return;
					end;
					u4 = "Pets";
					v1.ViewBoxContents(v65, v68, v66);
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
function v1.UpdateShopFrames()
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
function v1.ViewBoxContents(p17, p18, p19)
	if p17 == "Christmas2019Box" then
		_G.Windows.ViewFrame(_G.Windows.FrameNames.Christmas2019);
		_G.ViewHalloweenBox();
		if game:GetService("UserInputService").GamepadEnabled then
			_G.ReturnToHWBox();
		end;
		return;
	end;
	if _G.MobileDevice == "Phone" then
		for v101, v102 in pairs(v1.GUI.Main:GetChildren()) do
			v102.Visible = v102.Name == "Weapons";
		end;
		u10 = "Weapons";
		if v1.GUI.ShopFrame.Title:FindFirstChild("Back") then
			v1.GUI.ShopFrame.Title.Back.Visible = true;
			v1.GUI.ShopFrame.Title.Title.Visible = false;
		end;
	end;
	u11 = p17;
	u12 = p18;
	u13 = p19;
	u10 = p18.BoxType;
	u2.DisplayItem(v1.GUI.ViewBoxFrame.BoxFrame.ItemContainer, p18);
	for v103, v104 in pairs(p18.RarityChances) do
		v1.GUI.ViewBoxFrame.BoxFrame.RarityFrame[v103].Chance.Text = v104 .. "%";
	end;
	v1.GUI.ViewBoxFrame.BuyFrame.GetKeys.Visible = p19.Price.Key ~= nil;
	for v105, v106 in pairs(v1.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container:GetChildren()) do
		if v106:IsA("TextButton") then
			v106.Visible = p19.Price[v106.Name] ~= nil;
			local v107 = u2.Commafy(p19.Price[v106.Name] and 0);
			if tonumber(v107) == 1 then
				v107 = "x" .. v107;
			end;
			v106.Cost.Text = v107;
			if v106.Name == "Coins" then
				v106.Style = (p19.Price[v106.Name] and 0) <= _G.PlayerData.Coins and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton;
			end;
		end;
	end;
	for v108, v109 in pairs(v1.GUI.Main:GetChildren()) do
		v109.Visible = v109.Name == "ViewCrate";
	end;
	v1.GUI.Nav.Container[u10].NotSelected.Visible = false;
	v1.GUI.Nav.Container[u10].IsSelected.Visible = false;
	v1.GUI.Nav.Container[u10].Back.Visible = true;
	local v110 = v1.GUI.ViewBoxFrame.BoxContents:FindFirstChild("Container") or v1.GUI.ViewBoxFrame.BoxContents.ScrollingFrame.Container;
	v110:ClearAllChildren();
	local v111 = (v1.GUI.BoxContentsLayout or script.ViewBoxContents.BoxContentsLayout):Clone();
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
	local v114, v115, v116 = pairs(p18.Contents);
	while true do
		local v117, v118 = v114(v115, v116);
		if not v117 then
			break;
		end;
		local v119 = (v1.GUI.NewBoxContent or script.ViewBoxContents.NewBoxContents):Clone();
		u2.DisplayItem(v119, _G.Database[p18.BoxType][v118]);
		v119.LayoutOrder = v117;
		v119.Parent = v110;
		local l__BoxType__120 = p18.BoxType;
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
function v1.ViewBoxContentsXbox(p20, p21, p22)
	u11 = p20;
	u12 = p21;
	u13 = p22;
end;
function v1.ConnectNavButtons()
	local v127 = {};
	for v128, v129 in pairs(v1.GUI.Nav.Container:GetChildren()) do
		if v129:IsA("TextButton") then
			table.insert(v127, v129);
		end;
	end;
	function v1.ResetNavButtons()
		for v130, v131 in pairs(v127) do
			v131.IsSelected.Visible = false;
			v131.NotSelected.Visible = true;
			v131.Back.Visible = false;
		end;
	end;
	function v1.ViewFeatured()
		v1.ResetNavButtons();
		for v132, v133 in pairs(v1.GUI.Main:GetChildren()) do
			v133.Visible = v133.Name == "Featured";
		end;
		u10 = "Featured";
	end;
	for v134, v135 in pairs(v127) do
		v135.MouseButton1Click:connect(function()
			if u10 == v135.Name then
				if v1.GUI.ViewBoxFrame.Parent.Visible == true then
					if u4 == "Weapons" or u4 == "Pets" then
						v135.Back.Visible = false;
						v135.IsSelected.Visible = true;
						for v136, v137 in pairs(v1.GUI.Main:GetChildren()) do
							v137.Visible = v137.Name == u4;
						end;
						return;
					else
						v1.ViewFeatured();
						return;
					end;
				else
					v1.ViewFeatured();
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
			for v143, v144 in pairs(v1.GUI.Main:GetChildren()) do
				v144.Visible = v144.Name == v135.Name;
			end;
			u10 = v135.Name;
		end);
	end;
	if v1.GUI.ShopFrame.Title:FindFirstChild("Back") then
		v1.GUI.ShopFrame.Title.Back.Visible = true;
		v1.GUI.ShopFrame.Title.Title.Visible = false;
	end;
end;
function v1.ConnectNavButtonsPhone()
	local v145 = {};
	for v146, v147 in pairs(v1.GUI.Nav.Container:GetChildren()) do
		if v147:IsA("TextButton") then
			table.insert(v145, v147);
		end;
	end;
	function v1.ResetNavButtons()

	end;
	for v148, v149 in pairs(v145) do
		v149.MouseButton1Click:connect(function()
			for v150, v151 in pairs(v1.GUI.Main:GetChildren()) do
				v151.Visible = v151.Name == v149.Name;
			end;
			u10 = v149.Name;
			if v1.GUI.ShopFrame.Title:FindFirstChild("Back") then
				v1.GUI.ShopFrame.Title.Back.Visible = true;
				v1.GUI.ShopFrame.Title.Title.Visible = false;
			end;
		end);
	end;
	v1.GUI.ShopFrame.Title.Gems.More.MouseButton1Click:connect(function()
		v1.GUI.ShopFrame.Title.Back.Visible = true;
		v1.GUI.ShopFrame.Title.Title.Visible = false;
	end);
	v1.GUI.ShopFrame.Title.Gems.GetMore.MouseButton1Click:connect(function()
		v1.GUI.ShopFrame.Title.Back.Visible = true;
		v1.GUI.ShopFrame.Title.Title.Visible = false;
	end);
end;
function v1.PurchaseBox(p23, p24, p25)
	if p24.BoxType == "Pets" then
		v1.PurchaseEgg(p23, p24, p25);
		return;
	end;
	v1.GUI.ShopFrame.Visible = false;
	_G.Process("Unboxing");
	local v152 = game.ReplicatedStorage.Remotes.Shop.OpenCrate:InvokeServer(p23, "MysteryBox", p25);
	wait(0.75 - (time() - time()));
	v1.GUI.Processing.Visible = false;
	if v152 then
		game.ReplicatedStorage.Remotes.Shop.BoxController:Fire(p23, v152);
	end;
end;
function v1.PurchaseEgg(p26, p27, p28)
	v1.GUI.ShopFrame.Visible = false;
	_G.Process("Unboxing");
	local v153 = game.ReplicatedStorage.Remotes.Shop.OpenCrate:InvokeServer(p26, "Eggs", p28);
	wait(0.75 - (time() - time()));
	v1.GUI.Processing.Visible = false;
	if v153 then
		game.ReplicatedStorage.Remotes.Shop.EggController:Fire(p26, v153);
	end;
end;
function v1.ConnectViewBoxFrame()
	v1.GUI.ViewBoxFrame.BuyFrame.GetKeys.MouseButton1Click:connect(function()
		v1.OpenBuyPopup("Key", _G.Database.Weapons.Key, "Item", "Weapons", _G.Database.Shop.Weapons.Key);
	end);
	v1.GUI.ViewBoxFrame.BuyFrame.GetKeys.Amount.Text = "You have " .. (_G.PlayerData.Weapons.Owned.Key and 0) .. " Keys";
	game.ReplicatedStorage.UpdateDataClient.Event:connect(function(p29, p30)
		if not p29 then
			v1.GUI.ViewBoxFrame.BuyFrame.GetKeys.Amount.Text = "You have " .. (_G.PlayerData.Weapons.Owned.Key and 0) .. " Keys";
		end;
	end);
	v1.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.Coins.MouseButton1Click:connect(function()
		if u13.Price.Coins <= _G.PlayerData.Coins then
			v1.PurchaseBox(u11, u12, "Coins");
			_G.LastShopSelection = v1.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.Coins;
		end;
	end);
	v1.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.Key.MouseButton1Click:connect(function()
		if u13.Price.Key <= (_G.PlayerData.Weapons.Owned.Key and 0) then
			v1.PurchaseBox(u11, u12, "Key");
			_G.LastShopSelection = v1.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.Key;
			return;
		end;
		v1.OpenBuyPopup("Key", _G.Database.Weapons.Key, "Item", "Weapons", _G.Database.Shop.Weapons.Key);
	end);
	v1.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.Gems.MouseButton1Click:connect(function()
		if not (u13.Price.Gems <= _G.PlayerData.Gems) then
			v1.ViewGems(u13.Price.Gems - _G.PlayerData.Gems);
			return;
		end;
		v1.PurchaseBox(u11, u12, "Gems");
		_G.LastShopSelection = v1.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.Gems;
	end);
	v1.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.Candies2022.MouseButton1Click:connect(function()
		if not (u13.Price.Candies2022 <= (_G.PlayerData.Materials.Owned.Candies2022 and 0)) then
			if _G.ViewCandies then
				_G.ViewCandies();
			end;
			return;
		end;
		v1.PurchaseBox(u11, u12, "Candies2022");
		_G.LastShopSelection = v1.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.Candies2022;
	end);
	v1.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.ReaverKey2021.MouseButton1Click:connect(function()
		if not (u13.Price.ReaverKey2021 <= (_G.PlayerData.Materials.Owned.ReaverKey2021 and 0)) then
			if _G.ViewBattlePass then
				_G.ViewBattlePass();
			end;
			return;
		end;
		v1.PurchaseBox(u11, u12, "ReaverKey2021");
		_G.LastShopSelection = v1.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.ReaverKey2021;
	end);
	v1.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.SnowTokens2021.MouseButton1Click:connect(function()
		if not (u13.Price.SnowTokens2021 <= (_G.PlayerData.Materials.Owned.SnowTokens2021 and 0)) then
			if _G.ViewPurchaseCurrency then
				_G.ViewPurchaseCurrency();
			end;
			return;
		end;
		v1.PurchaseBox(u11, u12, "SnowTokens2021");
		_G.LastShopSelection = v1.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.SnowTokens2021;
	end);
	v1.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.SnowKey2021.MouseButton1Click:connect(function()
		if not (u13.Price.SnowKey2021 <= (_G.PlayerData.Materials.Owned.SnowKey2021 and 0)) then
			if _G.ViewBattlePass then
				_G.ViewBattlePass();
			end;
			return;
		end;
		v1.PurchaseBox(u11, u12, "SnowKey2021");
		_G.LastShopSelection = v1.GUI.ViewBoxFrame.BuyFrame.PurchaseOptions.Container.SnowKey2021;
	end);
end;
function v1.ConnectBuyPopup()
	v1.GUI.Main.BuyPopup.Container.Close.MouseButton1Click:connect(function()
		v1.GUI.Main.BuyPopup.Visible = false;
	end);
	v1.GUI.Main.BuyPopup.Container.PriceFrame.Gems.Buy.MouseButton1Click:connect(function()
		if u8 then
			v1.BuyItem(u8.ItemID, u8.ShopType, "Gems", v1.GUI.Main.BuyPopup.Container);
			v1.GUI.Main.BuyPopup.Visible = false;
		end;
	end);
	v1.GUI.Main.BuyPopup.Container.PriceFrame.Coins.Buy.MouseButton1Click:connect(function()
		if u8 then
			v1.BuyItem(u8.ItemID, u8.ShopType, "Coins", v1.GUI.Main.BuyPopup.Container);
			v1.GUI.Main.BuyPopup.Visible = false;
		end;
	end);
	v1.GUI.Main.BuyPopup.Container.PriceFrame.SnowTokens2021.Buy.MouseButton1Click:connect(function()
		if u8 then
			v1.BuyItem(u8.ItemID, u8.ShopType, "SnowTokens2021", v1.GUI.Main.BuyPopup.Container);
			v1.GUI.Main.BuyPopup.Visible = false;
		end;
	end);
	v1.GUI.Main.BuyPopup.Container.PriceFrame.Candies2022.Buy.MouseButton1Click:connect(function()
		if u8 then
			v1.BuyItem(u8.ItemID, u8.ShopType, "Candies2022", v1.GUI.Main.BuyPopup.Container);
			v1.GUI.Main.BuyPopup.Visible = false;
		end;
	end);
	v1.GUI.Main.BuyPopup.Container.PriceFrame.GetMoreGems.Buy.MouseButton1Click:connect(function()
		v1.ViewGems(l__Shop__1[u8.ShopType][u8.ItemID].Price.Gems - _G.PlayerData.Gems);
	end);
end;
function v1.HighlightGem(p31)
	local v154 = nil;
	local v155 = nil;
	local v156 = nil;
	local v157 = nil;
	local v158 = nil;
	local v159 = nil;
	local v160 = nil;
	local v161 = nil;
	local v162 = nil;
	local v163 = nil;
	local v164 = nil;
	local v165 = nil;
	local u14 = nil;
	local v166 = nil;
	local v167 = nil;
	local v173 = nil;
	local v174 = nil;
	if p31 ~= nil then
		local v168 = v1.GUI.Main.Gems:GetChildren();
		table.sort(v168, function(p32, p33)
			return tonumber(p32.Name) < tonumber(p33.Name);
		end);
		local v169, v170, v171 = pairs(v168);
		while true do
			local v172 = nil;
			v172, v154 = v169(v170, v171);
			if not v172 then
				break;
			end;
			v171 = v172;
			v155 = tonumber(v154.Name);
			if p31 <= v155 then
				v158 = print;
				v159 = "RQ";
				v156 = v155;
				v160 = v156;
				v157 = p31;
				v161 = v157;
				v162 = v158;
				v163 = v159;
				v164 = v160;
				v165 = v161;
				v162(v163, v164, v165);
				local v173 = spawn;
				u14 = v154;
				local v174 = function()
					wait(0.1);
					u14:TweenPosition(UDim2.new(u14.Position.X.Scale, u14.Position.X.Offset, u14.Position.Y.Scale, u14.Position.Y.Offset - 30), "Out", "Sine", 0.3);
					wait(0.31);
					u14:TweenPosition(UDim2.new(u14.Position.X.Scale, u14.Position.X.Offset, u14.Position.Y.Scale, u14.Position.Y.Offset + 30), "In", "Sine", 0.3);
					wait(0.31);
					u14.Position = u14.Position;
				end;
				v166 = v173;
				v167 = v174;
				v166(v167);
				return;
			end;		
		end;
		return;
	end;
	v158 = print;
	v159 = "RQ";
	v156 = v155;
	v160 = v156;
	v157 = p31;
	v161 = v157;
	v162 = v158;
	v163 = v159;
	v164 = v160;
	v165 = v161;
	v162(v163, v164, v165);
	v173 = spawn;
	u14 = v154;
	v174 = function()
		wait(0.1);
		u14:TweenPosition(UDim2.new(u14.Position.X.Scale, u14.Position.X.Offset, u14.Position.Y.Scale, u14.Position.Y.Offset - 30), "Out", "Sine", 0.3);
		wait(0.31);
		u14:TweenPosition(UDim2.new(u14.Position.X.Scale, u14.Position.X.Offset, u14.Position.Y.Scale, u14.Position.Y.Offset + 30), "In", "Sine", 0.3);
		wait(0.31);
		u14.Position = u14.Position;
	end;
	v166 = v173;
	v167 = v174;
	v166(v167);
end;
function v1.ViewGems(p34)
	v1.ResetNavButtons();
	for v175, v176 in pairs(v1.GUI.Main:GetChildren()) do
		v176.Visible = v176.Name == "Gems";
	end;
	u10 = "Gems";
	v1.HighlightGem(p34);
end;
function v1.ConnectGems()
	for v177, v178 in pairs(v1.GUI.Main.Gems:GetChildren()) do
		v178.MouseButton1Click:connect(function()
			script.Click:Play();
			game.ReplicatedStorage.Remotes.Shop.PurchaseProduct:FireServer(v178.Name, "Gems");
		end);
	end;
	v1.GUI.Title.Gems.GetMore.MouseButton1Click:connect(function()
		v1.ViewGems();
	end);
end;
return v1;
