# Script which reads the Instagram feed for puppies and generates a static page.
# Some lines end in ; to suppress pry output.
require 'rest-client'
require 'json'
require 'yaml'
require 'haml'

config = YAML::load_file "config.yml"

media_url = "https://api.instagram.com/v1/"
media_url << "users/#{config["instagram"]["target_user_id"]}/media/recent/"
media_url << "?client_id=#{config["instagram"]["client_id"]}"
media_url << "&access_token=#{config["instagram"]["access_token"]}"
media_url << "&count=16" # 16 results gives a 4x4 grid

# get puppy data from server
puppy_data = JSON.parse(RestClient.get(media_url));

# 150, 306, and 612 on a side
images = puppy_data["data"].map do |puppy|
  {
    thumb: puppy["images"]["thumbnail"]["url"],
    medium: puppy["images"]["low_resolution"]["url"],
    full: puppy["images"]["standard_resolution"]["url"]
  }
end;

# limit to first 16, for a 4x4 thumbnail grid
images = images.first 16;

# clear output directory
Dir["#{config["files"]["output_dir"]}/*"].each {|file| FileUtils.rm_rf file}

# generate HTML from template
template = File.read config["files"]["template"]
engine = Haml::Engine.new template, :format => :html5;
output = engine.render Object.new, :images => images;

# write destination html file
output_file = File.open config["files"]["index"], "w"
output_file.write output
output_file.close

# TODO: generate Coffeescript and Sass

# copy static output files
Dir[File.join config["files"]["static_dir"], "*"].each do |file|
  FileUtils.cp_r file, config["files"]["output_dir"]
end
