# Function to create an animation heatmap
# ---------------------------------------------------------------------------------------------
# sname: name of the file to be saved (.gif)
# imgs: array of original images
# bgimg: background image
# figtitle: figure title
# fps: frames per second
# ksize: size of the kernel (Kernel.gaussian)
# inverse: order of subtraction (background subtraction)
# col: color palette
# cb_title: colorbar title
# alpha: opacity
# clim: fixed limits for the heatmap
# ---------------------------------------------------------------------------------------------
# save a gif animation
# ---------------------------------------------------------------------------------------------
function anim_smoke(sname::String, imgs::Array{Array{RGB{Normed{UInt8,8}},2},1},
                    bgimg::Union{Array{RGB{Normed{UInt8,8}},2},Nothing}; 
                    figtitle=" ", cb_title=" ", fps=10, ksize= 3, inverse=false,
                    col=:rainbow, alpha=1.0, clim=(-Inf,Inf))

    n = length(imgs)

    if isnothing(bgimg)
        anim = @animate for i in 1:n
            img_gs = gauss_grayscale(imgs[i], ksize=ksize)
            img_gs = Float64.(img_gs)
            plot(imgs[i], axis=nothing, bordercolor="white")
            heatmap!(img_gs, color=col, colorbar_title=cb_title, clim=clim, alpha=alpha)
            title!(figtitle)
        end

    else
        bgimg_gs = gauss_grayscale(bgimg, ksize=ksize)
        anim = @animate for i in 1:n
            img_gs = gauss_grayscale(imgs[i], ksize=ksize)
            img_diff = backsubtraction(img_gs,bgimg_gs, inverse=inverse)
            img_diff = Float64.(img_diff)
            plot(imgs[i], axis=nothing, bordercolor="white")
            heatmap!(img_diff, color=col, colorbar_title=cb_title, clim=clim, alpha=alpha)
            title!(figtitle)
        end
    end     

    gif(anim, sname, fps=fps)

end

# Statistics of an array of images
# ---------------------------------------------------------------------------------------------
# statfun: function to be applied to an array of images (works with mean and std)
# imgs: array of original images
# bgimg: background image
# figtitle: figure title
# ksize: size of the kernel (Kernel.gaussian)
# inverse: order of subtraction (background subtraction)
# col: color palette
# cb_title: colorbar title
# alpha: opacity
# clim: fixed limits for the heatmap
# showPlot: true to return a plot
# ---------------------------------------------------------------------------------------------
# returns plot
# ---------------------------------------------------------------------------------------------
function stats_smokemap(statfun, imgs::Array{Array{RGB{Normed{UInt8,8}},2},1},
                        bgimg::Union{Array{RGB{Normed{UInt8,8}},2},Nothing}; 
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
               	     title=figtitle, bordercolor="white", colorbar_title=cb_title)
        display(fig)
    end
    
    return [imgs_array, res]
end 
