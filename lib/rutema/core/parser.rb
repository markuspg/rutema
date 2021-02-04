# Copyright (c) 2007-2017 Vassilis Rizopoulos. All rights reserved.
# Copyright (c) 2021 Markus Prasser. All rights reserved.

# frozen_string_literal: true

require_relative 'framework'

module Rutema
  module Parsers
    ##
    # Base class for rutema specification parsers that raises exceptions if used
    # directly
    #
    # Parser classes should be derived from this class and implement
    # parse_specification and validate_configuration
    class SpecificationParser
      attr_reader :configuration

      def initialize(configuration)
        @configuration = configuration
        @configuration ||= {}
        validate_configuration
      end

      ##
      # Parse a specification
      def parse_specification(_param)
        raise ParserError, \
              'Not implemented, an actual parser implementation should be' \
              ' derived from SpecificationParser'
      end

      ##
      # Parse a setup specification
      #
      # By default parse_specification is called by this.
      def parse_setup(param)
        parse_specification(param)
      end

      ##
      # Parse a teardown specification
      #
      # By default parse_specification is called by this.
      def parse_teardown(param)
        parse_specification(param)
      end

      ##
      # A parser stores its configuration in @configuration
      #
      # To avoid validating the configuration in +element_*+ methods repeatedly,
      # all configuration validation should be done here.
      #
      # The default implementation of this method does nothing.
      def validate_configuration; end
    end
  end
end
