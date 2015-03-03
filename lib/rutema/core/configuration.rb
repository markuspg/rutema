  #  Copyright (c) 2007-2015 Vassilis Rizopoulos. All rights reserved.
  require 'ostruct'
  require_relative 'parser'
  require_relative 'reporter'
  module Rutema
    #This module defines the "configuration directives" used in the configuration of Rutema
    #
    #Example
    #A configuration file needs as a minimum to define which parser to use and which tests to run.
    #
    #Since rutema configuration files are valid Ruby code, you can use the full power of the Ruby language including require directives
    #
    # require 'rake'
    # configuration.parser={:class=>Rutema::MinimalXMLParser}
    # configuration.tests=FileList['all/of/the/tests/**/*.*']
    module ConfigurationDirectives
      attr_reader :parser,:tools,:paths,:reporters,:tests,:context,:check,:setup,:teardown
      #Adds a hash of values to the tools hash of the configuration
      #
      #This hash is then accessible in the parser and reporters as a property of the configuration instance
      #
      #Required keys:
      # :name - the name to use for accessing the path in code
      #Example:
      # configure do |cfg|
      #  cfg.tool={:name=>"nunit",:path=>"/bin/nunit",:configuration=>{:important=>"info"}}
      # end
      #
      #The path to nunit can then be accessed in the parser as
      # @configuration.tools.nunit[:path]
      #
      #This way you can pass configuration information for the tools you use
      def tool= definition
        @tools||=OpenStruct.new
        raise ConfigurationException,"required key :name is missing from #{definition}" unless definition[:name]
        @tools[definition[:name]]=definition
      end
      #Adds a path to the paths hash of the configuration
      #
      #Required keys:
      # :name - the name to use for accessing the path in code
      # :path - the path
      #Example:
      # cfg.path={:name=>"sources",:path=>"/src"}
      def path= definition
        @paths||=OpenStruct.new
        raise ConfigurationException,"required key :name is missing from #{definition}" unless definition[:name]
        raise ConfigurationException,"required key :path is missing from #{definition}" unless definition[:path]
        @paths[definition[:name]]=definition[:path]
      end
      
      #Path to the setup specification. (optional)
      #
      #The setup test runs before every test.
      def setup= path
        @setup=check_path(path)
      end
      
      #Path to the teardown specification. (optional)
      #
      #The teardown test runs after every test.    
      def teardown= path
        @teardown=check_path(path)
      end
      
      #Path to the check specification. (optional)
      #
      #The check test runs once in the beginning before all the tests.
      #
      #If it fails no tests are run.
      def check= path
        @check=check_path(path)
      end
      
      #Hash values for passing data to the system. It's supposed to be used in the reporters and contain 
      #values such as version numbers, tester names etc.
      def context= definition
        @context||=Hash.new
        raise ConfigurationException,"Only accepting hash values as context_data" unless definition.kind_of?(Hash)
        @context.merge!(definition)
      end
      
      #Adds the specification identifiers available to this instance of Rutema
      #
      #These will usually be files, but they can be anything.
      #Essentially this is an Array of strings that mean something to your parser
      def tests= array_of_identifiers
        @tests||=Array.new
        @tests+=array_of_identifiers.map{|f| full_path(f)}
      end
      
      #A hash defining the parser to use.
      #
      #The hash is passed as is to the parser constructor and each parser should define the necessary configuration keys.
      #
      #The only required key from the configurator's point fo view is :class which should be set to the fully qualified name of the class to use.
      #
      #Example:
      # cfg.parser={:class=>Rutema::MinimalXMLParser}
      def parser= definition
        raise ConfigurationException,"required key :class is missing from #{definition}" unless definition[:class]
        @parser=definition
      end
      
      #Adds a reporter to the configuration.
      #
      #As with the parser, the only required configuration key is :class and the definition hash is passed to the class' constructor.
      # 
      #Unlike the parser, you can define multiple reporters.
      def reporter= definition
        @reporters||=Array.new
        raise ConfigurationException,"required key :class is missing from #{definition}" unless definition[:class]
        @reporters<<definition
      end

      private 
      #Checks if a path exists and raises a ConfigurationException if not
      def check_path path
        path=File.expand_path(path)
        raise ConfigurationException,"#{path} does not exist" unless File.exists?(path)
        return path
      end
      #Gives back a string of key=value,key=value for a hash
      def definition_string definition
        msg=Array.new
        definition.each{|k,v| msg<<"#{k}=#{v}"}
        return msg.join(",")
      end

      def full_path filename
        return File.expand_path(filename) if File.exists?(filename)
        return filename
      end
    end

    class ConfigurationException<RuntimeError
    end

    class Configuration
      include ConfigurationDirectives
      attr_reader :logger,:filename,:cwd
      def initialize config_file,logger=nil
        @filename=config_file
        load_configuration(@filename)
      end

      def configure
        if block_given?
          yield self
        end
      end
    
      #Loads the configuration from a file
      #
      #Use this to chain configuration files together
      #==Example
      #Say you have on configuration file "first.cfg" that contains all the generic directives and several others that change only one or two things. 
      #
      #You can 'include' the first.cfg file in the other configurations with
      # load_from_file("first.cfg")
      def load_from_file filename
        fnm = File.exists?(filename) ? filename : File.join(@wd,filename)
        load_configuration(fnm)
      end
      private
      def load_configuration filename
        begin 
          cfg_txt=File.read(filename)
          @cwd=File.expand_path(File.dirname(filename))
          #add the path to the require lookup path to allow require statements in the configuration files
          $:.unshift @cwd
          #evaluate in the working directory to enable relative paths in configuration
          Dir.chdir(@cwd){eval(cfg_txt,binding(),filename,__LINE__)}
        rescue ConfigurationException
          #pass it on, do not wrap again
          raise
        rescue SyntaxError
          #Just wrap the exception so we can differentiate
          raise ConfigurationException.new,"Syntax error in the configuration file '#{filename}':\n#{$!.message}"
        rescue NoMethodError
          raise ConfigurationException.new,"Encountered an unknown directive in configuration file '#{filename}':\n#{$!.message}"
        rescue 
          #Just wrap the exception so we can differentiate
          raise ConfigurationException.new,"#{$!.message}"
        end
      end
    end
  end