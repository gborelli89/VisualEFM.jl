module VisualEFM

using Plots
using Images
using ImageFiltering
using ImageBinarization
using ImageMorphology

include("utils.jl")
include("sandErosion.jl")

export 
    binarizeMask!,
    readImage,
    erosionOne,
    animErosion,
    erosionColorMap

end
