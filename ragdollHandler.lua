local ServerScriptService = game:GetService("ServerScriptService")

local eventDispatcher = _G.import("eventDispatcher")
local animationService = _G.import("animationLibrary")
local globalService = _G.import("globalService")

local collectionService = game:GetService("CollectionService")
local ragdollService = require(ServerScriptService.Services.ragdollService)
local animService = require(game.ReplicatedStorage.Libraries.animationLibrary)

local function pickupRagdoll(player, character, hrp, upperTorso, ragdoll)
	if character:FindFirstChild("carriedRagdoll") then return end
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	local raycastResult = workspace:Raycast(hrp.Position, Vector3.new(0,-3.5,0), raycastParams)
	
	if raycastResult then
		local hitPart = raycastResult.Instance
		local ragdolledCharacter = hitPart.Parent

		if ragdolledCharacter:IsA("Accessory") or ragdolledCharacter:IsA("Tool") then
			if ragdolledCharacter.Parent:FindFirstChild("Humanoid") then
				ragdolledCharacter = ragdolledCharacter.Parent 
			end
		end

		if hitPart.Name == "Handle" then 
			if hitPart.Parent.Parent:FindFirstChild("Humanoid") then
				ragdolledCharacter = hitPart.Parent.Parent
			end
		end
		
		if ragdolledCharacter:FindFirstChild("Humanoid") and ragdolledCharacter == ragdoll then
			if ragdoll:GetAttribute("ragdolled") == true then
				if not collectionService:HasTag(character, "Action") then
					local ragHRP = ragdoll:FindFirstChild("HumanoidRootPart")
					
					if ragHRP and hrp then
						ragdollService:pickupRagdoll(ragdoll, upperTorso, character)
					end
				end
			end
		end
	end
end


local function dropRagdoll(player, character)
	if character and character:FindFirstChild("carriedRagdoll") then
		ragdollService:dropRagdoll(character)
	end
end

return {Priority=3,
	Run=function()
		eventDispatcher.remoteConnect("pickupRagdoll", pickupRagdoll)
		eventDispatcher.remoteConnect("dropRagdoll", dropRagdoll)
end}
