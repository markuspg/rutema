# Copyright (c) 2007-2020 Vassilis Rizopoulos. All rights reserved.

module Rutema
  ##
  # A list of possible states a Rutema::RunnerMessage can transport
  #
  # It is ordered by ascending priority.
  STATUS_CODES = %i[uninitialized started skipped success warning error].freeze

  ##
  # Message is the base class of different message types for exchanging data
  #
  # The two classes ErrorMessage and RunnerMessage are the primarily used
  # message classes throughout Rutema.
  #
  # Messages are mostly created by Engine and Runners class instances through
  # the Messaging module. Errors within Rutema will be represented by
  # ErrorMessage instances. Test errors are represented by RunnerMessage
  # instances which have their +status+ attribute set to +:error+.
  class Message
    ##
    # Test id or name of the respective test
    attr_accessor :test
    ##
    # Message text
    attr_accessor :text
    ##
    # A timestamp respective to the message (in all known cases the time of
    # message creation)
    attr_accessor :timestamp

    ##
    # Initialize a new message from a Hash
    #
    # The following keys of the hash are used:
    # * +test+ - the test id/name (defaults to an empty string)
    # * +text+ - the text of the message (defaults to an empty string)
    # * +timestamp+ - a timestamp (defaults to +Time.now+)
    def initialize(params)
      @test = params.fetch(:test, '')
      @text = params.fetch(:text, '')
      @timestamp = params.fetch(:timestamp, Time.now)
    end

    ##
    # Convert the message to a string representation
    def to_s
      msg = ''
      msg << "#{@test}: " unless @test.empty?
      msg << @text
    end
  end

  ##
  # ErrorMessage is a class for simple error messages
  #
  # Compared to Message it does not contain any additional information. The
  # only difference is that "Error - " is being prepended to its stringified
  # representation.
  #
  # This class is mainly used to signal errors concerning the execution of
  # Rutema. Test errors are signalled by RunnerMessage instances with the
  # +status+ attribute set to +:error+.
  class ErrorMessage < Message
    ##
    # Convert the message to a string representation
    def to_s
      'ERROR - ' + super
    end
  end

  ##
  # Rutema::RunnerMessage instances are repeatedly created during test execution
  #
  # These messages are particular to a respective test and carry additional
  # information compared to the base Rutema::Message
  class RunnerMessage < Message
    ##
    # The backtrace of a conducted but failed step
    attr_accessor :backtrace
    ##
    # The duration of a test step
    attr_accessor :duration
    ##
    # An error occurred during a step or a test
    attr_accessor :err
    ##
    # The represented step is a special one (i.e. a setup or teardown step)
    attr_accessor :is_special
    ##
    # The number of a test step
    attr_accessor :number
    ##
    # The output of a test step
    attr_accessor :out
    ##
    # The status of a respective test step or test itself
    attr_accessor :status

    ##
    # Initialize a new RunnerMessage from a Hash
    #
    # The following (additional to Message) keys of the hash are used:
    # * 'backtrace' - A backtrace of a conducted but failed step (defaults to an
    #   empty string)
    # * 'duration' - An optional duration of a step (defaults to +0+)
    # * 'err' - An optional error message (defaults to an empty string)
    # * 'is_special' - If the respective step is a special one (i.e. setup or
    #   teardown - defaults to +false+)
    # * 'number' - The number of a step (defaults to +1+)
    # * 'out' - An optional output of a step (defaults to an empty string)
    # * 'status' - A status of a step or the respective test (defaults to +:uninitialized+)
    def initialize(params)
      super(params)

      @backtrace = params.fetch('backtrace', '')
      @duration = params.fetch('duration', 0)
      @err = params.fetch('err', '')
      @is_special = params.fetch('is_special', false)
      @number = params.fetch('number', 1)
      @out = params.fetch('out', '')
      @status = params.fetch('status', :uninitialized)
    end

    ##
    # Return a string combining the stored step output, error string and
    # backtrace
    def output
      msg = ''
      msg << "Output: \"#{@out}\"\n" unless @out.empty?
      msg << "Error: \"#{@err}\"\n" unless @err.empty?
      msg << "Backtrace:\n=> " + (@backtrace.is_a?(Array) ? @backtrace.join("\n=> ") : @backtrace) unless @backtrace.empty?
      msg.chomp
    end

    ##
    # Convert the message to a string representation
    #
    # The output of the #output method will be appended, if this returns a
    # non-empty string
    def to_s
      msg = "#{@test}:"
      msg << " #{@timestamp.strftime('%H:%M:%S')} :"
      msg << "#{@text}." unless @text.empty?
      outpt = output
      msg << "\n#{outpt}" unless outpt.empty?
      msg
    end
  end

  ##
  # ReportState is used by the Reporters::Collector event reporter to accumulate
  # all RunnerMessage instances emitted by a specific test. This accumulated
  # data can then in the end be passed to block reporters.
  #
  # ReportState permanently assumes the name of the respective test in its
  # +test+ attribute and the timestamp of the first received message in its
  # +timestamp+ attribute.
  #
  # Durations will be accumulated in the +duration+ attribute and all inserted
  # messages in the +steps+ attribute. The +status+ attribute will always be set
  # to the status of the highest priority of all the inserted messages. The
  # order of the status priorities can be seen in ascending order in
  # STATUS_CODES in the Rutema module
  class ReportState
    ##
    # Holds all inserted RunnerMessage instances
    attr_accessor :steps

    ##
    # Accumulates the durations of all inserted messages
    attr_reader :duration
    ##
    # If the Message passed on initialization was a special one
    attr_reader :is_special
    ##
    # Always has the status of the highest priority of all inserted messages
    attr_reader :status
    ##
    # The name of the respective test whose messages this ReportState collects
    attr_reader :test
    ##
    # The timestamp of the first message of the test
    attr_reader :timestamp

    ##
    # Create a new ReportState instance from a RunnerMessage
    def initialize(message)
      @duration = message.duration
      @is_special = message.is_special
      @status = message.status
      @steps = [message]
      @test = message.test
      @timestamp = message.timestamp
    end

    ##
    # Accumulate a further RunnerMessage instance
    #
    # Raises a RunnerError if a message of a different test is being inserted
    # than what the ReportState instance was created with
    def <<(message)
      if message.test != @test
        raise Rutema::RunnerError,
              "Attempted to insert \"#{message.test}\" message into \"#{@test}\" ReportTestStates"
      end

      append_message_and_update(message)
    end

    private

    ##
    # Add message to the steps Array and update duration and status attributes
    def append_message_and_update(message)
      @duration += message.duration
      unless message.status.nil? \
        || (!@status.nil? && STATUS_CODES.find_index(message.status) \
            < STATUS_CODES.find_index(@status))
        @status = message.status
      end
      @steps << message
    end
  end

  module Messaging
    #Signal an error - use the test name/id as the identifier
    def error identifier,message
      @queue.push(ErrorMessage.new(:test=>identifier,:text=>message,:timestamp=>Time.now))
    end

    #Informational message during test runs
    def message message
      case message
      when String
        @queue.push(Message.new(:text=>message,:timestamp=>Time.now))
      when Hash
        hm=Message.new(message)
        hm=RunnerMessage.new(message) if message[:test] && message["status"]
        hm.timestamp=Time.now
        @queue.push(hm)
      end
    end
  end

  #Generic error class for errors in the engine
  class RutemaError<RuntimeError
  end

  #Is raised when an error is found in a specification
  class ParserError<RutemaError
  end

  #Is raised on an unexpected error during execution
  class RunnerError<RutemaError
  end

  #Errors in reporters should use this class
  class ReportError<RutemaError
  end
end
