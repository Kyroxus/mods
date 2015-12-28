require "/scripts/behavior.lua"
require "/scripts/pathing.lua"
require "/scripts/util.lua"
require "/scripts/vec2.lua"

-- Engine callback - called on initialization of entity
function init()
  self.pathing = {}

  self.shouldDie = true
  self.notifications = {}
  if storage.spawnPosition == nil then
    local position = mcontroller.position()
    local groundSpawnPosition
    if mcontroller.baseParameters().gravityEnabled then
      groundSpawnPosition = findGroundPosition(position, -20, 3)
    end
    storage.spawnPosition = groundSpawnPosition or position
  end
  BData:setPosition("spawn", storage.spawnPosition)

  self.behavior = BTree:new(entity.configParameter("behavior"))

  self.collisionPoly = mcontroller.collisionPoly()

  if entity.hasSound("deathPuff") then    
    entity.setDeathSound("deathPuff")
  end
  if entity.configParameter("deathParticles") then
    entity.setDeathParticleBurst(entity.configParameter("deathParticles"))
  end
  
  mcontroller.setAutoClearControls(false)
  self.behaviorTickRate = 1
  self.behaviorTick = math.random(1, self.behaviorTickRate)

  entity.setGlobalTag("flipX", "")

  self.debug = true
end

-- Engine callback - called on each update
-- Update frequencey is dependent on update delta
function update(dt)
  if self.behaviorTick >= self.behaviorTickRate then
    self.behaviorTick = self.behaviorTick - self.behaviorTickRate
    mcontroller.clearControls()

    self.tradingEnabled = false
    self.setFacingDirection = false

    BData:setEntity("self", entity.id())
    BData:setPosition("self", mcontroller.position())
    BData:setNumber("facingDirection", mcontroller.facingDirection())

    if self.behavior and self.behavior:run(dt * self.behaviorTickRate) ~= "running" then
      self.behavior:reset()
    end

    self.interacted = false
    self.damaged = false
    self.notifications = {}
  end
  self.behaviorTick = self.behaviorTick + 1

  runWorkers()
end

function uninit()
  self.behavior:uninit()
end

-- Engine callback - called on taking damage
function damage(args)
  self.damaged = true
  BData:setEntity("damageSource", args.sourceId)
end

function setupTenant(...)
  require("/scripts/tenant.lua")
  tenant.setHome(...)
end

function suicide(args, output)
  status.setResource("health", 0)
end

function wasDamaged(args, output)
  return self.damaged == true
end

function shouldDie()
  return self.shouldDie and status.resource("health") <= 0
end

function attackNotification(args, output)
  return false
end

-- param type
-- param state
function setAnimationState(args, output)
  args = parseArgs(args, {
    type = nil,
    state = nil
  })
  if args.type == nil or args.state == nil or args.type == "" or args.state == "" then
    return false
  end

  entity.setAnimationState(args.type, args.state)
  return true
end

-- param type
-- param tag
function setGlobalTag(args, output)
  args = parseArgs(args, {
    type = nil,
    tag = nil  
  })
  if args.type == nil or args.type == ""then
    return false
  end

  entity.setGlobalTag(args.type, args.tag or "")
  return true
end

-- param entity
function isValidTarget(args, output)
  args = parseArgs(args, {
    entity = nil
  })
  local entityId = BData:getEntity(args.entity)
  if entityId == nil then return false end

  return entity.isValidTarget(entityId)
end

function rotatePoly(angle)
  local basePoly = mcontroller.baseParameters().standingPoly
  local newPoly = {}
  for i,point in pairs(basePoly) do
    table.insert(newPoly, vec2.rotate(point, angle))
  end
  self.collisionPoly = newPoly
end

-- param angle
-- param vector
-- param immediate
function rotate(args, output)
  args = parseArgs(args, {
    angle = 0,
    vector = nil,
    immediate = true
  })

  local angle
  while true do
    if args.vector then
      local vector = vec2.norm(BData:getVec2(args.vector))
      if vector == nil then return false end
      angle = math.atan(vector[2], vector[1])
    else
      angle = BData:getNumber(args.angle)
    end
    angle = angle + entity.configParameter("rotationOffset", 0)

    entity.rotateGroup("all", angle, args.immediate)
    rotatePoly(entity.currentRotationAngle("all") or 0)

    diff = ((entity.currentRotationAngle("all") - angle) + 3.14) % 6.28 - 3.14
    if math.abs(diff) < 0.02 or args.immediate then break end
    coroutine.yield("running")
  end

  rotatePoly(angle)
  return true
end

-- param transformationGroup
function resetTransformationGroup(args, output)
  args = parseArgs(args, {
    transformationGroup = nil  
  })
  if args.transformationGroup == nil then return false end
  entity.resetTransformationGroup(args.transformationGroup)
  return true
end

-- param transformationGroup
-- param angle
function rotateTransformationGroup(args, output)
  args = parseArgs(args, {
    transformationGroup = nil,
    angle = 0  
  })
  local angle = BData:getNumber(args.angle)
  if angle == nil or args.transformationGroup == nil or args.transformationGroup == "" then
    return false
  end

  entity.rotateTransformationGroup(args.transformationGroup, angle)
  return true
end

-- param touchDamage
function setDamageOnTouch(args, output)
  args = parseArgs(args, {
    touchDamage = false  
  })

  entity.setDamageOnTouch(args.touchDamage)
  return true
end

-- param emitter
function burstParticleEmitter(args, output)
  args = parseArgs(args, {
    emitter = nil
  })

  if args.emitter == nil then return false end

  entity.burstParticleEmitter(args.emitter)
  return true
end

-- param emitter
-- param active
function setParticleEmitterActive(args, output)
  args = parseArgs(args, {
    active = true  
  })
  if args.emitter == nil then return false end

  entity.setParticleEmitterActive(args.emitter, args.active)
  return true
end

-- param sound
function playSound(args, output)
  args = parseArgs(args, {
    sound = nil
  })

  if args.sound == nil or args.sound == "" then return false end

  entity.playSound(args.sound)
  return true
end

function setLightActive(args, output)
  args = parseArgs(args, {
    light = nil,
    active = true  
  })
  if light == nil or active == nil then return false end

  entity.setLightActive(args.light, args.active)
  return true
end

function setDying(args, output)
  args = parseArgs(args, {
    shouldDie = true
  })
  self.shouldDie = args.shouldDie
  return true
end