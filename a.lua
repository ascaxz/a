--[[

    Wow it's open source hooray now fuck off ya skid
    It's a pretty shite example anyway lmao

--]]

local Esp = {
	Container = {},
	Settings = {
		Enabled = false,
        Name = false,
		Box = false,
		Health = false,
		Tracer = false,
        TeamCheck = false,
		TextSize = 16,
        Range = 0,
        HpLow = Color3.new(1, 0, 0),
        HpHigh = Color3.new(0, 1, 0),
        Font = 0,
        BoxOutline = false,
        HPOutline = false,
        BoxColor = Color3.new(1, 1, 1)
	}
}
local Camera = workspace.CurrentCamera
local WorldToViewportPoint = Camera.WorldToViewportPoint
local v2new = Vector2.new
local Player = game:GetService("Players").LocalPlayer
local TracerStart = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 35)

local CheckVis = function(esp, inview)
	if not inview or (Esp.Settings.TeamCheck and Esp.TeamCheck(esp.Player)) or (esp.Root.Position - Camera.CFrame.Position).Magnitude > Esp.Settings.Range then
		esp.Name.Visible = false
		esp.Box.Visible = false
		esp.Health.Visible = false
		esp.Tracer.Visible = false
        esp.OutlineBox.Visible = false
        esp.OutlineHealth.Visible = false
		return
	end
	esp.Name.Visible = Esp.Settings.Name
	esp.Box.Visible = Esp.Settings.Box
	esp.Health.Visible = Esp.Settings.Health
	esp.Tracer.Visible = Esp.Settings.Tracer
    esp.OutlineBox.Visible = Esp.Settings.BoxOutline
    esp.OutlineHealth.Visible = Esp.Settings.HPOutline
end

-- newcclosure breaks Drawing.new apparently
Esp.Add = function(plr, root, col)
	if Esp.Container[root] then
        local Container = Esp.Container[root]
        Container.Connection:Disconnect()
		Container.Name:Remove()
		Container.Box:Remove()
		Container.Health:Remove()
		Container.Distance:Remove()
		Container.Tracer:Remove()
        Container.OutlineHealth:Remove()
        Container.OutlineBox:Remove()
		Esp.Container[root] = nil
	end
	local Holder = {
		Name = Drawing.new("Text"),
		Box = Drawing.new("Square"),
        OutlineBox = Drawing.new("Square"),
		Health = Drawing.new("Square"),
        OutlineHealth = Drawing.new("Square"),
		Tracer = Drawing.new("Line"),
		Player = plr,
		Root = root,
		Colour = col
	}
	Esp.Container[root] = Holder
    Holder.Name.Text = plr.Name
    Holder.Name.Size = Esp.Settings.TextSize
    Holder.Name.Center = true
	Holder.Name.Color = col
    Holder.Name.Outline = true
    Holder.Name.Font = Esp.Settings.Font;
    Holder.Box.Filled = false
    Holder.Box.Thickness = 1
	Holder.OutlineBox.Color = col
	Holder.OutlineBox.Filled = false
    Holder.OutlineBox.Thickness = 1
    Holder.OutlineHealth.Filled = false
    Holder.OutlineHealth.Thickness = 1
	Holder.Health.Thickness = 1
	Holder.Health.Color = Color3.fromRGB(0, 255, 0)
    Holder.Health.Filled = true
	Holder.Tracer.From = TracerStart
	Holder.Tracer.Color = col
    Holder.Tracer.Thickness = 1
	Holder.Connection = game:GetService("RunService").Stepped:Connect(function()
		if Esp.Settings.Enabled then
			local Pos, Vis = WorldToViewportPoint(Camera, root.Position)
			if Vis then
				--[[local X = 2200 / Pos.Z
				local BoxSize = v2new(X, X * 1.4)
				local Health = Esp.GetHealth(plr)
				Holder.Name.Position = v2new(Pos.X, Pos.Y - BoxSize.X / 2 - (4 + Esp.Settings.TextSize))
				Holder.Box.Size = BoxSize
				Holder.Box.Position = v2new(Pos.X - BoxSize.X / 2, Pos.Y - BoxSize.Y / 2)
				Holder.Health.Color = Health > 0.66 and Color3.new(0, 1, 0) or Health < 0.33 and Color3.new(1, 0, 0) or Color3.new(1, 1, 0)
				Holder.Health.Size = v2new(1.5, BoxSize.Y * Health)
				Holder.Health.Position = v2new(Pos.X - (BoxSize.X / 2 + 4), (Pos.Y - BoxSize.Y / 2) + ((1 - Health) * BoxSize.Y))
				Holder.Distance.Text = math.floor((root.Position - Camera.CFrame.Position).Magnitude) .. " Studs"
				Holder.Distance.Position = v2new(Pos.X, Pos.Y + BoxSize.X / 2 + 4)
				Holder.Tracer.To = v2new(Pos.X, Pos.Y + BoxSize.Y / 2)]]
                local orientation, size = utils.getboundingboxcharacter(root.Parent);
                local truecenter = Vector3.new(root.Position.X, orientation.Y, root.Position.Z);
                local pos = WorldToViewportPoint(Camera, truecenter);
                local height = Vector3.new(0, size.Y / 2, 0);
                local up = WorldToViewportPoint(Camera, truecenter + height);
                local down = WorldToViewportPoint(Camera, truecenter - height);
                local trueheight = math.abs(up.Y - down.Y);
                Holder.Box.Size = Vector2.new(trueheight / 2, trueheight);
                Holder.Box.Position = Vector2.new(pos.X - (Holder.Box.Size.X / 2), pos.Y - (Holder.Box.Size.Y / 2));
                Holder.OutlineBox.Size = Vector2.new(Holder.Box.Size.X - 2, Holder.Box.Size.Y - 2);
                Holder.OutlineBox.Position = Vector2.new(Holder.Box.Position.X + 1, Holder.Box.Position.Y + 1);
                Holder.OutlineHealth.Size = Vector2.new(4, Holder.OutlineBox.Size.Y + 2);
                Holder.OutlineHealth.Position = Vector2.new(Holder.OutlineBox.Position.X - 4, Holder.OutlineBox.Position.Y - 1);
                Holder.Health.Size = Vector2.new(2, (-trueheight * Esp.GetHealth(plr)));
                Holder.Health.Position = Vector2.new(Holder.OutlineBox.Position.X - 3, Holder.OutlineBox.Position.Y + Holder.Box.Size.Y - 3);
                Holder.Health.Color = Esp.Settings.HpLow:Lerp(Esp.Settings.HpHigh, Esp.GetHealth(plr));
                Holder.Name.Position = Vector2.new(Holder.OutlineBox.Position.X + (Holder.OutlineBox.Size.X / 2), Holder.OutlineBox.Position.Y - Holder.Name.TextBounds.Y - 1);
                Holder.Tracer.To = Vector2.new(pos.X, pos.Y + Holder.OutlineBox.Size.Y / 2);
			end
			CheckVis(Holder, Vis)
		elseif Holder.Name.Visible then
			Holder.Name.Visible = false
			Holder.Box.Visible = false
			Holder.Health.Visible = false
			Holder.Tracer.Visible = false
            Holder.OutlineBox.Visible = false
            Holder.OutlineHealth.Visible = false
		end
	end)
