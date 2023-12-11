using Labelyst
using Test
using DataFrames

@testset "Assertion Tests" begin
    # Test make_outfile
    testfile = "/not/existing/dir"
    @test_throws AssertionError Labelyst.make_outfile(testfile)
end

@testset "make_outfile" begin
    # Test make_outfile
    testfile = "testdir"
    @test Labelyst.make_outfile(testfile) == "testdir.typ"
    rm("testdir.typ")
end
