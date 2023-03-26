script.Parent:RemoveDefaultLoadingScreen();
game.StarterGui.ResetPlayerGuiOnSpawn = false;
local China = require(script.Parent:WaitForChild("ChinaPolicyService"));
China:WaitForReady();
local IsActive = China:IsActive();
local JoinedFriend = false;
local ModeSwitch = false;
local Portal = false;
game:GetService("TeleportService").LocalPlayerArrivedFromTeleport:connect(function(customLoadingScreen, TeleportData)
	script.Parent.ClientLoaded:FireServer("Teleport");
	if TeleportData then
		if TeleportData.Joined == true then
			JoinedFriend = true;
		end;
		if TeleportData.ModeSwitch then
			ModeSwitch = true;
		end;
		if TeleportData.PortalEvent == true then
			Portal = true;
		end;
	end;
end);
spawn(function()
	while true do
		wait();
		if game.ReplicatedStorage then
			break;
		end;	
	end;
	while true do
		wait();
		if game.ReplicatedStorage:FindFirstChild("GetSyncData") then
			break;
		end;	
	end;
	while true do
		wait(0.25);
		local data = game.ReplicatedStorage.GetSyncData:InvokeServer()
		if data ~= nil then
			_G.Database = data
			break
		end
	end;
	_G.Database.Weapons = _G.Database.Item;
	for toyName, ToyData in pairs(_G.Database.Toys) do
		_G.Database.Emotes[toyName] = ToyData;
	end;
end);
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false);
local UIS = game:GetService("UserInputService");
local Xbox = game.PlaceId == 188331445 and UIS.GamepadEnabled or UIS.GamepadEnabled and not UIS.KeyboardEnabled;
local screen;
if IsActive then
	screen = script.Loading_Clean
else
	screen = script.Loading
end
screen.Name = "Loading";
game.Players.LocalPlayer:WaitForChild("PlayerGui"):SetTopbarTransparency(0);
local plrGui = game.Players.LocalPlayer:WaitForChild("PlayerGui");
screen.Parent = plrGui;
if Xbox then
	spawn(function()
		game.ReplicatedStorage.Remotes.Extras:WaitForChild("IsXbox"):FireServer();
		game.ReplicatedStorage.DefaultChatSystemChatEvents.GetInitDataRequest:InvokeServer();
	end);
end;
local Phone = false;
local IsStudio = game:GetService("RunService"):IsStudio();
local TS = game:GetService("TweenService");
local tween1 = TweenInfo.new(4.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0);
local DataItem = game.ReplicatedStorage:WaitForChild("GetSyncData"):InvokeServer("Item");
_G.Cache = {};
_G.SmallCache = {};
local Database = { "Item", "Perks", "Radios", "Effects", "Emotes", "Toys", "Pets" };
local ContentProvider = game:GetService("ContentProvider");
(function()
	local LoadingData = nil;
	if not IsStudio then
		screen:WaitForChild("Container"):WaitForChild("LoadingText").Text = "Loading Data...";
		wait(2);
		screen:WaitForChild("Container"):WaitForChild("LoadingBar").Visible = true;
		screen:WaitForChild("Container"):WaitForChild("LoadingText").Visible = false;
		wait(1.6);
		TS:Create(screen:WaitForChild("Container"):WaitForChild("LoadingBar"):WaitForChild("BarContainer"):WaitForChild("Bar"), tween1, {
			Size = UDim2.new(1, 0, 1, 0)
		}):Play();
		wait(4.8);
		screen:WaitForChild("Container"):WaitForChild("LoadingBar").Visible = false;
		screen:WaitForChild("Container"):WaitForChild("LoadingText").Text = "Loading Character...";
		screen:WaitForChild("Container"):WaitForChild("LoadingText").Visible = true;
	end;
	while true do
		wait();
		LoadingData = game.Players.LocalPlayer:FindFirstChild("LoadingData");
		if game.Players.LocalPlayer.Character ~= nil then
			break;
		end;
		if LoadingData then
			break;
		end;	
	end;
	if LoadingData then
		screen:WaitForChild("Container"):WaitForChild("LoadingText").Text = "Verifying Data, please wait 60 seconds!...";
		while true do
			wait();
			if game.Players.LocalPlayer.Character ~= nil then
				break;
			end;		
		end;
	end;
end)();
game:GetService("LogService").MessageOut:connect(function(Message, Type)
	--game.ReplicatedStorage.ServerPrint:FireServer(Message);
end);
local function LoadGame()
	local QSize = tonumber(game.ContentProvider.RequestQueueSize);
	local FinishLoading = false;
	local Skipped = false;
	spawn(function()
		wait(7);
		pcall(function()
			if not FinishLoading then
				screen.Container.Skip.Visible = true;
				screen.Container.Warning.Visible = true;
				screen.Container.Skip.MouseButton1Click:connect(function()
					Skipped = true;
				end);
			end;
		end);
	end);
	while game.ContentProvider.RequestQueueSize > 0 and not Skipped do
		screen:WaitForChild("Container"):WaitForChild("LoadingText").Text = "Loading World: " .. game.ContentProvider.RequestQueueSize .. " objects left.";
		game:GetService("RunService").RenderStepped:wait();	
	end;
	FinishLoading = true;
	screen:WaitForChild("Container").Skip.Visible = false;
	screen.Container.Warning.Visible = false;
