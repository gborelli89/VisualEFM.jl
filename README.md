# VisualEFM

This package provides useful tool for a few techniques on experimental fluid mechanics. The package mainly deals with image processing techniques, so [JuliaImages](https://juliaimages.org/stable/) packages were used. The development started at [gborelli89/VisualEFM.jl](https://github.com/gborelli89/VisualEFM.jl), but now it is being done on [tunelipt/VisualEFM.jl](https://github.com/tunelipt/VisualEFM.jl). 

## Some useful functions

There are some useful functions implemented in the package:

* `VisualEFM.getColors`: given a color palette extracts discrete number of colors.
* `binMask`: reads a black and white figure (mask) and turns it into a boolean matrix.
* `readImage`: reads an image. If desired, one can extract only a ROI and apply a mask.
* `VisualEFM.applyGaussian`: applies blur to an image considering a gaussian kernel.
* `VisualEFM.backsubtraction`: applies backsubtraction to an image.
* `VisualEFM.getDiffPattern`: gets a pattern by differencing two images (after thresholding and closing). 
* `VisualEFM.imgGaussGrayscale`: auxiliary function to apply gaussian blur to an image and converts it to graysacale.

## Sand Erosion

This is a technique used in wind tunnels that can be be applied for large and flat urban areas to identify regions of high wind velocities at pedestrian level, which can lead to uncomfortable or even dangerous areas, as well as regions of low wind velocities, that can generate heat islands with poor ventilation.

The technique consists of spreading sand on the flat surface of the model and starting increasing the wind tunnel velocity. As the velocity increases, erosion patterns are produced. The first patterns produced, at low wind tunnel velocities, can be related to regions where, in the real case, the local wind velocities at pedestrian level tend to be higher. An example is shown below.

![patterns](https://user-images.githubusercontent.com/49885481/93953517-fc7cb200-fd21-11ea-8ff7-a50dab2b1048.png)

The analysis of many pictures can be an annoying job, so a few tools are presented in this package.

### Pattern produced between two velocities

The pattern produced between two velocities can be computed using the function `erosionOne` with the following required parameters (given in order).

* `img`: image to be analyzed 
* `bgimg`: background image 

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

* `sname`: string with the file name to be saved (should be .gif)
* `imgs`: array of images for which the erosion patterns are to be extracted
* `bgimgs`: array of background images. Usually only one image is given. 

The same optional parameters of `erosionOne` can be applied (except from `showPlot`). An additional parameter is `fps` which provides a way to speed up or down the final gif. The default is `fps=1`. 

```julia
f = "rpm".*["000","150","175","200","225","250","270","310","400"].*".jpg"
imgs = readImage.(f, roi=[500:2050,:])
animErosion("no_mask.gif", imgs[2:end], [imgs[1]], ref_img=imgs[1]);
```

![exErosion_anim](https://user-images.githubusercontent.com/49885481/93951331-62fed180-fd1c-11ea-92a5-a3a2b9cb74a8.gif)


### Erosion color maps

Finally, color maps can be produced with the function `erosionColorMap`. The required parameters are:

* `imgseq`: the sequence of images (image without pattern included)
* `U`: the label values for each pattern (length should be the length of the array of images given minus one)

The optional arguments, `figtitle`, `ref_img`, `ksize`, `thrfun`, `nclose` and `showPlot` can also be modified. Moreover, there is a `cb_title` entry which provides a way to print a legend for the color bar. This time, the `col`argument is a color palette. A inverse rainbow is defined as default (`inv_rainbow`).

```julia
u = [150,175,200,225,250,270,310,400]
erosionColorMap(imgs, u, ref_img=imgs[1], figtitle="without mask", cb_title="WT rpm") 
erosionColorMap(imgs_mask, u, ref_img=imgs[1], figtitle="with mask", cb_title="WT rpm")
```

The figures below show the results obtained for the scenario with no masks (left) and the one with the same rectangular mask used previously (right).

![erosion_colorMap](https://user-images.githubusercontent.com/49885481/93951725-752d3f80-fd1d-11ea-87ce-381fa50284dd.png)

## Water table and smoke visualization techniques

Many visualization techniques are used in both water channels and wind tunnels. These are important tools that helps us to better understand fluid flow. This package presents some functions to help us with these visualization techniques. It is important to mention that the operations are done on grayscale images and it is basically a qualitative tool. No information on the velocity field is obtained. However, the functions are useful in identifying wakes and jets.

### Frames extraction

In many cases videos are recorded during experimental campaigns. Lighting plays an important whole. Contrast is necessary to better visualize the streaklines. There are many tools to extract the frames of a video, but one might want to use [VideoIO.jl](https://github.com/JuliaIO/VideoIO.jl). Some functions that can be used to extract the frames and save them in png files are given below. These functions were not incorporated into the project for now.

```julia
using VideoIO
using Images

# Function to read and count number of frames of a videoName
# --------------------------------------------------------------------------------------------
# videoName: video name (with extension)
# --------------------------------------------------------------------------------------------
# returns the VideoReader
# --------------------------------------------------------------------------------------------
function readCountVideo(videoName::String)
    
    f = VideoIO.openvideo(videoName)
    println(counttotalframes(f))

    return f

end

# Function to break the video in multiple frames
# --------------------------------------------------------------------------------------------
# f: VideoReader returned from readCountVideo
# skip_frames: integer with the number of frames to skip
# roi: region of interest
# --------------------------------------------------------------------------------------------
# returns images of the frames
# --------------------------------------------------------------------------------------------
function breakVideo(f, skip_frames::Int64; roi=nothing)

    img = []

    if skip_frames == 0
        for i in f
            if !isnothing(roi)
                i = i[roi[1],roi[2]]
            end
            push!(img, i)
        end
    elseif skip_frames > 0
        for i in f
            if !isnothing(roi)
                i = i[roi[1],roi[2]]
            end
            push!(img, i)
            skipframes(f, skip_frames, throwEOF=false)
        end
    else
        throw(DomainError(skip_frames,"skip_frames must be positive!"))
    end

    return img
end

# Save png frame files
# --------------------------------------------------------------------------------------------
# img: array of images returned from breakVideo()
# dname: directory name (to save frames in png)
# --------------------------------------------------------------------------------------------
# saves the frames inside the folder given
# --------------------------------------------------------------------------------------------
function saveFrames(img, dname::String)

    n = length(img)
    fnames = string(dname)*"frame".*string.(collect(1:n)).*".png"

    [save(fnames[i], img[i]) for i in 1:n]

    println("Done! Frames saved in "*dname)

end
```

### Creating an animation with the extracted frames

A heatmap gif can be created with the frames extracted. Again, the colors actually represent the grayscale. Depending on the technique applied, higher values may represent jets or wakes. The function `animSmoke` can be used for that. It just presents the data in a nicer manner. The required parameters are:

* `sname`: string with the name of the gif file to be saved
* `imgs`: array of frames (read with `readImage`)
* `bgimg`: background image to subtract from (if no image was obtained, `nothing` must be used)

The optional parameters are:

* `figtitle` and `cb_title`: figure and colorbar titles
* `fps`: gif speed in frames per second
* `ksize`: size of the gaussian filter applied (default: `ksize=3`)
* `inverse`: direction of back subtraction
* `col` and `alpha`: color palette (default: `col=:rainbow`) and opacity (default: `alpha=1.0`)
* `clim`: colorbar limits (default: `clim=(-Inf,Inf)`)

Example:

```julia
f = "frame".*string.(collect(1:40)).*".png" # file names for the first 40 frames
imgs = readImage.(f)
animSmoke("my_anim.gif", imgs, nothing, figtitle="Example", cb_color="Grayscale", alpha=0.8)
# No background subtraction 
```
![my_anim](https://user-images.githubusercontent.com/49885481/94213557-7beabc80-fead-11ea-9871-d3d3346dc188.gif)

### Statistics on the grayscale frames

Many phenomena are transient and turbulence is usually present. It is sometimes useful to find mean and standard deviation values. With the grayscale images this can be done to find mean and std gray values in space. This tool is useful to compare diferent scenarios. The function is `statSmokeMap` The parameters are the same as those for `animSmoke`, but instead of a file name, the first parameter required is a statistic function. The function works for `mean` and `std` of the `Statistics.jl` package, but other functions can be used if desired.

Example:

```julia
using Statistics
statSmokeMap(mean, imgs, nothing, cb_title="Mean Grayscale Values")
statSmokeMap(std, imgs, nothing, cb_title="Std Grayscale Values", col=:bluesreds)
```
![stats_example](https://user-images.githubusercontent.com/49885481/94213568-82793400-fead-11ea-9007-59d99b947787.png)

## Acknowledgements

The sand erosion pictures were obtained from *Institute for Technological Research (IPT), São Paulo, Brazil*. 

The water table videos were kindly provided by *M.Sc. Michele Rossi*. 

[![Build Status](https://travis-ci.com/gborelli89/VisualEFM.jl.svg?branch=master)](https://travis-ci.com/gborelli89/VisualEFM.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/gborelli89/VisualEFM.jl?svg=true)](https://ci.appveyor.com/project/gborelli89/VisualEFM-jl)
[![Coverage](https://codecov.io/gh/gborelli89/VisualEFM.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/gborelli89/VisualEFM.jl)
[![Coverage](https://coveralls.io/repos/github/gborelli89/VisualEFM.jl/badge.svg?branch=master)](https://coveralls.io/github/gborelli89/VisualEFM.jl?branch=master)
