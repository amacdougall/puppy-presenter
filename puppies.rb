# Script which reads the Instagram feed for puppies and generates a static page
require 'rest-client'
require 'json'
require 'yaml'
require 'haml'


config = YAML::load_file "config.yml"

media_url = "https://api.instagram.com/v1/users/#{config["target_user_id"]}/media/recent/"
media_url << "?client_id=#{config["client_id"]}&access_token=#{config["access_token"]}"

# get puppy data from server
puppy_data = JSON.parse(RestClient.get(media_url))

# get all 612x612 images
images = puppy_data["data"].map do |puppy|
  puppy["images"]["standard_resolution"]["url"]
end

# get only new images
if File.exists? config["last_image_filename"]
  last_images = JSON.load(File.open(config["last_image_filename"]))
  images -= last_images # remove any which have already been seen
end

# generate HTML from template
# TODO: put template in a template directory
template = File.read config["template_filename"]
engine = Haml::Engine.new template, {format: :html5}
output = engine.render Object.new, :images => images

# write output to file
# TODO: write to an output directory instead
output_file = File.open(config["output_filename"], "w")
output_file.write output
output_file.close

# TODO: upload output file to server

# TODO: notify interested parties
