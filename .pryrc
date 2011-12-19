$LOAD_PATH.unshift "./lib"
require "scotty"

def scotty
  @scotty ||= Scotty::Core.instance
end

def reload!
  Scotty::Init.reload!
  @scotty = Scotty::Core.instance
  !!@scotty
end
