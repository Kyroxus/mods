{
function onInteraction(args)
    if world.info("name") == nil then
    return { "ShowPopup", { message = "You are on a Space ship! :)" } };
end
}
