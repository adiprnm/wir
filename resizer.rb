require "mini_magick"
require "optparse"
require "ostruct"
require "image_optimizer"

DEFAULTS = {
  image_quality: 75,
  max_dimension: 1920,
  prefix: "image",
  output_dir: "output"
}

def calculate_dimensions(dimensions)
  maximum = dimensions.max
  minimum = dimensions.min
  
  width = maximum.clamp(0, DEFAULTS[:max_dimension])
  height = minimum unless width == DEFAULTS[:max_dimension]
  
  height ||= (minimum.to_f / maximum * width).ceil.to_i
  
  dimensions[0] > dimensions[1] ? [width, height] : [height, width]
end

options = OpenStruct.new
OptionParser.new do |opt|
  opt.on("-m MAX_DIMENSION", "The image's maximum dimension. The default value is #{DEFAULTS[:max_dimension]}") { |o| options.max_dimension = o }
  opt.on("-q IMAGE_QUALITY", "The image quality. The default value is #{DEFAULTS[:image_quality]}") { |o| options.quality = o }
  opt.on("-d DIRECTORY_NAME", "The directory that contains the images") { |o| options.dirname = o }
  opt.on("-p PREFIX", "The image output prefix. The default value is `#{DEFAULTS[:prefix]}`") { |o| options.prefix = o }
  opt.on("-f FORMAT", "The image format. When the option is not given, it shall use the original image format") { |o| options.format = o }
  opt.on("-o OUTPUT_DIR", "The image output directory. The default value is `#{DEFAULTS[:output_dir]}`") { |o| options.output_dir = o }
end.parse!

raise "Directory is not exists!" unless Dir.exist? options.dirname

options.prefix ||= DEFAULTS[:prefix]
options.output_dir ||= DEFAULTS[:output_dir]
options.quality ||= DEFAULTS[:image_quality]

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