local Module = {}

local ItemModule = require(script.Parent.ItemModule)
local MysteryBoxes = _G.Database.MysteryBox
local Weapons = _G.Database.Weapons

local Random = Random.new
local rarities = {
	Common = 70;
	Uncommon = 15;
	Rare = 10;
	Legendary = 5
}

function Module.OpenBox(boxName, weaponName)
	local box = MysteryBoxes[boxName]
	local numItems = Random:NextInteger(23, 27)
	
	-- Get a table of weapon IDs for each rarity in the box
	local weaponRarityTable = {
		Common = {}, 
		Uncommon = {}, 
		Rare = {}, 
		Legendary = {}
	}
	for _, weaponId in pairs(box.Contents) do
		local weapon = Weapons[weaponId]
		table.insert(weaponRarityTable[weapon.Rarity], weaponId)
	end
	
	-- Clear the item container and add a new grid layout to it
	local container = script.Unboxing.Main.Container.Background.ItemContainer.OffsetContainer.MainContainer
	container:ClearAllChildren()
	local gridLayout = script.UIGridLayout:Clone()
	gridLayout.Parent = container
	local cellSizeOffset = gridLayout.CellSize.X.Offset
	container.Size = UDim2.new(0, cellSizeOffset * (numItems + 5), 1, 0)
	container.Position = UDim2.new(0.5, cellSizeOffset / 2, 0, 0)
	
	-- Function to get a random weapon ID, weapon table, and rarity string
	local function getRandomWeapon()
		local rarity = Random:NextInteger(1, 500) == 1 and "Godly" or rarities[Random:NextInteger(1, 100)]
		local weaponId = rarity == "Godly" and box.GodlyCover or weaponRarityTable[rarity][Random:NextInteger(1, #weaponRarityTable[rarity])]
		return weaponId, Weapons[weaponId], rarity
	end
	
	-- Add each item to the container and display it
	for i = 1, numItems + 5 do
		local item
		if i == numItems then
			local rarity = Weapons[weaponName].Rarity
			item = rarity == "Godly" and box.GodlyCover and Weapons[box.GodlyCover] or Weapons[weaponName]
		else
			local weaponId, weaponTable = getRandomWeapon()
			item = weaponTable
		end
		local itemFrame = script.NewItem:Clone()
		ItemModule.DisplayItem(itemFrame, item)
		itemFrame.LayoutOrder = i
		itemFrame.Parent = container
	end
	
	-- Display the pre-items
	local preItem1Id, preItem1Table = getRandomWeapon()
	ItemModule.DisplayItem(container.PreItem1, preItem1Table)
	local preItem2Id, preItem2Table = getRandomWeapon()
	ItemModule.DisplayItem(container.PreItem2, preItem2Table)
	
	-- Animate the container and destroy it
	local unboxingFrame = script.Unboxing:Clone()
	unboxingFrame.Parent = game.Players.LocalPlayer.PlayerGui
	local animationTime = 4 + Random:NextNumber()
	container:TweenPosition(
		UDim2.new(0.5, -(cellSizeOffset * numItems) + Random:NextInteger(-(cellSizeOffset / 2 - 5), cellSizeOffset / 2 - 5) + cellSizeOffset - cellSizeOffset / 2, 
		0, 0), 
		"Out", 
		"Quad", 
		animationTime, 
		true)
	wait(animationTime + 1)
	unboxingFrame:Destroy()
end
-- Load the pets and tween service
local Pets = _G.Database.Pets
local TweenService = game:GetService("TweenService")

-- Set up tween info for egg cracking animation
local eggTweenInfo = TweenInfo.new(0.125, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

-- Define function to hatch an egg
function Module.HatchEgg(player, petIndex)
	-- Create the hatching UI and set the pet icon
	local hatchingUI = script.Hatching:Clone()
	hatchingUI.Parent = player.PlayerGui
	hatchingUI.Cracked.PetIcon.Image = ItemModule.GetImage(Pets[petIndex].Image)
	
	-- Wait a moment before starting the egg cracking animation
	wait(1)

	-- Get the egg object
	local egg = hatchingUI.Uncracked.Egg

	-- Set up the egg cracking animation
	local eggTweens = {}
	for i = 1, 10 do
		local rotation = i % 2 == 1 and 10 or -10
		table.insert(eggTweens, TweenService:Create(egg, eggTweenInfo, {Rotation = rotation}))
	end

	-- Play the egg cracking animation
	for _, tween in ipairs(eggTweens) do
		tween:Play()
		wait(0.125)
	end

	-- Wait a moment before showing the hatched pet
	wait(0.5)

	-- Show the hatched pet and wait a moment before destroying the hatching UI
	hatchingUI.Uncracked.Visible = false
	hatchingUI.Cracked.Visible = true
	wait(1)
	hatchingUI:Destroy()
end

-- Get all ImageLabels in the script and preload their content
local descendants = script:GetDescendants()
local imageButtons = {}

for _, descendant in ipairs(descendants) do
	if descendant:IsA("ImageButton") then
		table.insert(imageButtons, descendant)
	end
end
game:GetService("ContentProvider"):PreloadAsync(imageButtons)

-- Return the optimized module
return Module
