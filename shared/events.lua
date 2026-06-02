--[[
    ec_outfitbag — Event- & Callback-Namen (Präfix ECOFB)
    ---------------------------------------------------------------------------
    Alle Net-Events und lib.callbacks nutzen das Präfix ECOFB (ec_outfitbag),
    um Kollisionen mit anderen Resources zu vermeiden.
]]

ECOFB = ECOFB or {}

ECOFB.Events = {
    Server = {
        RequestOpen = 'ECOFB:Server:RequestOpen',
        RequestPlace = 'ECOFB:Server:RequestPlace',
        RequestPickup = 'ECOFB:Server:RequestPickup',
        SaveOutfit = 'ECOFB:Server:SaveOutfit',
        ApplyOutfit = 'ECOFB:Server:ApplyOutfit',
        DeleteOutfit = 'ECOFB:Server:DeleteOutfit',
        SelectOutfit = 'ECOFB:Server:SelectOutfit',
        SetCategory = 'ECOFB:Server:SetCategory',
        EditOutfit = 'ECOFB:Server:EditOutfit',
        CloseBag = 'ECOFB:Server:CloseBag',
        SyncWorldBags = 'ECOFB:Server:SyncWorldBags',
    },
    Client = {
        OpenBag = 'ECOFB:Client:OpenBag',
        CloseBag = 'ECOFB:Client:CloseBag',
        SyncWorldBags = 'ECOFB:Client:SyncWorldBags',
        SpawnBag = 'ECOFB:Client:SpawnBag',
        RemoveBag = 'ECOFB:Client:RemoveBag',
        Notify = 'ECOFB:Client:Notify',
        OpenAppearance = 'ECOFB:Client:OpenAppearance',
        StartSaveOutfit = 'ECOFB:Client:StartSaveOutfit',
    },
}

ECOFB.Callbacks = {
    GetBagData = 'ECOFB:Callback:GetBagData',
    CanAccessBag = 'ECOFB:Callback:CanAccessBag',
    GetPlayerSlots = 'ECOFB:Callback:GetPlayerSlots',
    FindFreeSlot = 'ECOFB:Callback:FindFreeSlot',
    GetOutfitAppearance = 'ECOFB:Callback:GetOutfitAppearance',
    GetOutfitDetails = 'ECOFB:Callback:GetOutfitDetails',
}
