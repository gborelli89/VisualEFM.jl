# New color palette
inv_rainbow = [:red,:orange,:yellow,:green,:blue]

"""
    getcolors(n; palette_name=inv_rainbow, alpha=0.6)

## Description
Given a color palette gets discrete number of colors.
## Arguments
- n: number of colors
- pallete_name: name of the color palette
- alpha: opacity
"""
function getcolors(n; palette_name=inv_rainbow, alpha=0.6)
    col = cgrad(palette_name, n, categorical=true, alpha=alpha)
end

"""
    binarymask(maskname::String)

## Description
Returns a binary mask from a blck and white image
## Arguments
- maskname: string with the file name
returns a binary mask
"""
function binarymask(maskname::String)
    mask = load(maskname)
    mask = Gray{Float64}.(mask)
    mask = round.(mask)
    mask = Bool.(mask)
end

""" 
    read_image(fname::String; roi=nothing, mask::Union{BitArray{2}, Nothing}=nothing, outercolour=RGBA(1,1,1,0))

## Description
Function that can be used to load one or more images (with broadcasting)
## Arguments
- fname: file name
- roi: region of interest (if nothing, roi = [:,:])
- mask: provide a mask be aplied to the figure (BitArray{2}). White is the portion to be kept
returns the images with with roi and mask applied
- outercolour: RGBA colour to be applied to the non valid region (default=RGBA(1,1,1,0) -> white)
## Example
```jldoctest
julia> using VisualEFM

julia> fnames = "rpm" .* string.(collect(0:90:270)) .* ".jpg"
4-element Array{String,1}:
 "rpm0.jpg"
 "rpm90.jpg"
 "rpm180.jpg"
 "rpm270.jpg"

 #(Not run)
julia> im = read_image.(fnames)
```
"""
function read_image(fname::String; roi=nothing, mask::Union{BitArray{2}, Nothing}=nothing, outercolour=RGBA(1,1,1,0))
    
    img = load(fname)

    if !isnothing(mask)	
        mask = .!Bool.(mask)
        img[mask] .= outercolour
    end
    if !isnothing(roi)
    	img = img[roi[1],roi[2]]
    end

    return img
end

"""
    apply_gaussian(img; ksize=1)

## Description
Apply a gaussian filter on the images.
## Arguments
- im: original image
- ksize: size of the kernel (Kernel.gaussian)
returns blur image
"""
function apply_gaussian(img::AbstractArray; ksize=1)
    k = Kernel.gaussian(ksize)
    blur = imfilter(img, reflect(k)) # apply convolution!0
    return blur
end

"""
    gauss_grayscale(img::AbstractArray; ksize=1)

## Description
Auxiliary function to apply a Gaussian filter on the image and convert it to grayscale.
## Arguments
- img: image 
- ksize: size of the kernel (Kernel.gaussian)
returns the image filtered and in grayscale
"""
function gauss_grayscale(img::AbstractArray; ksize=1)
    
    img_blur = apply_gaussian(img, ksize=ksize)
    img_gs = Gray.(img_blur)

    return img_gs

end

"""
    backsubtraction(img::AbstractArray, bgimg::AbstractArray; inverse=false)

## Description
Background subtraction (grayscale).
## Arguments
- img: image 
- bgimg: background image
- inverse: if false do img-bgimg, if true do bgimg-img
returns grayscale image subtracted
"""
function backsubtraction(img::AbstractArray, bgimg::AbstractArray; inverse=false)  

    if ndims(img) != ndims(bgimg)
        throw(DimensionMismatch("img and bgimg should have the same dimension!"))
    end

    inverse ? img_sub = bgimg .- img : img_sub = img .- bgimg

    return img_sub

end


"""  
    getdiffpattern(img::AbstractArray, bgimg::AbstractArray; thrfun = Otsu(), nclose=1, inverse=true)

## Description
Function to get the difference pattern.
## Arguments
- img: image to extract pattern
- bgimg: image to subtract (background subtraction)
- thrfun: threshold algorithm (default Otsu)
- nclose: number of times to apply dilatation followed by erosion (closing)
- inverse: direction of background subtraction (see backsubtraction)
returns image difference pattern
"""
function getdiffpattern(img::AbstractArray, bgimg::AbstractArray; thrfun = Otsu(), nclose=1, inverse=true)

    img_pattern = backsubtraction(Gray.(img), Gray.(bgimg), inverse=inverse)  
    binarize!(img_pattern, thrfun)

    # if nclose is negative or zero, nothing is done!
    if nclose <= 0
        @warn("If nclose is negative or zero, no closing is applied!")
    else
        [dilate!(img_pattern) for _ in 1:nclose]
        [erode!(img_pattern) for _ in 1:nclose]
    end

    return img_pattern

end
