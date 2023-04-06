-- Decompiled with the Synapse X Luau decompiler.

local u1 = {
	XPTable = {}
};
(function(p1)
	local v1 = 0;
	for v2 = 1, 100 do
		local v3 = v2 - 1;
		u1.XPTable[v2] = v1 + ((1000 + 225 * v2) * v2 - 225 * (v2 * (0.5 * (v2 - 1))) - 1000 - 225 - ((1000 + 225 * v3) * v3 - 225 * (v3 * (0.5 * (v3 - 1))) - 1000 - 225));
		if p1 then
			print("Level: ", v2, " XP: ", v2, (1000 + 225 * v2) * v2 - 225 * (v2 * (0.5 * (v2 - 1))) - 1000 - 225);
		end;
	end;
end)();
function u1.GetLevel(p2)
	p2 = p2 and 0;
	if p2 >= 1237500 then
		return 100, u1.XPTable[100];
	end;
	for v4, v5 in pairs(u1.XPTable) do
		local v6 = u1.XPTable[v4 + 1];
		if v6 ~= nil and v5 <= p2 and p2 < v6 then
			return v4, v6;
		end;
	end;
	return 1, u1.XPTable[2];
end;
function u1.GetXP(p3)
	p3 = p3 and 1;
	return (1000 + 225 * p3) * p3 - 225 * (p3 * (0.5 * (p3 - 1))) - 1000 - 225;
end;
function u1.GetProgressToNextLevel(p4)
	local v7, v8 = u1.GetLevel(p4);
	local v9 = u1.GetXP(v7);
	return (p4 - v9) / (v8 - v9);
end;
return u1;
