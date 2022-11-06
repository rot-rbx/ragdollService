local collectionService = game:GetService("CollectionService")

local starterGui = game:GetService("StarterGui")
local uis = game:GetService("UserInputService")

local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local repStorage = game:GetService("ReplicatedStorage")

local libraries = repStorage:FindFirstChild("Libraries")
local data = repStorage:FindFirstChild("Data")

local animService = require(libraries:FindFirstChild("animationLibrary"))

local eventDispatcher = require(libraries:FindFirstChild("eventDispatcher"))
local globalService = _G.import("globalService")

local actionLibrary = _G.import("actionLibrary")
local action = actionLibrary.action

local checkTags = actionLibrary.checkTags
local checkTag = actionLibrary.checkTag

local camera = workspace:FindFirstChild("Camera")
local player = game.Players.LocalPlayer

local mouse = player:GetMouse()

local function EnableHumanoid(Humanoid, b)
	task.spawn(function()
		for _,v in next,Enum.HumanoidStateType:GetEnumItems() do
			if (v ~= Enum.HumanoidStateType.None and v ~= Enum.HumanoidStateType.Dead and v ~= Enum.HumanoidStateType.Physics) then
				Humanoid:SetStateEnabled(v, b)
			end
		end
	end)
end

local function pickupRagdoll(...)
	local character, hrp, humanoid, upperTorso = ...
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	local raycastResult = workspace:Raycast(hrp.Position, Vector3.new(0,-3.25,0), raycastParams)
	
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
		
		if ragdolledCharacter:FindFirstChild("Humanoid") then
			if ragdolledCharacter:GetAttribute("ragdolled") == true then
				if not collectionService:HasTag(character, "Action") then
					globalService.get("sessions", player)["states"]["carrying"] = true
					
					table.insert(globalService.get("sessions", player)["cameraBlacklist"], ragdolledCharacter)
					eventDispatcher.fire("updateCameraBlacklist")
					local sanityCheck = eventDispatcher.remoteFire("pickupRagdoll", character, hrp, upperTorso, ragdolledCharacter)
					
					if not sanityCheck then
						globalService.get("sessions", player)["states"]["carrying"] = false
					end
					
				end
			end
		end
	end
end

local function dropRagdoll(character)
	eventDispatcher.remoteFire("dropRagdoll", character)
end


return {Priority=5,
	Run=function()
		repeat task.wait() until player.Character
		
		local character = player.Character
		local hrp = character:WaitForChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		local upperTorso = character:WaitForChild("UpperTorso")
		
		
		uis.InputBegan:Connect(function(input, gameProcessed)
			if character:GetAttribute("ragdolled") == true then return end
			if input.KeyCode == Enum.KeyCode.V then
				if not character:FindFirstChild("carriedRagdoll") then
					pickupRagdoll(character, hrp, humanoid, upperTorso)
				else
					dropRagdoll(character)
				end
			end

		end)
		
		eventDispatcher.remoteConnect("ragdollClient", function(bool)
			if bool == true then
				EnableHumanoid(humanoid, false)
				humanoid:ChangeState(Enum.HumanoidStateType.Physics)
				camera.CameraSubject = upperTorso

			else
				EnableHumanoid(humanoid, true)
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				camera.CameraSubject = humanoid
			end
		end)
	end
}