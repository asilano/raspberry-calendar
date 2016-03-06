# encoding: utf-8
$: << './lib'
require 'yaml'
require 'webdriver'
require 'command_interpreter'

class Controller
  attr_reader :webdriver

  def initialize
    @config = YAML::load_file('config.yml')
  end

  def run
    @webdriver = Webdriver.new(@config, File.absolute_path('.cookies'))

    while true do
      begin
        input = gets.chomp
        command = CommandInterpreter::parse input
        if (command)
          command.execute(self)
        else
          puts "  Sorry?"
        end
      rescue StandardError => e
        puts "  Oh dear, something broke. Recovering..."
        puts e
        @webdriver.reset
      end
    end
  end
end

if __FILE__ == $0
  ctrl = Controller.new
  ctrl.run
end