-- Decompiled with the Synapse X Luau decompiler.

local v1 = {};
local v2 = require(script.Parent.InventoryModule);
local v3 = require(game.ReplicatedStorage.Modules.ItemModule);
v1.GUI = {};
v1.RequestsEnabled = true;
v1.TradeInventory = nil;
function _G.NewTradeRequest()

end;
local l__Trade__1 = game.ReplicatedStorage.Trade;
function v1.SendTradeRequest(p1)
	if not l__Trade__1.SendRequest:InvokeServer(game.Players[p1]) then
		v1.UpdateTradeRequestWindow("SendingRequest", {
			Receiver = {
				Name = p1
			}
		});
	end;
end;
function v1.UpdateTradeRequestWindow(p2, p3)
	local l__RequestFrame__4 = v1.GUI.RequestFrame;
	for v5, v6 in pairs(l__RequestFrame__4:GetChildren()) do
		v6.Visible = v6.Name == p2;
	end;
	l__RequestFrame__4.Visible = true;
	_G.NewTradeRequest(false);
	if p2 == "SendingRequest" then
		l__RequestFrame__4.SendingRequest.Username.Text = p3.Receiver.Name;
		return;
	end;
	if p2 ~= "ReceivingRequest" then
		l__RequestFrame__4.Visible = false;
		return;
	end;
	l__RequestFrame__4.ReceivingRequest.Username.Text = p3.Sender.Name;
	_G.NewTradeRequest(true);
end;
function v1.ConnectRequestWindow()
	v1.GUI.RequestFrame.SendingRequest.Cancel.MouseButton1Click:connect(function()
		v1.GUI.RequestFrame.Visible = false;
		l__Trade__1.CancelRequest:FireServer();
	end);
	v1.GUI.RequestFrame.ReceivingRequest.Accept.MouseButton1Click:connect(function()
		v1.GUI.RequestFrame.Visible = false;
		l__Trade__1.AcceptRequest:FireServer();
		_G.NewTradeRequest(false);
	end);
	v1.GUI.RequestFrame.ReceivingRequest.Decline.MouseButton1Click:connect(function()
		v1.GUI.RequestFrame.Visible = false;
		l__Trade__1.DeclineRequest:FireServer();
		_G.NewTradeRequest(false);
	end);
end;
l__Trade__1.DeclineRequest.OnClientEvent:connect(function()
	v1.UpdateTradeRequestWindow();
	_G.NewTradeRequest(false);
end);
l__Trade__1.CancelRequest.OnClientEvent:Connect(function()
	v1.UpdateTradeRequestWindow();
end);
l__Trade__1.SendRequest.OnClientInvoke = function(p4)
	if v1.RequestsEnabled then
		v1.UpdateTradeRequestWindow("ReceivingRequest", {
			Sender = {
				Name = p4.Name
			}
		});
	end;
	return v1.RequestsEnabled;
end;
local u2 = {};
local function u3(p5)
	for v7, v8 in pairs(p5:GetChildren()) do
		if v8:IsA("Frame") then
			v8.Visible = false;
			if u2[v8] then
				u2[v8]:disconnect();
			end;
		end;
	end;
end;
local function u4(p6, p7)
	local v9, v10, v11 = pairs(p7);
	while true do
		local v12, v13 = v9(v10, v11);
		if not v12 then
			break;
		end;
		local v14 = v13[3];
		local v15 = {};
		for v16, v17 in pairs(_G.Database[v14][v13[1]]) do
			v15[v16] = v17;
		end;
		v15.DataType = v14;
		v15.Amount = v13[2];
		local v18 = p6.Container["NewItem" .. v12];
		v3.DisplayItem(v18, v15);
		if u2[v18] then
			u2[v18]:disconnect();
		end;
		u2[v18] = v18.Container.ActionButton.MouseButton1Click:connect(function()
			l__Trade__1.RemoveOffer:FireServer(v13[1], v13[3]);
		end);
		v18.Visible = true;	
	end;
