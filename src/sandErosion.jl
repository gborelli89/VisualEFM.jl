"""
    erosion_one(img::AbstractArray, bgimg::AbstractArray; figtitle=" ", ref_img=nothing, ksize= 3, thrfun = Otsu(), nclose=1, col=RGBA(1.0,0.0,0.0,0.5), showPlot=true)

## Description
Function to process and plot a sand erosion case.
## Arguments
- img: image to extract pattern
- bgimg: image to subtract from
- figtitle: figure title
- ref_img: reference image (if "nothing", then no background image is used)
- ksize: size of the kernel (Kernel.gaussian)
- thrfun: threshold algorithm (default Otsu)
- nclose: number of times to apply dilatation followed by erosion (closing)
- col: color
- showPlot: if true returns a figure
returns plot with erosion pattern given two images
## Example
```jldoctest
julia> using VisualEFM

julia> fnames = "rpm" .* string.(collect(0:90:270)) .* ".jpg";

#(Not run)
julia> im = read_image.(fnames);

julia> erosion_one(im[3], im[1], figtitle="WT at 180 rpm", ref_img=im[1])
```
"""
function erosion_one(img::AbstractArray, bgimg::AbstractArray; figtitle=" ", ref_img=nothing, ksize= 3, thrfun = Otsu(),
                    nclose=1, col=RGBA(1.0,0.0,0.0,0.5), showPlot=true)

    img_blur = apply_gaussian(img, ksize=ksize)
    bgimg_blur = apply_gaussian(bgimg, ksize=ksize)

    img_erosion = getdiffpattern(img_blur, bgimg_blur, thrfun=thrfun, nclose=nclose)
    mask = Bool.(img_erosion)

    img_erosion = Float64.(img_erosion).*col

    if !isnothing(ref_img) # include reference image on the background
        ref_img = RGBA.(ref_img, 1.0)
        ref_img[mask] .= RGBA(0.0,0.0,0.0,0.0)
        img_erosion = ref_img + img_erosion
    end

    if showPlot
        fig = plot(img_erosion, axis=nothing, bordercolor="white")
        title!(string(figtitle))
        display(fig)
    end

    return [img_erosion, mask]
end

"""
    erosion_anim(sname::String, imgs::AbstractArray, bgimgs::AbstractArray; figtitle=" ", fps=1, ref_img=nothing, ksize= 3, thrfun = Otsu(), nclose=1, col=RGBA(1.0,0.0,0.0,0.5))

## Description                    
Function to create an animation of the erosion process.
## Arguments
- sname: name of the file to be saved (.gif)
- imgs: array of original images
- bgimg: array of images to subtract from
- figtitle: figure title
- fps: frames per second
- ref_img: reference image (if "nothing", then no background is used)
- ksize: size of the kernel (Kernel.gaussian)
- thrfun: threshold algorithm (default Otsu)
- nclose: number of times to apply dilatation followed by erosion (closing)
- col: color
saves gif animation
## Example
```jldoctest
julia> using VisualEFM

julia> fnames = "rpm" .* string.(collect(0:90:270)) .* ".jpg";

# (Not run)
julia> im = read_image.(fnames);

julia> erosion_anim("erosion_animation.gif", im, im[1], ref_img=im[1])
```
"""
function erosion_anim(sname::String, imgs::AbstractArray, bgimgs::AbstractArray; figtitle=" ",
                    fps=1, ref_img=nothing, ksize= 3, thrfun = Otsu(), 
                    nclose=1, col=RGBA(1.0,0.0,0.0,0.5))

    n = length(imgs)
    if length(figtitle) == 1 # same figtitle for everything
        figtitle = repeat([figtitle], n)
    end

    if eltype(bgimgs) <: AbstractArray
        if length(bgimgs) != length(imgs)
            throw(DimensionMismatch("bgimgs must be an array with length equals to one or with 
                                    the same length of imgs array"))
        end

        anim = @animate for i in 1:n
            erosion_one(imgs[i], bgimgs[i], figtitle=figtitle[i],
                        ref_img=ref_img, ksize=ksize, thrfun=thrfun,
                        nclose=nclose, col=col, showPlot=true)
        end
        
    else 
        anim = @animate for i in 1:n
            erosion_one(imgs[i], bgimgs; figtitle=figtitle[i],
                            ref_img=ref_img, ksize=ksize,thrfun=thrfun,
                            nclose=nclose, col=col, showPlot=true)
        end
    end

    gif(anim, sname, fps=fps)

end

"""
    erosion_colormap(imgseq::AbstractArray, U::AbstractVector; figtitle=" ", cb_title=" ", ref_img=nothing, ksize= 3, thrfun = Otsu(), nclose=1, col=cfd, showPlot=true)

## Description
Function to create heatmap from the erosion images.
## Arguments
- imgseq: array with images in sequence
- U: erosion reference (array 1D of velocities)
- cb_title = colobar title (default="")
- ref_img: reference image (if "nothing", then imgseq[1] is used)
- ksize: size of the kernel (Kernel.gaussian)
- thrfun: threshold algorithm (default Otsu)
- nclose: number of times to apply dilatation followed by erosion (closing)
- col: color
- alpha: opacity parameter
- showPlot: true to return a plot
returns a color map plot
## Example
```jldoctest
julia> using VisualEFM

julia> fnames = "rpm" .* string.(collect(0:90:270)) .* ".jpg";

# (Not run)
julia> im = read_image.(fnames);

julia> erosion_colormap(im, [90,180,270], figtitle="Color Map", cb_title="Grayscale", ref_img=im[1])
```

"""
function erosion_colormap(imgseq::AbstractArray, U::AbstractVector; figtitle=" ", cb_title=" ", 
                    ref_img=nothing, ksize= 3, thrfun = Otsu(), nclose=1, col=cfd, showPlot=true)

    n = length(imgseq) - 1
    U = float(U)
    if length(U) != n
        throw(DimensionMismatch("U length should a 1 be equal to the length of imgseq minus one"))
    end

    imgs_erosion =[]

    mapU = fill(0.0,size(imgseq[1]))
    mask = fill(false, size(imgseq[1]))

    for i in 1:n
        k = i + 1
        img_temp, mask_temp = erosion_one(imgseq[k], imgseq[i], figtitle = " ", ref_img=nothing,
                                ksize=ksize, thrfun=thrfun, nclose=nclose, showPlot=false)
        push!(imgs_erosion, img_temp)

        mask = mask .| mask_temp

        mask_temp[mapU .!= 0.0] .= false # ensures to remove intersections
        mapU = mapU + Float64.(mask_temp)*U[i]

    end

    id0 = mapU .== 0.0
    mapU[id0] .= NaN

    if showPlot
        if isnothing(ref_img)
            fig = heatmap(mapU[end:-1:1,:], color=col, title=string(figtitle), 
                            colorbar_title=string(cb_title), aspect_ratio=1, axis=nothing, 
                            bordercolor="white")
        else
            bg = copy(ref_img) # don't change original
            bg[mask] .= RGBA(0.0,0.0,0.0,0.0)
    	    fig = plot(bg)
            heatmap!(mapU, color=col, title=string(figtitle), colorbar_title=string(cb_title),
                    axis=nothing, bordercolor="white")
        end
        display(fig)
    end

    return [mapU, ref_img]
end
