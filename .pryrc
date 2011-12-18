$LOAD_PATH.unshift "./lib"
require "scotty"

def scotty
  @scotty ||= Scotty::Core.new
end

def reload!
  Scotty::Init.reload!
  @scotty = Scotty::Core.new
  !!@scotty
end