end;
local u5 = "Accept";
function v1.UpdateTrade(p8)
	local v19 = nil;
	local v20 = nil;
	if p8.Player1.Player == game.Players.LocalPlayer then
		local v19 = "Player1";
		local v20 = "Player2";
	elseif p8.Player2.Player == game.Players.LocalPlayer then
		v19 = "Player2";
		v20 = "Player1";
	else
		v19 = nil;
		v20 = nil;
	end;
	local l__Offer__21 = p8[v19].Offer;
	local l__Offer__22 = p8[v20].Offer;
	u3(v1.GUI.YourOffer.Container);
	u3(v1.GUI.TheirOffer.Container);
	u4(v1.GUI.YourOffer, l__Offer__21);
	u4(v1.GUI.TheirOffer, l__Offer__22);
	u5 = "Accept";
	v1.GUI.YourOffer.Accepted.Visible = false;
	v1.GUI.TheirOffer.Accepted.Visible = false;
	v1.GUI.Actions.Accept.Confirm.Visible = false;
	v1.GUI.Actions.Accept.Cancel.Visible = false;
	local v23 = false;
	if #l__Offer__21 < 1 then
		v23 = #l__Offer__22 < 1;
	end;
	v1.GUI.Actions.Accept.AddItem.Visible = v23;
	v1.UpdateTradeInventory(p8);
	local v24 = false;
	if #l__Offer__21 < 1 then
		v24 = #l__Offer__22 < 1;
	end;
	v1.ResetCooldown(v24);
end;
l__Trade__1.UpdateTrade.OnClientEvent:connect(v1.UpdateTrade);
local u6 = nil;
l__Trade__1.StartTrade.OnClientEvent:connect(function(p9, p10)
	for v25, v26 in pairs({ "Weapons", "Pets" }) do
		for v27, v28 in pairs(v2.CreateBlankTradeInventoryTable()[v26]) do
			v1.GUI.TradeGUI.Container.Items.Main:FindFirstChild(v26).Items.Container:FindFirstChild(v27).Container:ClearAllChildren();
		end;
	end;
	v1.TradeInventory = v2.GenerateInventory(v1.GUI.TradeGUI.Container.Items, _G.PlayerData, "Trading", v1.GUI.ItemsLayout);
	v1.ConnectOfferButtons(v1.TradeInventory);
	v1.UpdateTrade(p9);
	v1.GUI.TheirOffer.Username.Text = "(" .. p10 .. ")";
	v1.GUI.TradeGUI.Enabled = true;
	v1.GUI.RequestFrame.Visible = false;
	if u6 then
		u6:disconnect();
	end;
	local l__SearchText__29 = v1.GUI.TradeGUI.Container.Items.Tabs.Search.Container.SearchText;
	u6 = l__SearchText__29:GetPropertyChangedSignal("Text"):connect(function()
		local v30 = string.gsub(l__SearchText__29.Text, "S", "");
		for v31, v32 in pairs(v1.TradeInventory.Data) do
			for v33, v34 in pairs(v32.Current) do
				v34.Frame.Visible = string.find(string.lower(v34.Name), string.lower(v30));
				if v34.Frame.Parent.Parent:IsA("ScrollingFrame") then
					v34.Frame.Parent.Parent.CanvasPosition = Vector2.new(0, 0);
				else
					v34.Frame.Parent.Parent.Parent.Parent.CanvasPosition = Vector2.new(0, 0);
				end;
			end;
		end;
	end);
end);
function v1.UpdateTradeInventory(p11)
	if p11.Player1.Player == game.Players.LocalPlayer then
		local v35 = "Player1";
		local v36 = "Player2";
	elseif p11.Player2.Player == game.Players.LocalPlayer then
		v35 = "Player2";
		v36 = "Player1";
	else
		v35 = nil;
		v36 = nil;
	end;
	local l__Offer__37 = p11[v35].Offer;
	local l__Offer__38 = p11[v36].Offer;
	for v39, v40 in pairs(v1.TradeInventory.Data) do
		for v41, v42 in pairs(v40) do
			local v43, v44, v45 = pairs(v42);
			while true do
				local v46, v47 = v43(v44, v45);
				if not v46 then
					break;
				end;
				local l__Frame__48 = v47.Frame;
				local v49 = v47.Amount;
				for v50, v51 in pairs(l__Offer__37) do
					if v51[1] == v46 and v51[3] == v39 then
						v49 = v49 - v51[2];
					end;
				end;
				if v49 == 1 then
					l__Frame__48.Container.Amount.Text = "";
					l__Frame__48.Visible = true;
				elseif v49 > 1 then
					l__Frame__48.Container.Amount.Text = "x" .. v49;
					l__Frame__48.Visible = true;
				elseif v49 < 1 then
					l__Frame__48.Visible = false;
				end;			
			end;
		end;
	end;
