# Copyright (c) 2007-2020 Vassilis Rizopoulos. All rights reserved.

# frozen_string_literal: false

module Rutema
  ##
  # Generic base class for all Rutema errors
  #
  # Currently Rutema derives the more specific ConfigurationException,
  # ParserError, ReportError and RunnerError from it.
  class RutemaError < RuntimeError
  end

  ##
  # ConfigurationException is being raised on errors processing a _rutema_
  # configuration
  class ConfigurationException < RutemaError
  end

  ##
  # ParserError is raised when parsing a specification fails
  #
  # The exception may be thrown for errors within the parser subsystem itself
  # as well as for errors encountered within the parsed specifications.
  class ParserError < RutemaError
  end

  ##
  # RunnerError is raised on unexpected errors in the runner
  class RunnerError < RutemaError
  end

  ##
  # ReportError is raised on errors with the reporting subsystem
  class ReportError < RutemaError
  end
end
