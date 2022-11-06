local globalService = require(game.ReplicatedStorage.Libraries.globalService)
local eventDispatcher = require(game.ReplicatedStorage.Libraries.eventDispatcher)
local animService = require(game.ReplicatedStorage.Libraries.animationLibrary)

local actionLibrary = require(game.ReplicatedStorage.Libraries.actionLibrary)

local action = actionLibrary.action
local checkTags = actionLibrary.checkTags
local checkTag = actionLibrary.checkTag

local serverStorage = game:GetService("ServerStorage")
local httpService = game:GetService("HttpService")

local ragdollService = {}

ragdollService.__index = ragdollService

local function EnableHumanoid(Humanoid, b)
	task.spawn(function()
		for _,v in next,Enum.HumanoidStateType:GetEnumItems() do
			if (v ~= Enum.HumanoidStateType.None and v ~= Enum.HumanoidStateType.Dead and v ~= Enum.HumanoidStateType.Physics) then
				Humanoid:SetStateEnabled(v, b)
			end
		end
	end)
end

local JointParent = {}
local ragdollConnections = {}

function ragdollService:ragdoll(character)
	local player = game.Players:GetPlayerFromCharacter(character)
	local humanoid = character:FindFirstChild("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local upperTorso = character:FindFirstChild("UpperTorso")

	local uniqueID = character:GetAttribute("ragdollID") or httpService:GenerateGUID()

	if character:GetAttribute("ragdolled") == true then return end
	
	if player then
		character:SetAttribute("LockedTorso", true)
	end
	
	local folder = character:FindFirstChild("RagdollConstraints") or Instance.new("Folder")
	folder.Name = "RagdollConstraints"
	folder.Parent = character
	
	character:SetAttribute("ragdolled", true)
	character:SetAttribute("ragdollID", uniqueID)
	
	local mJointParent = JointParent[uniqueID]
	if (not mJointParent) then mJointParent = {} JointParent[uniqueID] = mJointParent end
	if (not hrp.Anchored) then
		if player then
			eventDispatcher.remoteFire(player, "ragdollClient", true)
			pcall(function()
				if player then
					upperTorso:SetNetworkOwner(player)
				end
			end)
		end
	end
	
	if not player then
		upperTorso:SetNetworkOwner(nil)
		EnableHumanoid(humanoid, false)
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	end
	
	local constraints = {}

	local NeckConstraint = Instance.new('HingeConstraint')
	NeckConstraint.Name = 'RagdollNeck'
	NeckConstraint.LimitsEnabled = true
	NeckConstraint.LowerAngle = 0
	NeckConstraint.UpperAngle = 0
	NeckConstraint.Attachment0 = character.UpperTorso['NeckRigAttachment']
	NeckConstraint.Attachment1 = character.Head['NeckRigAttachment']
	NeckConstraint.Parent = folder

	local WaistConstraint = Instance.new('BallSocketConstraint')
	WaistConstraint.Name = 'RagdollWaist'
	WaistConstraint.Attachment0 = character.LowerTorso['WaistRigAttachment']
	WaistConstraint.Attachment1 = character.UpperTorso['WaistRigAttachment']
	table.insert(constraints, WaistConstraint)

	local LeftWristConstraint = Instance.new('HingeConstraint')
	LeftWristConstraint.Name = 'RagdollLeftWrist'
	LeftWristConstraint.LimitsEnabled = true
	LeftWristConstraint.LowerAngle = 0
	LeftWristConstraint.UpperAngle = 0
	LeftWristConstraint.Attachment0 = character.LeftLowerArm['LeftWristRigAttachment']
	LeftWristConstraint.Attachment1 = character.LeftHand['LeftWristRigAttachment']
	LeftWristConstraint.Parent = folder

	local RightWristConstraint = Instance.new('HingeConstraint')
	RightWristConstraint.Name = 'RagdollRightWrist'
	RightWristConstraint.LimitsEnabled = true
	RightWristConstraint.LowerAngle = 0
	RightWristConstraint.UpperAngle = 0
	RightWristConstraint.Attachment0 = character.RightLowerArm['RightWristRigAttachment']
	RightWristConstraint.Attachment1 = character.RightHand['RightWristRigAttachment']
	RightWristConstraint.Parent = folder

	local LeftKneeConstraint = Instance.new('BallSocketConstraint')
	LeftKneeConstraint.Name = 'RagdollLeftKnee'
	LeftKneeConstraint.Attachment0 = character.LeftUpperLeg['LeftKneeRigAttachment']
	LeftKneeConstraint.Attachment1 = character.LeftLowerLeg['LeftKneeRigAttachment']
	table.insert(constraints, LeftKneeConstraint)

	local RightKneeConstraint = Instance.new('BallSocketConstraint')
	RightKneeConstraint.Name = 'RagdollRightKnee'
	RightKneeConstraint.Attachment0 = character.RightUpperLeg['RightKneeRigAttachment']
	RightKneeConstraint.Attachment1 = character.RightLowerLeg['RightKneeRigAttachment']
	table.insert(constraints, RightKneeConstraint)

	local LeftAnkleConstraint = Instance.new('HingeConstraint')
	LeftAnkleConstraint.Name = 'RagdollLeftAnkle'
	LeftAnkleConstraint.LimitsEnabled = true
	LeftAnkleConstraint.LowerAngle = 0
	LeftAnkleConstraint.UpperAngle = 0
	LeftAnkleConstraint.Attachment0 = character.LeftLowerLeg['LeftAnkleRigAttachment']
	LeftAnkleConstraint.Attachment1 = character.LeftFoot['LeftAnkleRigAttachment']
	LeftAnkleConstraint.Parent = folder

	local RightAnkleConstraint = Instance.new('HingeConstraint')
	RightAnkleConstraint.Name = 'RagdollRightAnkle'
	RightAnkleConstraint.LimitsEnabled = true
	RightAnkleConstraint.LowerAngle = 0
	RightAnkleConstraint.UpperAngle = 0
	RightAnkleConstraint.Attachment0 = character.RightLowerLeg['RightAnkleRigAttachment']
	RightAnkleConstraint.Attachment1 = character.RightFoot['RightAnkleRigAttachment']
	RightAnkleConstraint.Parent = folder

	local LeftShoulderConstraint = Instance.new('BallSocketConstraint')
	LeftShoulderConstraint.Name = 'RagdollLeftShoulder'
	LeftShoulderConstraint.Attachment0 = character.UpperTorso['LeftShoulderRigAttachment']
	LeftShoulderConstraint.Attachment1 = character.LeftUpperArm['LeftShoulderRigAttachment']
	table.insert(constraints, LeftShoulderConstraint)

	local RightShoulderConstraint = Instance.new('BallSocketConstraint')
	RightShoulderConstraint.Name = 'RagdollRightShoulder'
	RightShoulderConstraint.Attachment0 = character.UpperTorso['RightShoulderRigAttachment']
	RightShoulderConstraint.Attachment1 = character.RightUpperArm['RightShoulderRigAttachment']
	table.insert(constraints, RightShoulderConstraint)

	local LeftElbowConstraint = Instance.new('BallSocketConstraint')
	LeftElbowConstraint.Name = 'RagdollLeftElbow'
	LeftElbowConstraint.Attachment0 = character.LeftUpperArm['LeftElbowRigAttachment']
	LeftElbowConstraint.Attachment1 = character.LeftLowerArm['LeftElbowRigAttachment']
	table.insert(constraints, LeftElbowConstraint)

	local RightElbowConstraint = Instance.new('BallSocketConstraint')
	RightElbowConstraint.Name = 'RagdollRightElbow'
	RightElbowConstraint.Attachment0 = character.RightUpperArm['RightElbowRigAttachment']
	RightElbowConstraint.Attachment1 = character.RightLowerArm['RightElbowRigAttachment']
	table.insert(constraints, RightElbowConstraint)

	local LeftHipConstraint = Instance.new('BallSocketConstraint')
	LeftHipConstraint.Name = 'RagdollLeftHip'
	LeftHipConstraint.Attachment0 = character.LowerTorso['LeftHipRigAttachment']
	LeftHipConstraint.Attachment1 = character.LeftUpperLeg['LeftHipRigAttachment']
	table.insert(constraints, LeftHipConstraint)

	local RightHipConstraint = Instance.new('BallSocketConstraint')
	RightHipConstraint.Name = 'RagdollRightHip'
	RightHipConstraint.Attachment0 = character.LowerTorso['RightHipRigAttachment']
	RightHipConstraint.Attachment1 = character.RightUpperLeg['RightHipRigAttachment']
	table.insert(constraints, RightHipConstraint)


	for _,constraint in pairs(constraints) do
		constraint.TwistLimitsEnabled = true
		constraint.LimitsEnabled = true
		constraint.UpperAngle = 40
		constraint.TwistLowerAngle = -20
		constraint.TwistUpperAngle = 40
		constraint.Restitution = 1

		constraint.Parent = folder
	end
	
	constraints = nil
	
	hrp.CFrame = upperTorso.CFrame
	hrp.Velocity = Vector3.new(0,0,0)

	upperTorso.Massless = true

	local weld = Instance.new("Weld")
	weld.Part0 = hrp
	weld.Part1 = upperTorso
	weld.C0 = upperTorso.CFrame
	weld.C1 = upperTorso.CFrame
	weld.Parent = hrp
	weld.Name = "ragdollRootWeld"

	hrp.CanCollide = false
	
	for _,v in next,character:GetChildren() do
		if (v:IsA('BasePart')) then
			for _,u in next,v:GetChildren() do
				if (u:IsA('Motor')) then mJointParent[u] = u.Parent u.Parent = nil end
			end
		elseif (v:IsA('Accessory')) then
			v.Handle.CanCollide = false
		end
	end
end

function ragdollService:pickupRagdoll(character, carrierUT, carrier)
	local player = game.Players:GetPlayerFromCharacter(character)
	local humanoid = character:FindFirstChild("Humanoid")
	local upperTorso = character:FindFirstChild("UpperTorso")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	
	local uniqueID = character:GetAttribute("ragdollID")
	
	local mJointParent = JointParent[uniqueID]
	if (not mJointParent) then return false end
	
	if player then
		player.DevComputerMovementMode = Enum.DevComputerMovementMode.Scriptable
	end
	
	if game.Players:GetPlayerFromCharacter(carrier) then
		carrier:SetAttribute("LockedTorso", true)
	end
	
	action(carrier, .8, "ragdollPickup")
	
	animService.playAnimation(carrier:FindFirstChild("Humanoid"), "ragdollPickup")
	
	task.wait(.5)
	
	if checkTag(carrier, "Stunned") or not character:GetAttribute("ragdolled") then 
		animService.stopAnimation(carrier:FindFirstChild("Humanoid"), "ragdollPickup") 
		return false 
	end
	
	local objectValue = Instance.new("ObjectValue")
	objectValue.Name = "carriedRagdoll"
	objectValue.Value = character
	objectValue.Parent = carrier
	
	character:SetAttribute("carried", true)
	
	if player then
		character:SetAttribute("LockedTorso", true)
	end
	
	hrp.Velocity = Vector3.new(0,0,0)
	hrp.CFrame = upperTorso.CFrame
	hrp.Velocity = Vector3.new(0,0,0)
	
	for Motor,Parent in next,mJointParent do 
		Motor.Parent = Parent 
	end
	
	for _,v in next,character["RagdollConstraints"]:GetChildren() do
		if (v:IsA('Constraint')) then 
			v.Enabled = false 
		end
	end
	
	JointParent[uniqueID] = nil
	
	for _, part in pairs(character:GetChildren()) do
		if part:IsA("BasePart") or part:IsA("MeshPart") then
			part.Massless = true
		end
	end
	
	carrier:FindFirstChild("HumanoidRootPart").Anchored = true
	hrp.Anchored = true
	
	hrp.CFrame = carrierUT.CFrame * CFrame.new(-1.6,1.5,0) * CFrame.Angles(math.rad(90),math.rad(180),math.rad(200))
	
	task.wait()
	
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = carrierUT
	weldConstraint.Part1 = hrp
	weldConstraint.Name = "pickupWeld"						
	weldConstraint.Parent = character
	
	carrier:FindFirstChild("HumanoidRootPart").Anchored = false
	hrp.Anchored = false
	
	animService.playAnimation(carrier:FindFirstChild("Humanoid"), "carrying")
	animService.playAnimation(humanoid, "carried")
	
	if player then
		player.DevComputerMovementMode = Enum.DevComputerMovementMode.UserChoice
	end
	
	if game.Players:GetPlayerFromCharacter(carrier) then
		carrier:SetAttribute("LockedTorso", false)
	end
	
	return true
end


function ragdollService:dropRagdoll(character)
	if not character:FindFirstChild("carriedRagdoll") then return end
	local ragdoll = character:FindFirstChild("carriedRagdoll").Value
	
	if not ragdoll then return false end
	
	local uniqueID = ragdoll:GetAttribute("ragdollID")
	local mJointParent = JointParent[uniqueID]
	if (not mJointParent) then mJointParent = {} JointParent[uniqueID] = mJointParent end
	
	local humanoid = ragdoll:FindFirstChild("Humanoid")
	local upperTorso = ragdoll:FindFirstChild("UpperTorso")
	local hrp = ragdoll:FindFirstChild("HumanoidRootPart")
	
	action(character, .8, "ragdollDrop")
	
	ragdoll:SetAttribute("carried", false)
	
	hrp.Velocity = Vector3.new(0,0,0)
	hrp.CFrame = upperTorso.CFrame
	
	hrp.Velocity = Vector3.new(0,0,0)
	
	animService.stopAnimation(humanoid, "carried")
	
	for _,v in next,ragdoll:GetChildren() do
		if (v:IsA('BasePart')) then
			for _,u in next,v:GetChildren() do
				if (u:IsA('Motor')) then mJointParent[u] = u.Parent u.Parent = nil end
			end
		elseif (v:IsA('Accessory')) then
			v.Handle.CanCollide = false
		end
	end

	for _,v in next,ragdoll["RagdollConstraints"]:GetChildren() do
		if (v:IsA('Constraint')) then 
			v.Enabled = true 
		end
	end	
	
	ragdoll:FindFirstChild("pickupWeld"):Destroy()
	
	for _, part in pairs(ragdoll:GetChildren()) do
		if part:IsA("BasePart") or part:IsA("MeshPart") then
			part.Massless = false
		end
		if part.Name == "UpperTorso" then
			part.Massless = true
		end
	end
		
	animService.stopAnimation(character:FindFirstChild("Humanoid"), "carrying")
	
	character:FindFirstChild("carriedRagdoll"):Destroy()
	

	task.delay(2, function()
		if humanoid.Health > 5 and not ragdoll:GetAttribute("carried") and ragdoll:GetAttribute("ragdolled") == true then
			ragdollService:unragdoll(ragdoll)
		end		
	end)
	
	return true
end

function ragdollService:unragdoll(character)
	local player = game.Players:GetPlayerFromCharacter(character)
	local humanoid = character:FindFirstChild("Humanoid")
	local upperTorso = character:FindFirstChild("UpperTorso")

	local uniqueID = character:GetAttribute("ragdollID")

	local mJointParent = JointParent[uniqueID]
	if (not mJointParent) then return end
	
	character:SetAttribute("ragdolled", false)
	
	upperTorso.Massless = false
	
	local hrp = character:FindFirstChild("HumanoidRootPart")
	hrp:FindFirstChild("ragdollRootWeld"):Destroy()
	hrp.CFrame = upperTorso.CFrame
	hrp.Velocity = Vector3.new(0,0,0)
	
	--
	
	for Motor,Parent in next,mJointParent do 
		Motor.Parent = Parent 
	end
	
	for _,v in next,character:GetChildren() do
		if (v:IsA('BasePart')) then
			if (v:IsA('Accessory')) then
				v.Handle.CanCollide = true
			end
		end
	end
	
	JointParent[uniqueID] = nil
	
	for _,v in next,character["RagdollConstraints"]:GetChildren() do
		if (v:IsA('Constraint')) then 
			v:Destroy() 
		end
	end
	--

	if not player then
		EnableHumanoid(humanoid, true)
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end

	if player then
		eventDispatcher.remoteFire(player, "ragdollClient", false)
	end
	
	if player then
		character:SetAttribute("LockedTorso", false)
	end
end

function ragdollService:characterRemoving(character)
	local uniqueID = character:GetAttribute("ragdollID")
	if uniqueID then
		JointParent[uniqueID] = nil
	end
	
	if ragdollConnections[uniqueID] then
		for _,connection in pairs(ragdollConnections[uniqueID]) do
			if connection then
				connection:Disconnect()
			end
		end
	end
	
	ragdollService:dropRagdoll(character)
end


function ragdollService:ragdollTick(ragdoll)
	local humanoid = ragdoll:FindFirstChild("Humanoid")
	local uniqueID = ragdoll:GetAttribute("ragdollID")
	
	if ragdollConnections[uniqueID] then
		for _,connection in pairs(ragdollConnections[uniqueID]) do
			if connection then
				connection:Disconnect()
			end
		end
	end
	
	if humanoid then
		local connection;
		connection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			task.delay(2, function()
				if humanoid.Health > 5 and not ragdoll:GetAttribute("carried") and ragdoll:GetAttribute("ragdolled") == true then
					ragdollService:unragdoll(ragdoll)
					connection:Disconnect()
				end	
			end)
		end)
		
		ragdollConnections[uniqueID] = ragdollConnections[uniqueID] or {}
		table.insert(ragdollConnections[uniqueID], connection)
	end
end

---WHEN GRIPPING AN NPC MAKE SURE TO CALL THE CHARACTER REMOVING!!!!!!!!!!!!!!
---ELSE MEMORY LEAK!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

return ragdollService