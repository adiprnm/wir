
# Ruby Image Resizer dan Compressor

This is a simple Ruby script to resize and compress an image within a given folder.

```
Usage: resizer [options]
    -m MAX_DIMENSION                 The image's maximum dimension. The default value is 1920
    -q IMAGE_QUALITY                 The image quality. The default value is 75
    -d DIRECTORY_NAME                The directory that contains the images
    -p PREFIX                        The image output prefix. The default value is `image`
    -f FORMAT                        The image format. When the option is not given, it shall use the original image format
    -o OUTPUT_DIR                    The image output directory. The default value is `output`
```

Note that this script requires some dependencies, especially the `image_optimizer` gem. Please read the docs [here](https://github.com/jtescher/image_optimizer) for the full documentation.

