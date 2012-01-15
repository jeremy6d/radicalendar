require 'ostruct'
require 'yaml'
 
config = YAML.load_file("#{Rails.root}/config/settings.yml") || {}
config.keys.each do |key|
  config[key] = OpenStruct.new(config[key])
end
Config = OpenStruct.new(config)