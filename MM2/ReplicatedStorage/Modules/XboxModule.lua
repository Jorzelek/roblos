-- Decompiled with the Synapse X Luau decompiler.

local v1 = {};
local l__ContextActionService__1 = game:GetService("ContextActionService");
function v1.Bind(p1, p2, p3)
	l__ContextActionService__1:BindAction(p1, function(p4, p5)
		if p5 == Enum.UserInputState.Begin and not _G.PauseBinds then
			p3();
		end;
	end, false, p2);
end;
function v1.Unbind(p6, p7, p8)
	l__ContextActionService__1:UnbindAction(p6);
end;
return v1;
