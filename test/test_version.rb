# Copyright (c) 2021 Markus Prasser. All rights reserved.

# frozen_string_literal: true

require 'test/unit'

require_relative '../lib/rutema/version'

module Rutema
  ##
  # Module for the verification the functionality of rutema
  module Test
    ##
    # Verify the correct functionality of Rutema::Version
    class Version < ::Test::Unit::TestCase
      ##
      # Verify that the major version is correctly set
      def test_version_major
        assert_equal(2, Rutema::Version::MAJOR)
      end

      ##
      # Verify that the minor version is correctly set
      def test_version_minor
        assert_equal(0, Rutema::Version::MINOR)
      end

      ##
      # Verify that the tiny version is correctly set
      def test_version_tiny
        assert_equal(0, Rutema::Version::TINY)
      end

      ##
      # Verify that the version string is being assembled correctly
      def test_version_string
        assert_equal('2.0.0', Rutema::Version::STRING)
      end
    end
  end
end