end;
local function GiveGameGUI()
	local GUI;
	if Phone then
		GUI = game.ReplicatedStorage.GUI.MainMobile:Clone()
	elseif Xbox then		
		GUI = game.ReplicatedStorage.GUI.MainXbox:Clone()
	else
		GUI = game.ReplicatedStorage.GUI.MainPC:Clone()
	end;
	GUI.Name = "MainGUI";
	GUI.Parent = game.Players.LocalPlayer.PlayerGui;
	game.Players.LocalPlayer.CharacterAdded:Connect(function()
		local GUI;
		if Phone then
			GUI = game.ReplicatedStorage.GUI.MainMobile:Clone()
		elseif Xbox then		
			GUI = game.ReplicatedStorage.GUI.MainXbox:Clone()
		else
			GUI = game.ReplicatedStorage.GUI.MainPC:Clone()
		end;
		GUI.Name = "MainGUI";
		GUI.Parent = game.Players.LocalPlayer.PlayerGui;
	end)
	game.Players.LocalPlayer:WaitForChild("PlayerGui"):SetTopbarTransparency(1);
end;
local function FadeOut()
	for i = 1, 60 do
		screen.Container.BackgroundTransparency = screen.Container.BackgroundTransparency + 1/60
		screen.Container.Images.Colored.ImageTransparency = screen.Container.Images.Colored.ImageTransparency + 1/60
		game:GetService("RunService").RenderStepped:wait();
	end;
end;
local notJoinedFriend = not JoinedFriend;
if notJoinedFriend then
	notJoinedFriend = not game.ReplicatedStorage.Remotes.Extras.IsVIPServer:InvokeServer();
	if not notJoinedFriend then
		notJoinedFriend = true;
		if game.Players.LocalPlayer.Name ~= "Nikilis" then
			notJoinedFriend = game.Players.LocalPlayer.Name == "mg8897";
		end;
	end;
end;
local function Play()
	if not Phone then
		LoadGame();
	end;
	if _G.Database == nil then
		screen:WaitForChild("Container"):WaitForChild("LoadingText").Text = "Loading Database...";
		while true do
			wait();
			if _G.Database ~= nil then
				break;
			end;		
		end;
	end;
	screen.Container.Images.Colored.Visible = true;
	screen.Container.Images.Colored.ImageTransparency = 0;
	screen.Container.Images.Grey.Visible = false;
	screen.Container.LoadingText.Text = "";
	screen.Container.Thumbs.Visible = false;
	wait(1);
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true);
	GiveGameGUI();
	game.StarterGui.ResetPlayerGuiOnSpawn = true;
	FadeOut();
	screen:Destroy();
	game.ReplicatedStorage.GUI:Destroy();
