require "mini_magick"
require "optparse"
require "ostruct"
require "image_optimizer"

MAX_DIMENSION = 1920
DEFAULT_QUALITY = 75

def calculate_dimensions(dimensions)
  maximum = dimensions.max
  minimum = dimensions.min
  
  width = maximum.clamp(0, MAX_DIMENSION)
  height = minimum unless width == MAX_DIMENSION
  
  height ||= (minimum.to_f / maximum * width).ceil.to_i
  
  dimensions[0] > dimensions[1] ? [width, height] : [height, width]
end

options = OpenStruct.new
OptionParser.new do |opt|
  opt.on("-m MAX_DIMENSION", "The image's maximum dimension. The default value is #{MAX_DIMENSION}") { |o| options.max_dimension = o }
  opt.on("-q IMAGE_QUALITY", "The image quality. The default value is #{DEFAULT_QUALITY}") { |o| options.quality = o }
  opt.on("-d DIRECTORY_NAME", "The directory that contains the images") { |o| options.dirname = o }
  opt.on("-p PREFIX", "The image output prefix") { |o| options.prefix = o }
  opt.on("-f FORMAT", "The image format. When the option is not given, it shall use the original image format") { |o| options.format = o }
  opt.on("-o OUTPUT_DIR", "The image output directory. The default value is `output`") { |o| options.output_dir = o }
end.parse!

raise "Directory is not exists!" unless Dir.exist? options.dirname

options.prefix ||= "image"
options.output_dir ||= "output"
options.quality ||= DEFAULT_QUALITY

Dir.mkdir options.output_dir unless Dir.exist? options.output_dir

logger = Logger.new(STDOUT)
logger.info { "Resizing and compressing image with options: #{options.to_h}" }
filenames = Dir["#{options.dirname}/*"]
logger.info { "Got #{filenames.size} images to be resized and compressed. Resizing..." }
filenames.each_with_index do |filename, index|
  image = MiniMagick::Image.open(filename)
  extension = options.format || image.mime_type.split("/").last
  width, height = calculate_dimensions image.dimensions
  output_path = "#{options.output_dir}/#{options.prefix}-#{index + 1}.#{extension}"

  logger.info { "Processing #{output_path}..." }
  image.resize "#{width}x#{height}"
  image.format extension
  image.write(output_path)
  ImageOptimizer.new(output_path, quality: options.quality, quiet: true).optimize
end
logger.info { "Done." }