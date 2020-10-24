"""
    smoke_anim(sname::String, imgs::AbstractArray, bgimg::Union{AbstractArray,Nothing}; 
                figtitle=" ", cb_title=" ", fps=10, ksize= 3, inverse=false,
                col=:rainbow, alpha=1.0, clim=(-Inf,Inf))

## Description
Function to create an animation heatmap
## Arguments
- sname: name of the file to be saved (.gif)
- imgs: array of original images
- bgimg: background image
- figtitle: figure title
- fps: frames per second
- ksize: size of the kernel (Kernel.gaussian)
- inverse: order of subtraction (background subtraction)
- col: color palette
- cb_title: colorbar title
- alpha: opacity
- clim: fixed limits for the heatmap
saves a gif animation
## Example
```jldoctest
julia> using VisualEFM

julia> fnames = "frame" .* string.(collect(1:100)) .* ".jpg";

# (Not run)
julia> im = read_image.(fnames);

julia> smoke_anim("anim_smoke.gif", im, nothing, figtitle="Animation", cb_title="Grayscale", fps=20)
```
"""
function smoke_anim(sname::String, imgs::AbstractArray, bgimg::Union{AbstractArray,Nothing}; 
                    figtitle=" ", cb_title=" ", fps=10, ksize= 3, inverse=false,
                    col=:rainbow, alpha=1.0, clim=(-Inf,Inf))

    n = length(imgs)

    if isnothing(bgimg)
        anim = @animate for i in 1:n
            img_gs = gauss_grayscale(imgs[i], ksize=ksize)
            img_gs = Float64.(img_gs)
            plot(imgs[i], axis=nothing, bordercolor="white")
            heatmap!(img_gs, color=col, colorbar_title=string(cb_title), clim=clim, alpha=alpha)
            title!(string(figtitle))
        end

    else
        bgimg_gs = gauss_grayscale(bgimg, ksize=ksize)
        anim = @animate for i in 1:n
            img_gs = gauss_grayscale(imgs[i], ksize=ksize)
            img_diff = backsubtraction(img_gs,bgimg_gs, inverse=inverse)
            img_diff = Float64.(img_diff)
            plot(imgs[i], axis=nothing, bordercolor="white")
            heatmap!(img_diff, color=col, colorbar_title=string(cb_title), clim=clim, alpha=alpha)
            title!(string(figtitle))
        end
    end     

    gif(anim, sname, fps=fps)

end


"""
    smoke_statsmap(statfun, imgs::AbstractArray, bgimg::Union{AbstractArray,Nothing}; 
                    figtitle=" ", cb_title=" ", ksize = 3, inverse = false, 
                    col=:rainbow, alpha=1.0, clim=(-Inf,Inf), showPlot=true)

## Description
Plot statistics of an array of images.
## Arguments
- statfun: function to be applied to an array of images (works with mean and std)
- imgs: array of original images
- bgimg: background image
- figtitle: figure title
- ksize: size of the kernel (Kernel.gaussian)
- inverse: order of subtraction (background subtraction)
- col: color palette
- cb_title: colorbar title
- alpha: opacity
- clim: fixed limits for the heatmap
- showPlot: true to return a plot
returns a plot
## Example
```jldoctest
julia> using VisualEFM

julia> fnames = "frame" .* string.(collect(1:100)) .* ".jpg";

# (Not run)
julia> im = read_image.(fnames);

julia> smoke_statsmap(Statistics.mean, im, nothing, cb_title="Mean Grayscale Values")
```
"""
function smoke_statsmap(statfun, imgs::AbstractArray, bgimg::Union{AbstractArray,Nothing}; 
                        figtitle=" ", cb_title=" ", ksize = 3, inverse = false, 
                        col=:rainbow, alpha=1.0, clim=(-Inf,Inf), showPlot=true)

    imgs_gray = gauss_grayscale.(imgs, ksize=ksize)

    if !isnothing(bgimg)
        bgim_gray = gauss_grayscale(bgimg, ksize=ksize)
        imgs_gray = [backsubtraction(i,bgim_gray,inverse=inverse) for i in  imgs_gray]
    end

    imgs_array = [Float64.(j) for j in imgs_gray]

    res = statfun(imgs_array)

    if showPlot
        fig = heatmap(res, color=col, alpha=alpha, clim=clim, axis=nothing,
               	     title=string(figtitle), bordercolor="white", colorbar_title=string(cb_title))
        display(fig)
    end
    
    return [imgs_array, res]
end 
