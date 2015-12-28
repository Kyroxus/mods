bellsproutbehavior = {
  actionQueue = {}
}

function bellsproutbehavior.init()
  bellsproutbehavior.entityTypeReactions = {
    ["player"] = bellsproutbehavior.reactToPlayer,
    ["itemdrop"] = bellsproutbehavior.reactToItemDrop
  }

  bellsproutbehavior.actions = {
    ["inspect"] = bellsproutbehavior.inspect,
    ["follow"] = bellsproutbehavior.follow,
    ["eat"] = bellsproutbehavior.eat,
    ["emote"] = bellsproutbehavior.emote
  }
end

function bellsproutbehavior.queueAction(type, args)
  table.insert(bellsproutbehavior.actionQueue, {type = type, args = args})
end

function bellsproutbehavior.performAction(action)
  if bellsproutbehavior.actions[action.type] then
    return bellsproutbehavior.actions[action.type](unpack(action.args))
  end

  return false
end

function bellsproutbehavior.run()
  for _,action in pairs(bellsproutbehavior.actionQueue) do
    if bellsproutbehavior.performAction(action) then
      break
    end
  end

  bellsproutbehavior.actionQueue = {}
end

----------------------------------------
--ENTITY REACTIONS
----------------------------------------

function bellsproutbehavior.reactTo(entityId)
  local entityType = world.entityType(entityId)

  if bellsproutbehavior.entityTypeReactions[entityType] then
    bellsproutbehavior.entityTypeReactions[entityType](entityId)
  end
end

function bellsproutbehavior.reactToPlayer(entityId)
  local playerUuid = world.entityUuid(entityId)

  --Check hands for goodies
  local primaryItem = world.entityHandItem(entityId, "primary")
  local altItem = world.entityHandItem(entityId, "alt")
  local foodLiking = itemFoodLiking(primaryItem) or itemFoodLiking(altItem)
  if foodLiking and 100 - foodLiking/2 < status.resource("hunger") then
    bellsproutbehavior.queueAction("beg", {entityId, 3})
  end

  if storage.ownerUuid ~= 0 and storage.ownerUuid == playerUuid then
    bellsproutbehavior.reactToOwner(entityId)
  else
    bellsproutbehavior.reactToStranger(entityId)
  end
end

function bellsproutbehavior.reactToOwner(entityId)
  bellsproutbehavior.queueAction("follow", {entityId})
end

function bellsproutbehavior.reactToStranger(entityId)
  --No reaction
end

function bellsproutbehavior.reactToItemDrop(entityId)
  local entityName = world.entityName(entityId)

  local foodLiking = itemFoodLiking(entityName)
  if foodLiking then
    if 100 - foodLiking < status.resource("hunger") then
      bellsproutbehavior.queueAction("eat", {entityId,  2})
    end
  elseif foodLiking == nil then
    bellsproutbehavior.queueAction("inspect", {entityId, 2, {type = "eat", args = {entityId, 2}}})
  end
end

----------------------------------------
--ACTIONS
----------------------------------------

function bellsproutbehavior.follow(entityId)
  if self.actionState.stateDesc() == "" then
    return self.actionState.pickState({
      followTarget = entityId
    })
  end
end

function bellsproutbehavior.inspect(entityId, approachDistance, followUpAction)
  if self.actionState.stateDesc() == "" then
    return self.actionState.pickState({
      inspectTarget = entityId,
      approachDistance = approachDistance,
      followUpAction = followUpAction --Optional
    })
  end
end

function bellsproutbehavior.eat(entityId, approachDistance)
  if self.actionState.stateDesc() == "" then
    return self.actionState.pickState({
      eatTarget = entityId,
      approachDistance = approachDistance
    })
  end
end

function bellsproutbehavior.beg(entityId, approachDistance)
  if self.actionState.stateDesc() == "" then
    return self.actionState.pickState({
      begTarget = entityId,
      approachDistance = approachDistance
    })
  end
end

function bellsproutbehavior.emote(emoteName)
  emote(emoteName)
  return true
end