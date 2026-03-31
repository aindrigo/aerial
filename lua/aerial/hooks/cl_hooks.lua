hook.Add("Initialize", "aerial_Initialize", function()
    net.Start("aerial.SyncAttachments")
    net.SendToServer()
end)