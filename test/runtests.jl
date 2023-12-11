using Labelyst
using Test
using DataFrames

@testset "Assertion Tests" begin
    # Test make_outfile
    testfile = "/not/existing/dir"
    df = DataFrame(ID = ["p1"], label = ["lab1"])
    @test_throws AssertionError Labelyst.make_outfile(testfile)
    @test_throws AssertionError labelyst(df, testfile, "z6", [3, 2])
end

@testset "make_outfile" begin
    # Test make_outfile
    testfile = "testdir"
    @test Labelyst.make_outfile(testfile) == "testdir.typ"
    rm("testdir.typ")
end

