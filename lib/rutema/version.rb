# Copyright (c) 2007-2017 Vassilis Rizopoulos. All rights reserved.
# Copyright (c) 2021 Markus Prasser. All rights reserved.

# frozen_string_literal: true

module Rutema
  ##
  # Module defining the version numbers of rutema
  module Version
    ##
    # The major version of rutema
    MAJOR = 2
    ##
    # The minor version of rutema
    MINOR = 0
    ##
    # The tiny version of rutema
    TINY = 0
    ##
    # The version information of rutema assembled as a String
    STRING = [MAJOR, MINOR, TINY].join('.')
  end
end
