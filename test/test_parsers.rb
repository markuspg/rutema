# Copyright (c) 2007-2017 Vassilis Rizopoulos. All rights reserved.
# Copyright (c) 2021 Markus Prasser. All rights reserved.

require 'test/unit'
require 'ostruct'
require 'mocha/test_unit'
require_relative '../lib/rutema/parsers/xml'


#$DEBUG=true
module Rutema::Test
  ##
  # Module with a collection of samples for specification tests
  module Samples
    SAMPLE_SPEC=<<-EOT
    <specification name="sample">
    <title>Title</title>
    <description>Description</description>
    <scenario>
    <step/>
    <another_step script="script"/>
    </scenario>
    </specification>
    EOT
    INCLUDE_SPEC=<<-EOT
    <specification name="include">
    <title>Title</title>
    <description>Description</description>
    <scenario>
    <step/>
    <include_scenario file="#{File.expand_path(File.dirname(__FILE__))}/data/include.scenario"/>
    </scenario>
    </specification>
    EOT
    BAD_INCLUDE_SPEC=<<-EOT
    <specification name="bad_include">
    <title>Title</title>
    <description>Description</description>
    <scenario>
    <include_scenario file="unknown.scenario"/>
    </scenario>
    </specification>
    EOT
    MISSING_INCLUDE_SPEC=<<-EOT
    <specification name="bad_include">
    <title>Title</title>
    <description>Description</description>
    <scenario>
    <include_scenario/>
    </scenario>
    </specification>
    EOT
    MINIMAL_SPEC=<<-EOT
    <specification name="sample">
    <title>Title</title>
    <description>Description</description>
    <scenario>
    <echo/>
    <command cmd="l"/>
    </scenario>
    </specification>
    EOT
    INCLUDE_SCENARIO=<<-EOT
    <?xml version="1.0" encoding="UTF-8"?>
    <scenario>
      <echo>This is a step from an included scenario</echo>
      <echo>And another step from the included scenario</echo>
    </scenario>
    EOT
  end
end

module Rutema::Test
  ##
  # Verify the correct functionality of Rutema::Parsers::SpecificationParser
  class SpecificationParser < Test::Unit::TestCase
    ##
    # Verify that new Rutema::Parsers::SpecificationParser instances are
    # initialized correctly
    def test_initialization
      parser = nil
      assert_nothing_raised { parser = Rutema::Parsers::SpecificationParser.new({}) }
      assert_not_nil(parser)
      assert(parser.configuration.empty?, 'Configuration is not empty')
      assert_raise(Rutema::ParserError) { parser.parse_specification('foo') }
      assert_raise(Rutema::ParserError) { parser.parse_setup('foo') }
      assert_raise(Rutema::ParserError) { parser.parse_teardown('foo') }
      assert_nothing_raised { parser.validate_configuration }
    end
  end

  ##
  # Verify the correct functionality of Rutema::Parsers::XML
  class XMLParser < Test::Unit::TestCase
    def test_parse_specification
      config=stub()
      config.stubs(:parser).returns({})
      parser=Rutema::Parsers::XML.new(config)
      specification=parser.parse_specification(Samples::SAMPLE_SPEC)
      assert_equal("sample",specification.name)
      assert_equal("Description", specification.description)
      assert_equal("Title", specification.title)
      assert(specification.scenario)
      assert_equal(2, specification.scenario.steps.size)
      assert_equal(1, specification.scenario.steps[0].number)
      assert_equal("another_step", specification.scenario.steps[1].step_type)
      assert_equal("script", specification.scenario.steps[1].script)
      assert_equal(2, specification.scenario.steps[1].number)
      assert_raise(Rutema::ParserError) { parser.parse_specification("") }
      assert_raise(Rutema::ParserError) { parser.parse_specification("missing.spec") }
    end
    def test_include
      config=stub()
      config.stubs(:parser).returns({})
      parser=Rutema::Parsers::XML.new(config)
      specification=parser.parse_specification(Samples::INCLUDE_SPEC)
      assert_equal(3, specification.scenario.steps.size)
      assert(specification.scenario.steps[2].has_included_in?)
      assert_raise(Rutema::ParserError) {  parser.parse_specification(Samples::BAD_INCLUDE_SPEC) }
      assert_raise(Rutema::ParserError) {  parser.parse_specification(Samples::MISSING_INCLUDE_SPEC) }
    end
    def test_parse_error
      config=stub()
      config.stubs(:parser).returns({})
      parser=Rutema::Parsers::XML.new(config)
      assert_not_nil(parser.configuration)
      specification=nil
      assert_raise(Rutema::ParserError) { specification=parser.parse_specification("<") }
    end
  end
end
