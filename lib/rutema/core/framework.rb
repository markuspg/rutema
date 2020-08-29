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

  #While executing tests the state of each test is collected in an 
  #instance of ReportState and the collection is at the end passed to the available block reporters
  #
  #ReportState assumes the timestamp of the first message, the status of the last message
  #and accumulates the duration reported by all messages in it's collection.
  class ReportState
    attr_accessor :steps

    attr_reader :duration
    attr_reader :is_special
    attr_reader :status
    attr_reader :test
    attr_reader :timestamp

    def initialize message
      @test=message.test
      @timestamp=message.timestamp
      @duration=message.duration
      @status=message.status
      @steps=[message]
      @is_special=message.is_special
    end

    def <<(message)
      @steps<<message
      @duration+=message.duration
      @status=message.status unless message.status.nil? || (!@status.nil? && STATUS_CODES.find_index(message.status) < STATUS_CODES.find_index(@status))
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
