# WIR: Worth Image Resizer

This is a simple Ruby gem to resize and compress an image within a given folder.
```
Usage:
  wir resize -d, --directory=DIRECTORY

Options:
  -m, [--max-dimension=N]    # The maximum dimension of the resized image
                             # Default: 1920
  -q, [--quality=N]          # The resized image quality
                             # Default: 75
  -d, --directory=DIRECTORY  # The image input directory
  -p, [--prefix=PREFIX]      # The resized image name prefix
                             # Default: image
  -f, [--format=FORMAT]      # The resized image extension
                             # Default: jpeg
  -o, [--output=OUTPUT]      # The resized image output directory
                             # Default: .

Bulk-resize the images within a given directory.
```
## Installation

Install it in your local machine via Ruby gem
```
gem install wir
```