end;
function v1.ConnectOfferButtons(p12)
	for v52, v53 in pairs(p12.Data) do
		for v54, v55 in pairs(v53) do
			for v56, v57 in pairs(v55) do
				local l__Frame__58 = v57.Frame;
				if l__Frame__58 then
					l__Frame__58.Container.ActionButton.MouseButton1Click:connect(function()
						l__Trade__1.OfferItem:FireServer(v56, v52);
					end);
				end;
			end;
		end;
	end;
end;
local u7 = 6;
local u8 = false;
function v1.ResetCooldown(p13)
	if p13 then
		v1.GUI.Actions.Accept.Cooldown.Visible = false;
		u7 = 0;
		u8 = false;
		return;
	end;
	v1.GUI.Actions.Accept.Cooldown.Visible = true;
	u7 = 6;
	v1.GUI.Actions.Accept.Cooldown.Title.Text = " Please wait (" .. u7 .. ") before accepting.";
	if u8 then
		u7 = 6;
		return;
	end;
	v1.GUI.Actions.Accept.Cooldown.Visible = true;
	u8 = true;
	while true do
		wait(1);
		u7 = u7 - 1;
		v1.GUI.Actions.Accept.Cooldown.Title.Text = " Please wait (" .. u7 .. ") before accepting.";
		if u7 <= 0 then
			break;
		end;	
	end;
	u8 = false;
	v1.GUI.Actions.Accept.Cooldown.Visible = false;
end;
local u9 = time();
function v1.ConnectActions()
	v1.GUI.Actions.Accept.ActionButton.MouseButton1Click:connect(function()
		if u7 <= 0 and u5 == "Accept" then
			u5 = "Confirm";
			u9 = time();
			v1.GUI.Actions.Accept.Confirm.Visible = true;
		end;
	end);
	v1.GUI.Actions.Accept.Confirm.ActionButton.MouseButton1Click:connect(function()
		if u7 <= 0 and time() - u9 >= 0.4 and u5 == "Confirm" then
			u5 = "Waiting";
			v1.GUI.YourOffer.Accepted.Visible = true;
			v1.GUI.Actions.Accept.Cancel.Visible = true;
			l__Trade__1.AcceptTrade:FireServer();
		end;
	end);
	v1.GUI.Actions.Accept.Cancel.ActionButton.MouseButton1Click:connect(function()
		l__Trade__1.CancelAccept:FireServer();
	end);
	v1.GUI.Actions.Decline.ActionButton.MouseButton1Click:connect(function()
		l__Trade__1.DeclineTrade:FireServer();
		v1.GUI.TradeGUI.Enabled = false;
		v1.TradeInventory = nil;
	end);
	if v1.GUI.Actions:FindFirstChild("AddItems") then
		v1.GUI.Actions.AddItems.ActionButton.MouseButton1Click:connect(function()
			v1.GUI.TradeGUI.Container.Items.Visible = true;
		end);
		v1.GUI.TradeGUI.Container.Items.Tabs.Close.ActionButton.MouseButton1Click:connect(function()
			v1.GUI.TradeGUI.Container.Items.Visible = false;
		end);
	end;
end;
l__Trade__1.AcceptTrade.OnClientEvent:connect(function(p14, p15)
	if p14 then
		v1.GUI.TradeGUI.Enabled = false;
		if not p15 then
			return;
		end;
	else
		v1.GUI.TheirOffer.Accepted.Visible = true;
		return;
	end;
	for v59, v60 in pairs(p15) do
		_G.NewItem(v60[1], nil, nil, v60[3], v60[2]);
	end;
end);
l__Trade__1.DeclineTrade.OnClientEvent:connect(function()
	v1.GUI.TradeGUI.Enabled = false;
	v1.TradeInventory = nil;
end);
function v1.ConnectTabButtons()
	v2.ConnectTabButtons(nil, nil, v1.GUI.TradeGUI.Container.Items, v1.GUI.TradeGUI.Container.Items.Main);
end;
return v1;
