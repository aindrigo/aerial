hook.Add("Initialize", "aerialInitialize", function()
    net.Start("aerial.SyncAttachments")
    net.SendToServer()
end)