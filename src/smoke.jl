# Auxiliary function to apply Gaussian filter and convert to grayscale
# ---------------------------------------------------------------------------------------------
# img: image in Normed RGB
# ksize: size of the kernel (Kernel.gaussian)
# ---------------------------------------------------------------------------------------------
# returns the image filtered and in grayscale
# ---------------------------------------------------------------------------------------------
function imgGaussGrayscale(img::Array{RGB{Normed{UInt8,8}},2}; ksize=1)
    
    img_blur = applyGaussian(img, ksize=ksize)
    img_gs = Gray.(img_blur)

    return img_gs

end
            
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
function animSmoke(sname::String, imgs::Array{Array{RGB{Normed{UInt8,8}},2},1},
                    bgimg::Union{Array{RGB{Normed{UInt8,8}},2},Nothing}; 
                    figtitle=" ", cb_title=" ", fps=10, ksize= 3, inverse=false,
                    col=:rainbow, alpha=1.0, clim=(-Inf,Inf))

    n = length(imgs)

    if isnothing(bgimg)
        anim = @animate for i in 1:n
            img_gs = imgGaussGrayscale(imgs[i], ksize=ksize)
            img_gs = Float64.(img_gs)
            plot(imgs[i], axis=nothing, bordercolor="white")
            heatmap!(img_gs, color=col, colorbar_title=cb_title, alpha=alpha)
            title!(figtitle)
        end

    else
        bgimg_gs = imgGaussGrayscale(bgimg, ksize=ksize)
        anim = @animate for i in 1:n
            img_gs = imgGaussGrayscale(imgs[i], ksize=ksize)
            img_diff = backSubtraction(img_gs,bgimg_gs, inverse=inverse)
            img_diff = Float64.(img_diff)
            plot(imgs[i], axis=nothing, bordercolor="white")
            heatmap!(img_diff, color=col, colorbar_title=cb_title, alpha=alpha)
            title!(figtitle)
        end
    end     

    gif(anim, sname, fps=fps)

end

# Statistics of an array of images
# ---------------------------------------------------------------------------------------------
# statFun: function to be applied to an array of images (works with mean and std)
# imgs: array of original images
# bgimg: background image
# figtitle: figure title
# ksize: size of the kernel (Kernel.gaussian)
# inverse: order of subtraction (background subtraction)
# col: color palette
# cb_title: colorbar title
# alpha: opacity
# clim: fixed limits for the heatmap
# ---------------------------------------------------------------------------------------------
# returns plot
# ---------------------------------------------------------------------------------------------
function statSmokeMap(statFun, imgs::Array{Array{RGB{Normed{UInt8,8}},2},1},
                        bgimg::Union{Array{RGB{Normed{UInt8,8}},2},Nothing}; 
                        figtitle=" ", cb_title=" ", ksize = 3, inverse = false, 
                        col=:rainbow, alpha=1.0, clim=(-Inf,Inf))

    imgs_gray = imgGaussGrayscale.(imgs, ksize=ksize)

    if !isnothing(bgimg)
        bgim_gray = imgGaussGrayscale(bgimg, ksize=ksize)
        imgs_gray = [backSubtraction(i,bgim_gray,inverse=inverse) for i in  imgs_gray]
    end

    imgs_array = [Float64.(j) for j in imgs_gray]

    res = statFun(imgs_array)

    fig = heatmap(res, color=col, alpha=alpha, clim=clim, axis=nothing,
           	     title=figtitle, bordercolor="white", colorbar_title=cb_title)
    
    display(fig)

end 
