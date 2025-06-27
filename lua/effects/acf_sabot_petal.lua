local ACF       = ACF
local Clock     = ACF.Utilities.Clock

function EFFECT:Init(Data)
	local Index           = Data:GetAttachment()
	local BulletType      = Data:GetFlags()
	local Origin          = Data:GetOrigin()
	local Flight          = Data:GetStart()
	local Caliber         = Data:GetScale()
	local SabotPetalTable = {}

	local Forward         = Flight:Angle()

	local Seperation    = 0.05
	local ShellLifetime = 5
	self.LifeTime = Clock.CurTime + ShellLifetime

	--ammotype is APFSDS
	if (BulletType == 1) then
		self:SetModel("models/acf/munitions/apfsdssabot.mdl")
		self:SetAngles(Forward + Angle(0,0,120*Index))
		SabotPetalTable = {
			[1] = {Velocity = Vector(1, -Seperation, Seperation), Torque = Vector(math.random(0,0.2), -1, math.random(0,0.2))}, --top left
			[2] = {Velocity = Vector(1, 0, -Seperation),          Torque = Vector(math.random(0,0.2), 1, math.random(0,0.2))}, --bottom center
			[3] = {Velocity = Vector(1, Seperation, Seperation),  Torque = Vector(math.random(0,0.2), -1, math.random(0,0.2))}  --top right
		}
	--ammotype is APDS
	else
		self:SetModel("models/acf/munitions/apdssabot.mdl")
		self:SetAngles(Forward)
		self:SetBodygroup(1, Index-1)
		SabotPetalTable = {
			[1] = {Velocity = Vector(0.4, 0, 0),           Torque = Vector(math.random(0,0.2), 1, math.random(0,0.2))}, --cap
			[2] = {Velocity = Vector(1, Seperation, 0),  Torque = Vector(math.random(0,0.2), -1, math.random(0,0.2))}, --left
			[3] = {Velocity = Vector(1, -Seperation, 0), Torque = Vector(math.random(0,0.2), 1, math.random(0,0.2))}  --right
		}
	end

	self:SetModelScale(Caliber * 0.1)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	local PhysObj = self:GetPhysicsObject()

	if IsValid(PhysObj) then
		local Mass     = 10
		local Velocity = 39370.1
		local Torque   = 25

		local SabotPetalData = SabotPetalTable[Index]
		local VelocityVector = SabotPetalData.Velocity
		local TorqueVector = SabotPetalData.Torque

		PhysObj:Wake()
		PhysObj:SetMass(Mass)
		self:SetCollisionGroup(20) --only collide with world 

		VelocityVector:Rotate(Forward)
		TorqueVector:Rotate(Forward)

		PhysObj:SetVelocityInstantaneous(VelocityVector*Velocity)
		PhysObj:ApplyTorqueCenter(TorqueVector*Torque)
	end
end

function EFFECT:Think()
	return self.LifeTime > Clock.CurTime
end

function EFFECT:Render()
	self:DrawModel()
end