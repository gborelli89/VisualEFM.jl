using VisualEFM
using Test

@testset "VisualEFM.jl" begin

    f = ["rpm000.jpg", "rpm150.jpg", "rpm175.jpg", "rpm225.jpg"]
    im_original = readImage.(f, roi=[500:2050,:])
    mask = binarizeMask!("teste_mascara.png")
    im = readImage.(f, roi=[500:2050,:], mask=mask)
    
    @testset "Common functions" begin
        @test_throws MethodError readImage(f)
        @test length(im_original) == 4
        @test size(im_original[1]) == (1551, 1456)
        @test typeof(mask) == BitArray{2}
        @test mask[1:10,1:10] == fill(false, (10,10))
        @test size(im[1]) == (1551, 1456)
        @test length(im) == 4
        @test_throws MethodError VisualEFM.backSubtraction(im[2], im[1])
        @test_throws MethodError VisualEFM.getDiffPattern(im[2], im[1])
    end

    _,mo = erosionOne(im_original[3], im_original[1], showPlot=false)
    _,m = erosionOne(im[3], im[1], showPlot=false)
    a,_ = erosionColorMap(im_original, [150,175,225], showPlot=false)
    b,_ = erosionColorMap(im, [150,175,225], showPlot=false)

    @testset "Sand erosion" begin
        @test count(mo) > 231400 & count(mo) < 231800
        @test count(m) > 102620 & count(m) < 102820 
        @test_throws DimensionMismatch animErosion("test.gif",im_original[2:4], im_original[1:2])  
        @test_throws DimensionMismatch erosionColorMap(im_original, [150,175])
        @test_throws DimensionMismatch erosionColorMap(im, [150,175])
        @test maximum(x->isnan(x) ? -Inf : x, a) == 225
        @test maximum(x->isnan(x) ? -Inf : x, b) == 225
        @test minimum(x->isnan(x) ? Inf : x, a) == 150      
        @test minimum(x->isnan(x) ? Inf : x, b) == 150
    end
end
