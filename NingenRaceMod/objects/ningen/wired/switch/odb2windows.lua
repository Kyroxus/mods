function init(args)
  entity.setInteractive(true)
  entity.setAllOutboundNodes(entity.animationState("switchState") == "1")
end

function onInteraction(args)
  if entity.animationState("switchState") == "1" then
    entity.setAnimationState("switchState", "2")
    entity.playSound("onSounds");
    entity.setAllOutboundNodes(true)
  elseif
    entity.animationState("switchState") == "2" then
    entity.setAnimationState("switchState", "3")
    entity.playSound("onSounds");
    entity.setAllOutboundNodes(true)
  elseif
    entity.animationState("switchState") == "3" then
    entity.setAnimationState("switchState", "4")
    entity.playSound("onSounds");
    entity.setAllOutboundNodes(true)
  elseif
    entity.animationState("switchState") == "4" then
    entity.setAnimationState("switchState", "5")
    entity.playSound("onSounds");
    entity.setAllOutboundNodes(true)
  elseif
    entity.animationState("switchState") == "5" then
    entity.setAnimationState("switchState", "6")
    entity.playSound("onSounds");
    entity.setAllOutboundNodes(true)
  elseif
    entity.animationState("switchState") == "6" then
    entity.setAnimationState("switchState", "7")
    entity.playSound("onSounds");
    entity.setAllOutboundNodes(true)  
  elseif
    entity.animationState("switchState") == "7" then
    entity.setAnimationState("switchState", "8")
    entity.playSound("offSounds");
    entity.setAllOutboundNodes(true)
  elseif
    entity.animationState("switchState") == "8" then
    entity.setAnimationState("switchState", "1")
    entity.playSound("offSounds");
    entity.setAllOutboundNodes(true)
  end
end
