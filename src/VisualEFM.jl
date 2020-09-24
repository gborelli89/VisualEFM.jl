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
    binMask,
    readImage,
    erosionOne,
    animErosion,
    erosionColorMap,
    animSmoke,
    statSmokeMap

end
