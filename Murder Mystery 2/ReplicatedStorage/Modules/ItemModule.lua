-- Decompiled with the Synapse X Luau decompiler.

local v1 = {};
local function v2(p1)
	if _G.Cache[p1] ~= nil then
		return _G.Cache[p1];
	end;
	local v3 = (tonumber(p1) and "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. p1 or p1) .. "&bust=" .. math.random(1, 10000);
	_G.Cache[p1] = v3;
	return v3;
end;
v1.GetImage = v2;
function v1.GetImageSmall(p2)
	if _G.SmallCache[p2] ~= nil then
		return _G.SmallCache[p2];
	end;
	local v4 = (tonumber(p2) and "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=110&height=110&assetId=" .. p2 or p2) .. "&bust=" .. math.random(1, 10000);
	_G.SmallCache[p2] = v4;
	return v4;
end;
local v5 = {
	Chroma = function(p3, p4)
		p3.Tags.Chroma.Visible = p4.Chroma == true;
	end, 
	Evo = function(p5, p6)
		p5.Tags.Evo.Visible = p6.EvoBaseID ~= nil;
	end
};
local u1 = {
	Weapons = true, 
	Pets = true
};
function v5.Halloween(p7, p8)
	if not u1[p8.DataType] then
		p7.Tags.Halloween.Visible = p8.Event == "Halloween";
		p7.Tags.Halloween.Year.Text = p8.Year and "";
	end;
end;
function v5.Christmas(p9, p10)
	if not u1[p10.DataType] then
		p9.Tags.Christmas.Visible = p10.Event == "Christmas";
		p9.Tags.Christmas.Year.Text = p10.Year and "";
	end;
end;
local l__Rarities__2 = _G.Database.Rarities;
function v1.DisplayItem(p11, p12, p13, p14)
	if p12 == nil then
		p11.ItemName.Label.Text = "";
		p11.Container.Icon.Image = "";
		p11.Container.Amount.Text = "";
		p11.ItemName.BackgroundColor3 = Color3.fromRGB(95, 95, 95);
		for v6, v7 in pairs(p11.Tags:GetChildren()) do
			if v7:IsA("Frame") then
				v7.Visible = false;
			end;
		end;
		return;
	end;
	p11.ItemName.Label.Text = p12.ItemName or p12.Name;
	p12.Rarity = p12.Rarity and "Common";
	local v8 = l__Rarities__2[p12.Rarity].Color or Color3.new(1, 1, 1);
	p11.ItemName.BackgroundColor3 = v8;
	p11.Container.Icon.Image = v2(p12.Image);
	if p11.Container:FindFirstChild("Amount") then
		local v9 = p13 or p12.Amount;
		if v9 then
			local v10 = v9 > 1 and "x" .. v9 or "";
		else
			v10 = "";
		end;
		p11.Container.Amount.Text = v10;
	end;
	if p11.Container:FindFirstChild("Classic") then
		p11.Container.Classic.Visible = p12.Classic ~= nil;
	end;
	if p11.ItemName:FindFirstChild("ColoredName") then
		p11.ItemName.ColoredName.Text = p12.ItemName or p12.Name;
		local v11 = v8;
		if p12.Rarity == "Common" then
			v11 = Color3.new(1, 1, 1);
		end;
		p11.ItemName.ColoredName.TextColor3 = v11;
		p11.ItemName.RarityBar.BackgroundColor3 = v11;
	end;
	if not p12.EvoBaseID then
		for v12, v13 in pairs(v5) do
			if p11.Tags:FindFirstChild(v12) then
				v13(p11, p12);
			end;
		end;
	end;
	if p12.Signature then
		local l__Signature__14 = p12.Signature;
		if l__Signature__14 ~= "" then
			p11.Tags.Unique.PlayerName.Text = l__Signature__14 .. "'s";
			p11.Tags.Unique.Visible = true;
			if tonumber(l__Signature__14) then
				spawn(function()
					p11.Tags.Unique.PlayerName.Text = game.Players:GetNameFromUserIdAsync((math.abs(p12.Signature))) .. "'s";
				end);
			end;
		end;
		p11.Container.Amount.Text = p12.Rank and "#" .. p12.Rank or "";
	end;
	if p14 and p11:FindFirstChild("Tags") then
		for v15, v16 in pairs(p11.Tags:GetChildren()) do
			if v16:IsA("Frame") and v16.Visible == false then
				v16:Destroy();
			end;
		end;
		if #p11.Tags:GetChildren() == 1 then
			p11.Tags:Destroy();
		end;
	end;
end;
function v1.Commafy(p15)
	p15 = tostring(p15);
	local v17 = p15;
	while true do
		local v18, v19 = string.gsub(v17, "^(-?%d+)(%d%d%d)", "%1,%2");
		k = v19;
		v17 = v18;
		if k == 0 then
			break;
		end;	
	end;
	return v17;
end;
function v1.AnimateItemIconIntoInventory(p16, p17, p18)
	local v20 = p16:Clone();
	local l__X__21 = p16.AbsoluteSize.X;
	local l__Y__22 = p16.AbsoluteSize.Y;
	v20.Size = UDim2.new(0, l__X__21, 0, l__Y__22);
	v20.BackgroundTransparency = 1;
	v20.Position = UDim2.new(0, p16.AbsolutePosition.X + l__X__21 / 2, 0, p16.AbsolutePosition.Y + l__Y__22 / 2);
	v20.AnchorPoint = Vector2.new(0.5, 0.5);
	v20.ZIndex = 10;
	v20.Parent = p18;
	spawn(function()
		v20:TweenSizeAndPosition(UDim2.new(0, 25, 0, 25), UDim2.new(0, p17.AbsolutePosition.X + p17.AbsoluteSize.X / 2 - 3, 0, p17.AbsolutePosition.Y + p17.AbsoluteSize.Y / 2 - 20), "InOut", "Sine", 0.5);
		wait(0.5);
		v20:Destroy();
	end);
end;
return v1;
