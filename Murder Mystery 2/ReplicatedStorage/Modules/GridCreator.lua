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
local function u1(p2)
	local v4 = {};
	for v5, v6 in pairs(p2) do
		if type(v6) == "table" then
			v6 = u1(v6);
		end;
		v4[v5] = v6;
	end;
	return v4;
end;
v1.GetImage = v2;
local u2 = {
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
function v1.GetSortedInventory()
	local v7 = {};
	for v8, v9 in pairs(u1(_G.PlayerData.Weapons).Owned) do
		table.insert(v7, {
			ItemID = v8, 
			Amount = v9
		});
	end;
	table.sort(v7, function(p3, p4)
		local v10 = { p3.ItemID, p4.ItemID };
		local v11 = { p3.Amount, p4.Amount };
		local v12 = { _G.Database.Item[v10[1]], _G.Database.Item[v10[2]] };
		local v13 = { u2[v12[1].Rarity], u2[v12[2].Rarity] };
		if v10[1] == "DefaultKnife" then
			return true;
		end;
		if v10[2] == "DefaultKnife" then
			return false;
		end;
		if v10[1] == "DefaultGun" then
			return true;
		end;
		if v10[2] == "DefaultGun" then
			return false;
		end;
		if v13[1] ~= v13[2] then
			return v13[2] < v13[1];
		end;
		if v11[1] ~= v11[2] then
			return v11[2] < v11[1];
		end;
		return v12[1].ItemName < v12[2].ItemName;
	end);
	return v7;
end;
function v1.CreateFrame(p5, p6, p7, p8, p9, p10, p11, p12)
	local v14 = p8:Clone();
	v14.Name = p12 or (p6.ID or (p6.ItemID or tostring(p8.Name .. p10)));
	p7(v14, p6, p5);
	return v14;
end;
function v1.CreateGrid(p13, p14, p15, p16)
	local v15 = 0;
	local l__Container__16 = p16.Container;
	local l__Scale__17 = p14.Size.X.Scale;
	l__Container__16:ClearAllChildren();
	local v18, v19, v20 = pairs(p15);
	while true do
		local v21, v22 = v18(v19, v20);
		if not v21 then
			break;
		end;
		local v23 = true;
		if v22.ItemID ~= "DefaultKnife" then
			v23 = v22.ItemID == "DefaultGun";
		end;
		if not v23 then
			local v24 = math.floor(v15 / math.floor(1 / l__Scale__17));
			local v25 = v1.CreateFrame(v21, v22, p13, p14, p16, v15, v24);
			v25.Parent = l__Container__16;
			v25.Position = UDim2.new(v25.Size.X.Scale * (v15 % math.floor(1 / l__Scale__17)), 0, 0, v25.AbsoluteSize.Y * v24);
			if p16:IsA("ScrollingFrame") then
				p16.CanvasSize = UDim2.new(0, 0, 0, (v24 + 1) * v25.AbsoluteSize.Y);
			end;
			v15 = v15 + 1;
		end;	
	end;
end;
function v1.CreateList(p17, p18, p19, p20)
	local v26 = 0;
	local l__Container__27 = p20.Container;
	l__Container__27:ClearAllChildren();
	for v28, v29 in pairs(p19) do
		local v30 = math.floor(v26 / 1);
		local v31 = v1.CreateFrame(v28, v29, p17, p18, p20, v26, v30);
		v31.Parent = l__Container__27;
		v31.Position = UDim2.new(0, 0, 0, v31.AbsoluteSize.Y * v30);
		p20.CanvasSize = UDim2.new(0, 0, 0, (v30 + 1) * v31.AbsoluteSize.Y);
		v26 = v26 + 1;
	end;
end;
function v1.CreatePass(p21, p22, p23, p24, p25)
	local v32 = 0;
	for v33 = 1, p23.TotalTiers do
		local v34 = tostring(v33);
		local v35 = math.floor(v32 / 5);
		local v36 = v32 % 5;
		local v37 = p24:FindFirstChild("Page" .. v35);
		if not v37 then
			v37 = p25:Clone();
			v37.Name = "Page" .. v35;
			v37.Parent = p24;
		end;
		local v38 = p23.Rewards[v34] or {};
		local v39 = v37:FindFirstChild("Tier" .. v34);
		if not v39 then
			local v40 = v1.CreateFrame(v33, v38, p21, p22, nil, v36, nil, "Tier" .. v34);
			v40.Parent = v37;
			v40.Position = UDim2.new(0, v40.AbsoluteSize.X * v36, 0, 0);
		else
			p21(v39, v38, v33);
		end;
		v32 = v32 + 1;
	end;
end;
local u3 = game.ReplicatedStorage.GetSyncData:InvokeServer("Rarity");
function v1.MakeItemFrame(p26, p27, p28)
	local l__ItemID__41 = p27.ItemID;
	local l__Amount__42 = p27.Amount;
	if p26:FindFirstChild("Container") then
		p26 = p26.Container;
	end;
	local v43 = p26.Icon:FindFirstChild("ItemName") or p26.ItemName;
	local v44 = (_G.Database[p27.ItemType] or _G.Database.Item)[l__ItemID__41] or (l__ItemID__41 or {
		Image = "", 
		ItemName = "", 
		Rarity = "Common"
	});
	p26.Icon.Image = v2(v44.Image);
	v43.Text = v44.ItemName or v44.Name;
	v43.TextColor3 = u3[v44.Rarity and "Common"];
	if l__Amount__42 then
		p26.Rarity.Text = v44.Rarity;
		p26.Rarity.TextColor3 = u3[v44.Rarity];
		p26.Year.Text = v44.Year and "";
		p26.Event.Text = v44.Event and "";
		p26.Event.TextColor3 = v44.Event and u3[v44.Event] or Color3.new();
		if l__Amount__42 > 1 then
			p26.Amount.Text = "x" .. math.floor(l__Amount__42);
		end;
		if p28 == nil then
			p26.MouseEnter:connect(function()
				p26.Rarity.Visible = true;
				p26.Year.Visible = true;
				p26.Event.Visible = true;
			end);
			p26.MouseLeave:connect(function()
				p26.Rarity.Visible = false;
				p26.Year.Visible = false;
				p26.Event.Visible = false;
			end);
		end;
	end;
end;
function v1.Commafy(p29)
	local v45 = p29;
	while true do
		local v46, v47 = string.gsub(v45, "^(-?%d+)(%d%d%d)", "%1,%2");
		local k = v47;
		v45 = v46;
		if k == 0 then
			break;
		end;	
	end;
	return v45;
end;
return v1;
