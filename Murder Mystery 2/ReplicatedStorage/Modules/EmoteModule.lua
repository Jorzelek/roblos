-- Decompiled with the Synapse X Luau decompiler.

local v1 = {};
local v2 = {};
_G.EmotePages = {};
_G.CurrentPage = "";
v1.EmoteGUI = nil;
local u1 = {};
local function u2(p1)
	if _G.Cache[p1] ~= nil then
		return _G.Cache[p1];
	end;
	local v3 = (tonumber(p1) and "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. p1 or p1) .. "&bust=" .. math.random(1, 10000);
	_G.Cache[p1] = v3;
	return v3;
end;
local l__KeyboardEnabled__3 = game:GetService("UserInputService").KeyboardEnabled;
function v1.GeneratePage(p2, p3, p4, p5, p6)
	local v4 = script.Page:Clone();
	local v5 = script.Container:Clone();
	v5.Parent = v4;
	v4.Name = p4;
	v4.Parent = p3.EmotePages;
	local v6 = {};
	for v7, v8 in pairs(p2) do
		v6[v7] = v8;
	end;
	table.insert(v6, 1, "");
	table.insert(v6, 2, "");
	u1[p4] = {};
	local v9 = #v6 - 2;
	v5.Size = UDim2.new(v9, 0, 1, 0);
	v5:ClearAllChildren();
	local v10 = 3;
	for v11, v12 in pairs(v6) do
		if _G.Database.Emotes[v12] then
			local v13 = script.Emote:Clone();
			v13.Size = UDim2.new(1 / v9, 0, 1, 0);
			v13.Position = UDim2.new(1 / v9 * (v10 - 1 - 1 - 1), 0, 0, 0);
			v13.Name = v12;
			v13.Parent = v5;
			v13.Container.Icon.Image = u2(_G.Database.Emotes[v12].Image);
			v13.Container.EmoteName.Text = _G.Database.Emotes[v12].Name;
			v13.Container.Hotkey.Text = v10;
			v13.Container.Hotkey.Visible = l__KeyboardEnabled__3;
			v13.Container.Button.MouseButton1Click:connect(function()
				game.ReplicatedStorage.Remotes.Misc.PlayEmote:Fire(v12);
			end);
			u1[p4][v10] = v12;
			v10 = v10 + 1;
		end;
	end;
	table.insert(_G.EmotePages, p4);
	local v14 = script.Back:Clone();
	v14.Size = UDim2.new(1 / v9, 0, 1, 0);
	v14.Container.Icon.Visible = not game:GetService("UserInputService").GamepadEnabled;
	v14.Container.BButton.Visible = game:GetService("UserInputService").GamepadEnabled;
	v14.Container.Hotkey.Visible = game:GetService("UserInputService").KeyboardEnabled;
	v14.Parent = v5;
end;
function v1.ShowPage(p7)
	_G.EmoteController.Emotes = { nil, "Back" };
	for v15, v16 in pairs(u1[p7]) do
		_G.EmoteController.Emotes[v15] = v16;
	end;
	for v17, v18 in pairs(v1.EmoteGUI.EmotePages:GetChildren()) do
		v18.Visible = v18.Name == p7;
	end;
	_G.CurrentPage = p7;
	v1.EmoteGUI.PageName.Text = p7;
	if game:GetService("UserInputService").GamepadEnabled and v1.EmoteGUI.Visible then
		game:GetService("GuiService").SelectedObject = v1.EmoteGUI.EmotePages[p7].Container:GetChildren()[1].Container.Button;
	end;
end;
function _G.ChangePage(p8)
	for v19, v20 in pairs(_G.EmotePages) do
		if v19 == p8 then
			v1.ShowPage(v20);
		end;
	end;
end;
local u4 = {};
function v1.GenerateEmotes(p9, p10)
	u1 = {};
	_G.EmotePages = {};
	_G.CurrentPage = "";
	p10.EmotePages:ClearAllChildren();
	if #p9 > 0 then
		if #p9 > 6 then
			local v21 = {};
			local v22 = 0;
			for v23, v24 in pairs(p9) do
				local v25 = math.floor(v23 / 6) + 1;
				v21[v25] = v21[v25] or {};
				table.insert(v21[v25], v24);
				v22 = v25;
			end;
			local v26 = nil;
			for v27, v28 in pairs(v21) do
				local v29 = "Your Emotes (" .. v27 .. "/" .. v22 .. ")";
				v1.GeneratePage(v28, p10, v29);
				if v27 == 1 then
					v26 = v29;
				end;
			end;
			v1.GeneratePage({ "wave", "cheer", "laugh", "dance1", "dance2", "dance3" }, p10, "Roblox Emotes");
			v1.ShowPage(v26, p10);
		else
			v1.GeneratePage(p9, p10, "Your Emotes");
			v1.GeneratePage({ "wave", "cheer", "laugh", "dance1", "dance2", "dance3" }, p10, "Roblox Emotes");
			v1.ShowPage("Your Emotes", p10);
		end;
	else
		v1.GeneratePage({ "wave", "cheer", "laugh", "dance1", "dance2", "dance3" }, p10, "Roblox Emotes");
		v1.GeneratePage(p9, p10, "Your Emotes");
		v1.ShowPage("Roblox Emotes", p10);
	end;
	u4 = {};
	for v30, v31 in pairs(p9) do
		u4[v31] = true;
	end;
end;
local l__GamepadEnabled__5 = game:GetService("UserInputService").GamepadEnabled;
function v1.SetupPageButtons()
	local v32 = nil
	if l__GamepadEnabled__5 then
		v32 = "< LB";
	elseif l__KeyboardEnabled__3 then
		v32 = "< Q";
	else
		v32 = "<";
	end;
	local v33 = nil
	if l__GamepadEnabled__5 then
		v33 = "RB >";
	elseif l__KeyboardEnabled__3 then
		v33 = "E >";
	else
		v33 = ">";
	end;
	v1.EmoteGUI.Left.Text = v32;
	v1.EmoteGUI.Right.Text = v33;
	v1.EmoteGUI.Left.MouseButton1Click:connect(_G.EmotePageLeft);
	v1.EmoteGUI.Right.MouseButton1Click:connect(_G.EmotePageRight);
end;
game.ReplicatedStorage.UpdateDataClient.Event:connect(function(p11)
	if p11 then
		return;
	end;
	for v34, v35 in pairs(_G.PlayerData.Emotes.Owned) do
		if u4[v35] == nil then
			v1.GenerateEmotes(_G.PlayerData.Emotes.Owned, v1.EmoteGUI);
			return;
		end;
	end;
end);
return v1;
