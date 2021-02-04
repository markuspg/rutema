# Copyright (c) 2021 Markus Prasser. All rights reserved.

# frozen_string_literal: true

require 'test/unit'

require_relative '../lib/rutema/core/framework'

module Rutema::Test
  ##
  # Verify the correct functionality of Rutema::ErrorMessage
  class ErrorMessage < ::Test::Unit::TestCase
    ##
    # Verify that Rutema::ErrorMessage instances are initialized correctly from
    # an empty Hash
    def test_initialize_from_empty_hash
      before = Time.now
      msg = Rutema::ErrorMessage.new({})
      after = Time.now
      assert_equal('', msg.test)
      assert_equal('', msg.text)
      assert(before < msg.timestamp)
      assert(after > msg.timestamp)

      assert_equal('ERROR - ', msg.to_s)
    end

    ##
    # Verify that Rutema::ErrorMessage instances are initialized correctly
    def test_initialize
      msg = Rutema::ErrorMessage.new({
                                       test: 'A simple test string',
                                       text: 'Some random text',
                                       timestamp: Time.new(2021, 4, 2, 23, 20, 17)
                                     })
      assert_equal('A simple test string', msg.test)
      assert_equal('Some random text', msg.text)
      assert_equal(2, msg.timestamp.day)
      assert_equal(23, msg.timestamp.hour)
      assert_equal(20, msg.timestamp.min)
      assert_equal(4, msg.timestamp.month)
      assert_equal(17, msg.timestamp.sec)
      assert_equal(2021, msg.timestamp.year)

      assert_equal('ERROR - A simple test string Some random text', msg.to_s)
      msg.test = ''
      assert_equal('ERROR - Some random text', msg.to_s)
    end
  end

  ##
  # Verify the correct functionality of Rutema::Message
  class Message < ::Test::Unit::TestCase
    ##
    # Verify that Rutema::Message instances are initialized correctly from an
    # empty Hash
    def test_initialize_from_empty_hash
      before = Time.now
      msg = Rutema::Message.new({})
      after = Time.now
      assert_equal('', msg.test)
      assert_equal('', msg.text)
      assert(before < msg.timestamp)
      assert(after > msg.timestamp)

      assert_equal('', msg.to_s)
    end

    ##
    # Verify that Rutema::Message instances are initialized correctly
    def test_initialize
      msg = Rutema::Message.new({
                                  test: 'A simple test string',
                                  text: 'Some random text',
                                  timestamp: Time.new(2021, 4, 2, 23, 20, 17)
                                })
      assert_equal('A simple test string', msg.test)
      assert_equal('Some random text', msg.text)
      assert_equal(2, msg.timestamp.day)
      assert_equal(23, msg.timestamp.hour)
      assert_equal(20, msg.timestamp.min)
      assert_equal(4, msg.timestamp.month)
      assert_equal(17, msg.timestamp.sec)
      assert_equal(2021, msg.timestamp.year)

      assert_equal('A simple test string Some random text', msg.to_s)
      msg.test = ''
      assert_equal('Some random text', msg.to_s)
    end
  end
end
