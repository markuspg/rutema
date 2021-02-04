# Copyright (c) 2007-2017 Vassilis Rizopoulos. All rights reserved.
# Copyright (c) 2021 Markus Prasser. All rights reserved.

module Rutema
  STATUS_CODES = [:started, :skipped, :success, :warning, :error]

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
    # The test id or name of the respective test
    attr_accessor :test
    ##
    # The text of the message
    attr_accessor :text
    ##
    # A timestamp respective to the message (in all known cases the time of
    # message creation)
    attr_accessor :timestamp

    ##
    # Initialize a new message from a Hash
    #
    # The following keys of the Hash are used:
    # * +test+ - the test id/name (defaults to an empty String)
    # * +text+ - the text of the message (defaults to an empty String)
    # * +timestamp+ - a timestamp (defaults to +Time.now+)
    def initialize(params)
      @test = params.fetch(:test, '')
      @test ||= ''
      @text = params.fetch(:text, '')
      @timestamp = params.fetch(:timestamp, Time.now)
    end

    ##
    # Convert the Message instance to a String representation
    def to_s
      msg = ''
      msg << "#{@test} " unless @test.empty?
      msg << @text
      msg
    end
  end

  #What it says on the tin.
  class ErrorMessage<Message
    def to_s
      msg="ERROR - "
      msg<<"#{@test} " unless @test.empty?
      msg<<@text
      return msg
    end
  end
  #The Runner continuously sends these when executing tests
  #
  #If there is an engine error (e.g. when parsing) you will get an ErrorMessage, if it is a test error
  #you will get a RunnerMessage with :error in the status.
  class RunnerMessage<Message
    attr_accessor :duration,:status,:number,:out,:err,:is_special
    def initialize params
      super(params)
      @duration=params.fetch("duration",0)
      @status=params.fetch("status",:none)
      @number=params.fetch("number",1)
      @out=params.fetch("out","")
      @err=params.fetch("err","")
      @backtrace=params.fetch("backtrace","")
      @is_special=params.fetch("is_special","")
    end

    def to_s
      msg="#{@test}:"
      msg<<" #{@timestamp.strftime("%H:%M:%S")} :"
      msg<<"#{@text}." unless @text.empty?
      outpt=output()
      msg<<" Output" + (outpt.empty? ? "." : ":\n#{outpt}") # unless outpt.empty? || @status!=:error
      return msg
    end

    def output
      msg=""
      msg<<"#{@out}\n" unless @out.empty?
      msg<<@err unless @err.empty?
      msg<<"\n" + (@backtrace.kind_of?(Array) ? @backtrace.join("\n") : @backtrace) unless @backtrace.empty? 
      return msg.chomp
    end
  end
  #While executing tests the state of each test is collected in an 
  #instance of ReportState and the collection is at the end passed to the available block reporters
  #
  #ReportState assumes the timestamp of the first message, the status of the last message
  #and accumulates the duration reported by all messages in it's collection.
  class ReportState
    attr_accessor :steps
    attr_reader :test,:timestamp,:duration,:status,:is_special
    
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