end

Esp.Remove = function(root)
	for i, v in next, Esp.Container do
		if i == root then
			v.Connection:Disconnect()
			v.Name:Remove()
			v.Box:Remove()
			v.Health:Remove()
			v.Tracer:Remove()
            v.OutlineHealth:Remove()
            v.OutlineBox:Remove()
		end
	end
	Esp.Container[root] = nil
end

Esp.TeamCheck = function(plr)
	return plr.Team == Player.Team
end-- can b overwritten for games that don't use default teams

Esp.GetHealth = function(plr)
	return plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth
end -- can be overwritten for games that don't use default characters

Esp.UpdateTextSize = function(num)
	Esp.Settings.TextSize = num
	for i, v in next, Esp.Container do
		v.Name.Size = num
	end
end

Esp.UpdateFontSize = function(num)
    Esp.Settings.Font = num
    for i, v in next, Esp.Container do
        v.Name.Font = num
    end
end

Esp.UpdateTracerStart = function(pos)
    TracerStart = pos
    for i, v in next, Esp.Container do
        v.Tracer.From = pos
    end
end

Esp.ToggleRainbow = function(bool)
	if Esp.RainbowConn then
		Esp.RainbowConn:Disconnect()
	end
	if bool then
		Esp.RainbowConn = game:GetService("RunService").Heartbeat:Connect(function()
			local Colour = Color3.fromHSV(tick() % 12 / 12, 1, 1)
			for i, v in next, Esp.Container do
				v.Name.Color = Colour
				v.Box.Color = Colour
				v.Tracer.Color = Colour
			end
		end)
	else
		for i, v in next, Esp.Container do
			v.Name.Color = v.Colour
			v.Box.Color = v.Colour
			v.Tracer.Color = v.Colour
		end
	end
end

return Esp
