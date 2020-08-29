# Copyright (c) 2007-2020 Vassilis Rizopoulos. All rights reserved.

# frozen_string_literal: true

module Rutema
  ##
  # This module defines the version numbers of the library
  module Version
    ##
    # The major version number
    MAJOR = 2
    ##
    # The minor version number
    MINOR = 0
    ##
    # The tiny version number
    TINY = 0
    ##
    # The version number as a String
    STRING = [MAJOR, MINOR, TINY].join('.')
  end
end
