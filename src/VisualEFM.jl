module VisualEFM

using Plots
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
    anim_erosion,
    erosion_colormap,
    anim_smoke,
    stats_smokemap

end
