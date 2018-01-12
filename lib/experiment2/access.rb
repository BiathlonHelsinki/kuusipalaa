module Experiment2
  module Access
    AccessDeniedError = Class.new(StandardError)

    NO_ACCESS = 0
    REGULAR_MEMBER = 10
    ADMIN =  30
    OWNER     = 50


  end
end