end;
local TestServerID = 188331334;
local TestServerHardcore = 7540947129;
local TestServerMinigames = 450611752;
local TestServerAssassin = 7540948238;
local MM2ID = 7533823031;
local HardcoreID = (game.PlaceId == MM2ID and 7540947129) or TestServerHardcore;
local MinigamesID = (game.PlaceId == MM2ID and 450611752) or TestServerMinigames;
local AssassinID = (game.PlaceId == MM2ID and 7540948238) or TestServerAssassin;
local TeleportService = game:GetService("TeleportService");
local IsVIPServer = game.ReplicatedStorage.Remotes.Extras.IsVIPServer:InvokeServer()
local ShowJoinMenu = (not JoinedFriend and (not IsVIPServer or game.Players.LocalPlayer.Name == "mg8897"));
local JoinFrame;
local FriendPlaceId;
local FriendGameId;
local function UpdateList(Friends)
	if not Friends then Friends = game.Players.LocalPlayer:GetFriendsOnline(); end;
	local Index = 0;
	JoinFrame.Friends.FriendsList.ScrollingFrame.Container:ClearAllChildren();
	script.FriendLayout:Clone().Parent = JoinFrame.Friends.FriendsList.ScrollingFrame.Container;
	for _,Friend in pairs(Friends) do
		if Friend.PlaceId == MM2ID or Friend.PlaceId == TestServerID or Friend.PlaceId == HardcoreID then
			local NewFrame = script.Friend:Clone();
			NewFrame.FriendName.Text = game.Players:GetNameFromUserIdAsync(Friend.VisitorId);
			NewFrame.GameMode.Text = (Friend.PlaceId == HardcoreID and "Hardcore") or "Casual";
			NewFrame.Position = UDim2.new(0,0,0,30*Index);
			NewFrame.Parent = JoinFrame.Friends.FriendsList.ScrollingFrame.Container;
			NewFrame.Join.MouseButton1Click:connect(function()
				JoinFrame.Friends.Visible = false;
				JoinFrame.Loading.Visible = true;
				local FoundFriend = false;
				for _,Player in pairs(game.Players:GetPlayers()) do if Player.UserId == Friend.VisitorId then FoundFriend = true; break; end;end;
				if not FoundFriend then
					FriendPlaceId = Friend.PlaceId;
					FriendGameId = Friend.GameId
					TeleportService:TeleportToPlaceInstance(FriendPlaceId,FriendGameId,game.Players.LocalPlayer,"",{Joined=true})
					wait(5);
					JoinFrame.Friends.Visible = false;
					JoinFrame.Retry.Visible = true;
					JoinFrame.Loading.Visible = false;
					spawn(function() while JoinFrame.Retry.Visible == true do JoinFrame.Retry.Spinner.Rotation = JoinFrame.Retry.Spinner.Rotation + 5; game:GetService("RunService").RenderStepped:wait(); end; end)
					spawn(function()
						local Attempts = 1;
						while JoinFrame.Retry.Visible == true do
							JoinFrame.Retry.Retrying.Text = "Retrying... (" .. Attempts .. ")";
							FriendPlaceId = Friend.PlaceId;
							FriendGameId = Friend.GameId
							TeleportService:TeleportToPlaceInstance(FriendPlaceId,FriendGameId,game.Players.LocalPlayer,"",{Joined=true})
							for i = 1,50 do
								wait(0.1);
								if not JoinFrame.Retry.Visible then
									break;
								end
							end
							Attempts = Attempts+1;
						end;
					end);
					UpdateList();
				else
					JoinFrame:Destroy();
					Play();
				end;
			end)
			Index = Index + 1;
		end;
	end;
end
local function JoinFriend()	
	if ShowJoinMenu then
		local Friends;
		pcall(function() Friends = game.Players.LocalPlayer:GetFriendsOnline(); end)
		if Friends and #Friends > 0 then
			local OnlineMM2 = false;
			for _,Friend in pairs(Friends) do 
				if Friend.PlaceId == MM2ID or Friend.PlaceId == TestServerID or Friend.PlaceId == HardcoreID then 
					OnlineMM2 = true; 
				end; 
			end;
			if OnlineMM2 then
				JoinFrame.Parent = game.Players.LocalPlayer.PlayerGui;
				UpdateList(Friends);
				JoinFrame.Friends.Play.MouseButton1Click:connect(function()
					JoinFrame:Destroy();
					Play();
				end)
			else
				Play();
			end;
		else
			Play();
		end;
	else
		Play();
	end
