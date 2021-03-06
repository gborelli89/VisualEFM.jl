module VisualEFM

using Plots
gr();
using Images
using ImageFiltering
using ImageBinarization
using ImageMorphology

include("utils.jl")
include("sandErosion.jl")
include("smoke.jl")

export 
    binarymask,
    read_image,
    erosion_one,
    erosion_anim,
    erosion_colormap,
    smoke_anim,
    smoke_statsmap

end
