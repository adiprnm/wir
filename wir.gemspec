Gem::Specification.new do |spec|
  spec.name        = 'wir'
  spec.version     = '1.0.1'
  spec.authors     = ['Adi Purnama']
  spec.email       = 'adiprnm84@gmail.com'
  spec.homepage    = 'https://github.com/adiprnm/wir'
  spec.summary     = 'Resize and compress the image via command-line interface.'
  spec.license     = 'MIT'
  spec.files = Dir['lib/**/*']
  spec.executables = %w[wir]

  spec.add_dependency 'image_optimizer'
  spec.add_dependency 'mini_magick'
  spec.add_dependency 'thor'

  spec.add_development_dependency 'pry'
end