end
local function SelectGameMode()
	local GameMode = (not Phone and game.ReplicatedStorage.Remotes.Extras.GetData:InvokeServer("GameMode2")) or nil;
	local IsHardcore = (game.PlaceId == HardcoreID or game.PlaceId == TestServerHardcore);
	if (game.PlaceId == MM2ID or game.PlaceId == TestServerID) and not game:GetService("UserInputService").GamepadEnabled and not IsVIPServer and not JoinedFriend and not Phone then
		if GameMode == nil then
			local GameModeFrame = (not Phone and script.Gamemode:Clone()) or script.GamemodePhone:Clone();
			GameModeFrame.Parent = game.Players.LocalPlayer.PlayerGui;
			GameModeFrame.Select.Hardcore.Play.MouseButton1Click:connect(function()
				GameModeFrame.Select.Visible = false;
				GameModeFrame.Loading.Visible = true;
				game.ReplicatedStorage.ChangeGameMode:FireServer("Hardcore");
				game:GetService('TeleportService'):Teleport(HardcoreID);
			end)
			GameModeFrame.Select.Casual.Play.MouseButton1Click:connect(function()
				GameModeFrame:Destroy();
				game.ReplicatedStorage.ChangeGameMode:FireServer("Casual");
				JoinFriend();
			end)
			GameModeFrame.Select.Assassin.Play.MouseButton1Click:connect(function()
				GameModeFrame:Destroy();
				game.ReplicatedStorage.ChangeGameMode:FireServer("Assassin");
				game:GetService('TeleportService'):Teleport(AssassinID);
				screen:WaitForChild("Container"):WaitForChild("LoadingText").Text = "Switching Game Mode...";
			end)
		elseif GameMode == "Minigames" then
			print("Teleporting to Minigames..");
			wait(1);
			game:GetService('TeleportService'):Teleport(MinigamesID);
		elseif GameMode == "Hardcore" then
			print("Teleporting to Hardcore..");
			wait(1);
			game:GetService('TeleportService'):Teleport(HardcoreID);
		elseif GameMode == "Assassin" then
			print("Teleporting to Assassin..");
			wait(1);
			game:GetService('TeleportService'):Teleport(AssassinID);
		elseif GameMode == "Casual" then
			JoinFriend();
		end;
	else
		JoinFriend();
	end;
end
local function ConnectJoinFrame()
	JoinFrame = (script.Join:Clone())
	JoinFrame.Retry.Retry.MouseButton1Click:connect(function()
		JoinFrame.Retry.Visible = false;
		JoinFrame.Friends.Visible = true;
	end)
end
local DeviceNot = {
	["Tablet"] = "Phone", 
	["Phone"] = "Tablet"
};
local function SelectDevice()
	local DeviceSelect = script:WaitForChild("DeviceSelect");
	local LastDevice = game.ReplicatedStorage.GetData:InvokeServer("LastDevice")
	local contentToLoad = { "https://www.roblox.com/asset/?id=466263397", "https://www.roblox.com/asset/?id=466240313" }
	game:GetService("ContentProvider"):PreloadAsync(contentToLoad)
	wait();
	DeviceSelect.Parent = game.Players.LocalPlayer.PlayerGui;
	if LastDevice then
		DeviceSelect:WaitForChild("Container"):WaitForChild(LastDevice):WaitForChild("Last").Visible = true;
		DeviceSelect:WaitForChild("Container"):WaitForChild(DeviceNot[LastDevice]):WaitForChild("Cover").Visible = true;
		DeviceSelect:WaitForChild("Container"):WaitForChild(DeviceNot[LastDevice]):WaitForChild("Switch").Visible = true;
	end
	DeviceSelect:WaitForChild("Container"):WaitForChild("Phone"):WaitForChild("Button").MouseButton1Click:connect(function()
		Phone = true;
		spawn(function()game.ReplicatedStorage.ChangeLastDevice:FireServer("Phone");end);
		DeviceSelect:Destroy();
		ConnectJoinFrame();
		SelectGameMode();
	end)
	DeviceSelect:WaitForChild("Container"):WaitForChild("Tablet"):WaitForChild("Button").MouseButton1Click:connect(function()
		spawn(function()game.ReplicatedStorage.ChangeLastDevice:FireServer("Tablet");end);
		DeviceSelect:Destroy();
		ConnectJoinFrame();
		SelectGameMode();
	end)
end;
UIS:GetLastInputType();
if game.Players.LocalPlayer.FollowUserId > 0 and not IsVIPServer then
	local FoundPlayer = false;
	for _,Player in pairs(game.Players:GetChildren()) do
		if Player.userId == game.Players.LocalPlayer.FollowUserId then
			FoundPlayer = true;
			break;
		end
	end
	if not FoundPlayer then
		screen.Container.LoadingText.Text = "Joining User...";
		game.ReplicatedStorage.Follow:FireServer();	
		wait(5);
		screen.Container.LoadingText.Text = "Failed to join user.";
		wait(1);
	end;
	if game:GetService("UserInputService").TouchEnabled then
		SelectDevice()
	else
		SelectGameMode();
	end;
elseif (not Xbox) and (not Phone) then
	if game:GetService("UserInputService").TouchEnabled then
		SelectDevice()
	else
		SelectGameMode();
		game.Players.LocalPlayer.PlayerGui:SetAttribute("Device", "PC")
	end;
else
	Play();
end;