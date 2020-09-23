# VisualEFM

This package provides useful tool for a few techniques on experimental fluid mechanics. The package mainly deals with image processing techniques, so [JuliaImages](https://juliaimages.org/stable/) packages were applied. 

At the moment, only the algorithms for sand erosion technique are available. A few algorithms that can be useful for both water table and smoke vizualizing techniques are being developed.

## Sand Erosion

This is a technique used in wind tunnels that can be be applied for large and flat urban areas to identify regions of high wind velocities at pedestrian level, which can produce poor comfort or even dangerous areas, as well as regions of low wind velocities, that can generate heat islands with poor ventilation.

The technique consists of spreading sand on the flat surface of the model and starting increasing the wind tunnel velocity. As the velocity increases, erosion patterns are produced. The first patterns produced, at low wind tunnel velocities, can be related to regions where, in the real case, the local wind velocities at pedestrian level tend to be higher. An example is shown below.

![patterns](https://user-images.githubusercontent.com/49885481/93953517-fc7cb200-fd21-11ea-8ff7-a50dab2b1048.png)

The analysis of many pictures can be an anoying job, so a few tools are presented in this package.

### Pattern produced between two velocities

The pattern produced between two velocities can be computed using the function `erosionOne` with the arguments (must be given in order):

* image to be analyzed 
* background image 

```julia
img = readImage("rpm200.jpg")
bgimg = readImage("rpm000.jpg")
erosionOne(im, bgim, figtitle="200 rpm", ref_img=bgimg);
```


When reading the image, not only a region of interest can be applied, but also a mask. The mask is a boolean array and can be read withe the function `binMask`. The only argument is the image name. The following code can be used:

```julia
mask = binMask("mascara.png")
f = ["rpm000.jpg", "rpm200.jpg"]
img_mask = readImage.(f, roi[500:2050,:], mask=mask)
erosionOne(img_mask[2], img_mask[1], figtitle="200 rpm - partial", ref_img=bgimg)
```

The image below shows the result when no mask is used and when a retangular mask is applied.

![erosion_onecase](https://user-images.githubusercontent.com/49885481/93951569-123ba880-fd1d-11ea-97ba-2d422bb3b0a9.png)

### Erosion animation

An animation can also be created when a sequence of images is subtracted from a background image (taken at the beginning of the test when no pattern is presented). The function `animErosion` can be applied. Two examples are shown below. One without mask and othe with the same rectangular mask applied before.

```julia
f = "rpm".*["000","150","175","200","225","250","270","310","400"].*".jpg"
imgs = readImage.(f, roi=[500:2050,:])
animErosion("no_mask.gif", imgs[2:end], [imgs[1]], ref_img=imgs[1]);
```

![exErosion_anim](https://user-images.githubusercontent.com/49885481/93951331-62fed180-fd1c-11ea-92a5-a3a2b9cb74a8.gif)

```julia
imgs_mask = readImage.(f, roi=[500:2050,:], mask=mask)
animErosion("with_mask.gif", imgs_mask[2:end], [imgs_mask[1]], ref_img=imgs[1]);
```

![exErosion_anim_mask](https://user-images.githubusercontent.com/49885481/93951349-6eea9380-fd1c-11ea-9ab1-bd67a01efcec.gif)

### Color map

Finally, color maps can be produced with the function `erosionColorMap`

```julia
u = [150,175,200,225,250,270,310,400]
erosionColorMap(imgs, u, ref_img=imgs[1], figtitle="without mask", cb_title="WT rpm") 
erosionColorMap(imgs_mask, u, ref_img=imgs[1], figtitle="with mask", cb_title="WT rpm")
```

![erosion_colorMap](https://user-images.githubusercontent.com/49885481/93951725-752d3f80-fd1d-11ea-87ce-381fa50284dd.png)


[![Build Status](https://travis-ci.com/gborelli89/VisualEFM.jl.svg?branch=master)](https://travis-ci.com/gborelli89/VisualEFM.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/gborelli89/VisualEFM.jl?svg=true)](https://ci.appveyor.com/project/gborelli89/VisualEFM-jl)
[![Coverage](https://codecov.io/gh/gborelli89/VisualEFM.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/gborelli89/VisualEFM.jl)
[![Coverage](https://coveralls.io/repos/github/gborelli89/VisualEFM.jl/badge.svg?branch=master)](https://coveralls.io/github/gborelli89/VisualEFM.jl?branch=master)
