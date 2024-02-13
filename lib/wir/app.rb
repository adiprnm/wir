require "thor"
require "mini_magick"
require "image_optimizer"

module Wir
  class App < Thor
    ALLOWED_EXTENSIONS = ["jpg", "jpeg", "png"].freeze

    desc "resize", "bulk-resize the images"

    method_option :max_dimension,
                  aliases: "-m",
                  desc: "The maximum dimension of the resized image",
                  type: :numeric,
                  default: 1920
    method_option :quality,
                  aliases: "-q",
                  desc: "The resized image quality",
                  type: :numeric,
                  default: 75
    method_option :directory,
                  aliases: "-d",
                  desc: "The image input directory",
                  type: :string,
                  required: true
    method_option :prefix,
                  aliases: "-p",
                  desc: "The resized image name prefix",
                  type: :string,
                  default: "image"
    method_option :format,
                  aliases: "-f",
                  desc: "The resized image extension",
                  type: :string,
                  default: "jpeg"
    method_option :output,
                  aliases: "-o",
                  desc: "The resized image output directory",
                  type: :string,
                  default: "."
    def resize
      unless Dir.exist? options["directory"]
        puts "Cannot resize the image: directory is not exists!"
        return
      end

      Dir.mkdir options["output"] unless Dir.exist? options["output"]

      logger = Logger.new(STDOUT)
      logger.info { "Resizing and compressing images with options: #{options.to_h}" }

      filenames = Dir["#{options["directory"]}/*"].select do |file|
        ALLOWED_EXTENSIONS.any? { |ext| file.downcase.end_with? ext }
      end

      logger.info { "Got #{filenames.size} images to be resized and compressed. Resizing..." }

      filenames.each_with_index do |filename, index|
        image = MiniMagick::Image.open(filename)
        image.auto_orient

        width, height = calculate_dimensions image.dimensions
        output_path = "#{options["output"]}/#{options["prefix"]}-#{index + 1}.#{options["format"]}"

        logger.info { "Processing #{output_path}..." }
        image.resize "#{width}x#{height}"
        image.format options["format"]
        image.write(output_path)
        ImageOptimizer.new(output_path, quality: options.quality, quiet: true).optimize
      end

      logger.info { "Done." }
    end

    private
      def calculate_dimensions(dimensions)
        minimum, maximum = dimensions.sort
        max_dimension = options["max_dimension"]

        width = maximum.clamp(0, max_dimension)
        height = minimum unless width == max_dimension

        height ||= (minimum.to_f / maximum * width).ceil.to_i

        dimensions[0] > dimensions[1] ? [width, height] : [height, width]
      end
  end
end

