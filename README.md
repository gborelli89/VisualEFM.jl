# VisualEFM

This package provides useful tool for a few techniques on experimental fluid mechanics. The package mainly deals with image processing techniques, so [JuliaImages](https://juliaimages.org/stable/) packages were used. The development started at [gborelli89/VisualEFM.jl](https://github.com/gborelli89/VisualEFM.jl), but now the development is being shared on [tunelipt/VisualEFM.jl](https://github.com/tunelipt/VisualEFM.jl).

At the moment, only the algorithms for sand erosion technique are available. A few algorithms that can be useful for both water table and smoke visualizing techniques are being developed.

## Some useful functions

There are some useful functions implemented in the package:

* `VisualEFM.getColors`: given a color palette extracts discrete number of colors.
* `binMask`: reads a black and white figure (mask) and turns it into a boolean matrix.
* `readImage`: reads an image. If desired, one can extract only a ROI and apply a mask.
* `VisualEFM.applyGaussian`: applies blur to an image considering a gaussian kernel.
* `VisualEFM.backsubtraction`: applies backsubtraction to an image.
* `VisualEFM.getDiffPattern`: gets a pattern by differencing two images (after thresholding and closing). 

## Sand Erosion

This is a technique used in wind tunnels that can be be applied for large and flat urban areas to identify regions of high wind velocities at pedestrian level, which can lead to uncomfortable or even dangerous areas, as well as regions of low wind velocities, that can generate heat islands with poor ventilation.

The technique consists of spreading sand on the flat surface of the model and starting increasing the wind tunnel velocity. As the velocity increases, erosion patterns are produced. The first patterns produced, at low wind tunnel velocities, can be related to regions where, in the real case, the local wind velocities at pedestrian level tend to be higher. An example is shown below.

![patterns](https://user-images.githubusercontent.com/49885481/93953517-fc7cb200-fd21-11ea-8ff7-a50dab2b1048.png)

The analysis of many pictures can be an annoying job, so a few tools are presented in this package.

### Pattern produced between two velocities

The pattern produced between two velocities can be computed using the function `erosionOne` with the following required parameters (given in order).

* image to be analyzed 
* background image 

Other optional parameters are:

* `figtitle`: the title of the image produced (default: no title)
* `ref_img`: image to be ploted as a backgroud image for the erosion pattern (default: no image)
* `ksize`: the size of the kernel for the Gaussian blur (function `VisualEFM.applyGaussian` - default: `ksize=3`)
* `thrfun`: The threshold algorithm which should be appied for image binarization (default: `Otsu()`, see the documentation of [ImageBinarization.jl](https://zygmuntszpak.github.io/ImageBinarization.jl/stable/) for other algorithms)
* `nclose`: number of times the algorithms `ImageMorphology.dilate!` and `ImageMorphology.erode!` are applied in sequence to produce closing in the `VisualEFM.getDiffPattern` function (default: `nclose=1`)
* `col`: RGBA color that shoud be appied for the erosion pattern (default: `col=RGBA(1.0,0.0,0.0,0.5)`)
* `showPlot`: if true (default) a figure is presented.

The function returns 2 values: the erosion figure (which is plotted if `showPlot=true`) and a boolean array indicating the erosion region.

```julia
img = readImage("rpm200.jpg")
bgimg = readImage("rpm000.jpg")
erosionOne(im, bgim, figtitle="without mask", ref_img=bgimg);
```

When reading the image, not only a region of interest (`roi`) can be applied, but also a mask. The mask is a boolean array and can be read with the function `binMask`. The only argument is the image name. The following code can be used:

```julia
mask = binMask("mascara.png")
f = ["rpm000.jpg", "rpm200.jpg"]
img_mask = readImage.(f, roi[500:2050,:], mask=mask)
erosionOne(img_mask[2], img_mask[1], figtitle="with mask", ref_img=bgimg)
```

The image below shows the result when no mask is used and when a retangular mask is applied.

![erosion_onecase](https://user-images.githubusercontent.com/49885481/93951569-123ba880-fd1d-11ea-97ba-2d422bb3b0a9.png)

### Erosion animation

An animation can also be created when a sequence of images is subtracted from a background image (taken at the beginning of the test when no pattern is presented). The function `animErosion` can be applied. The required parameters are:

* string with the file name to be saved (should be .gif)
* array of images for which the erosion patterns are to be extracted
* array of background images. Usually only one image is given. 

The same optional parameters of `erosionOne` can be applied (except from `showPlot`). An additional parameter is `fps` which provides a way to speed up or down the final gif. The default is `fps=1`. 

```julia
f = "rpm".*["000","150","175","200","225","250","270","310","400"].*".jpg"
imgs = readImage.(f, roi=[500:2050,:])
animErosion("no_mask.gif", imgs[2:end], [imgs[1]], ref_img=imgs[1]);
```

![exErosion_anim](https://user-images.githubusercontent.com/49885481/93951331-62fed180-fd1c-11ea-92a5-a3a2b9cb74a8.gif)


### Color maps

Finally, color maps can be produced with the function `erosionColorMap`. The required parameters are:

* the sequence of images (image without pattern included)
* the label values for each pattern (length should be the length of the array of images given minus one)

The optional arguments, `figtitle`, `ref_img`, `ksize`, `thrfun`, `nclose` and `showPlot` can also be modified. Moreover, there is a `cb_title` entry which provides a way to print a legend for the color bar. This time, the `col`argument is a color palette. A inverse rainbow is defined as default (`inv_rainbow`).

```julia
u = [150,175,200,225,250,270,310,400]
erosionColorMap(imgs, u, ref_img=imgs[1], figtitle="without mask", cb_title="WT rpm") 
erosionColorMap(imgs_mask, u, ref_img=imgs[1], figtitle="with mask", cb_title="WT rpm")
```

The figures below show the results obtained for the scenario with no masks (left) and the one with the same rectangular mask used previously (right).

![erosion_colorMap](https://user-images.githubusercontent.com/49885481/93951725-752d3f80-fd1d-11ea-87ce-381fa50284dd.png)


[![Build Status](https://travis-ci.com/gborelli89/VisualEFM.jl.svg?branch=master)](https://travis-ci.com/gborelli89/VisualEFM.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/gborelli89/VisualEFM.jl?svg=true)](https://ci.appveyor.com/project/gborelli89/VisualEFM-jl)
[![Coverage](https://codecov.io/gh/gborelli89/VisualEFM.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/gborelli89/VisualEFM.jl)
[![Coverage](https://coveralls.io/repos/github/gborelli89/VisualEFM.jl/badge.svg?branch=master)](https://coveralls.io/github/gborelli89/VisualEFM.jl?branch=master)
