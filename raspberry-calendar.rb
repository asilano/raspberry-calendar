# encoding: utf-8
require 'yaml'
require './lib/webdriver'

if __FILE__ == $0
  config = YAML::load_file('config.yml')
  webdriver = Webdriver.new(config, File.absolute_path('.cookies'))

  while true do

  end
end