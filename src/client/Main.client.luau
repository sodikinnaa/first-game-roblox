local HUDController = require(script.Parent.Controllers.HUDController)
local SummitController = require(script.Parent.Controllers.SummitController)

-- Bind finish events before HUD waits for leaderstats.
SummitController.start()
HUDController.start()
