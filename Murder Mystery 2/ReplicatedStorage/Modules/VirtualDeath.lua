-- Decompiled with the Synapse X Luau decompiler.

return function(p1)
	local v1 = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.2);
	local v2 = {
		Transparency = 1, 
		Color = Color3.fromRGB(255, 255, 255)
	};
	local v3 = {
		Transparency = 1
	};
	local v4, v5, v6 = pairs(p1:GetDescendants());
	while true do
		local v7, v8 = v4(v5, v6);
		if not v7 then
			break;
		end;
		if v8:IsA("CharacterAppearance") then
			v8:Destroy();
		end;
		if v8:IsA("Decal") then
			game:GetService("TweenService"):Create(v8, v1, v3):Play();
		end;
		if v8:FindFirstChild("Mesh") then
			v8.Mesh.TextureId = "";
			v8.Mesh.VertexColor = Vector3.new(175, 221, 255);
		end;
		if v8:IsA("BasePart") then
			v8.CanCollide = false;
			v8.BrickColor = BrickColor.new("Pastel light blue");
			if v8:IsA("MeshPart") then
				v8.TextureID = "";
			end;
			game:GetService("TweenService"):Create(v8, v1, v2):Play();
			local v9 = script.Frost:Clone();
			v9.Parent = v8;
			v9.Enabled = true;
			spawn(function()
				wait(0.25);
				v9.Enabled = false;
			end);
		end;
		if v8:IsA("BasePart") then
			game:GetService("PhysicsService"):SetPartCollisionGroup(v8, "AnchoredRagdolls");
		end;	
	end;
end;
