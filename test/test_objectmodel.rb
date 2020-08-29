# Copyright (c) 2007-2020 Vassilis Rizopoulos. All rights reserved.

require 'test/unit'

require_relative '../lib/rutema/core/objectmodel'

module TestRutema
  class DummyCommand
    include Patir::Command

    def initialize
      @name="dummy"
      @output="output"
      @error="error"
    end
  end

  class Dummy
  # Facilitate testing with a Rutema::SpecificationElement based class
    include Rutema::SpecificationElement
  end

  ##
  # Test Rutema::SpecificationElement
  class TestSpecificationElement < Test::Unit::TestCase
    ##
    # Test Rutema::SpecificationElement#attribute
    def test_attribute
      obj = Dummy.new

      # Attribute with a String value and Symbol setting
      assert_raise(NoMethodError) { obj.name }
      assert_raise(NoMethodError) { obj.name? }
      # The assignment operator cannot be tested since it creates the methods
      assert_false(obj.has_name?)
      obj.attribute(:name, 'name')
      assert(obj.has_name?)
      assert(obj.name?)
      assert_equal(obj.name, 'name')
      obj.name = 'Another name'
      assert_equal('Another name', obj.name)

      # Attribute with a boolean value and String setting
      assert_raise(NoMethodError) { obj.bool }
      assert_raise(NoMethodError) { obj.bool? }
      # The assignment operator cannot be tested since it creates the methods
      assert_false(obj.has_bool?)
      obj.attribute('bool', false)
      assert(obj.has_bool?)
      assert(obj.bool?)
      assert_equal(false, obj.bool)
      obj.bool = true
      assert_equal(true, obj.bool)

      # Attribute with a textual representation of a boolean value
      assert_raise(NoMethodError) { obj.text_bool }
      assert_raise(NoMethodError) { obj.text_bool? }
      # The assignment operator cannot be tested since it creates the methods
      assert_false(obj.has_text_bool?)
      obj.attribute(:text_bool, 'true')
      assert(obj.has_text_bool?)
      assert(obj.text_bool?)
      assert_equal('true', obj.text_bool)
      obj.text_bool = 'false'
      assert_equal('false', obj.text_bool)
    end

    ##
    # Test Rutema::SpecificationElement#method_missing
    def test_method_missing
      obj = Dummy.new
      assert_raise(NoMethodError) { obj.name }
      assert_raise(NoMethodError) { obj.name? }
      # The assignment operator cannot be tested since it creates the methods
      assert_false(obj.has_name?)
      obj.name = 'Some name'
      assert_equal(obj.name, 'Some name')
      assert(obj.name?)
      assert(obj.has_name?)
    end

    ##
    # Test Rutema::SpecificationElement#respond_to?
    def test_respond_to
      obj = Dummy.new
      [false, true].each do |include_all|
        assert_false(obj.respond_to?(:has_a_name, include_all))
        assert_false(obj.respond_to?(:a_name, include_all))
        assert_false(obj.respond_to?(:a_name=, include_all))
        assert_false(obj.respond_to?(:a_name?, include_all))
      end

      obj.attribute(:a_name, 'Some name')

      [false, true].each do |include_all|
        assert(obj.respond_to?(:has_a_name, include_all))
        assert(obj.respond_to?(:a_name, include_all))
        assert(obj.respond_to?(:a_name=, include_all))
        assert(obj.respond_to?(:a_name?, include_all))
      end
    end
  end

  class TestStep<Test::Unit::TestCase
    def test_new
      step=Rutema::Step.new("Step",DummyCommand.new())
      assert_not_equal("dummy", step.name)
      assert(/step - .*DummyCommand.*/=~step.name)
      assert_equal("output", step.output)
      assert_equal("error", step.error)
      assert_equal(:not_executed, step.status)
      assert_nothing_raised() { step.run }
      assert_equal(:success, step.status)
      assert_nothing_raised() { step.reset }
      assert_equal(:not_executed, step.status)
      assert_equal("", step.output)
      assert(/0 - .*DummyCommand.*/=~step.to_s)
    end
  end

  class TestScenario<Test::Unit::TestCase
    def test_add_step
      scenario=Rutema::Scenario.new([])
      assert(scenario.steps.empty?)
      step=Rutema::Step.new("Step",DummyCommand.new())
      scenario=Rutema::Scenario.new([step])
      assert_equal(1,scenario.steps.size)
      scenario.add_step(step)
      assert_equal(2,scenario.steps.size)
    end
  end

  class TestSpecification<Test::Unit::TestCase
    def test_new
      spec=Rutema::Specification.new(:name=>"name",:title=>"title",:description=>"description")
      assert(!spec.has_version?, "Version present")
      assert_equal("name", spec.name)
      assert_equal("title", spec.title)
      assert_equal("description", spec.description)
      assert(!spec.has_scenario?,"Scenario present")
      spec.scenario="Foo"
      assert_not_nil(spec.scenario)
      assert_equal("name - title", spec.to_s)
      #we can arbitrarily add attributes to a spec
      spec.requirements=["R1","R2"]
      assert(spec.has_requirements?)
      assert_equal(2, spec.requirements.size)
    end
  end
end
