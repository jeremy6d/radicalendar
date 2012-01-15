require 'ostruct'
require 'yaml'
 
config = YAML.load_file("#{Rails.root}/config/settings.yml") || {}

config.keys.each do |key|
  config[key] = OpenStruct.new(config[key])
end

OrvaEvents::Config = OpenStruct.new(config)