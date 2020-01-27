module Duff
using Statistics, StatsBase, Printf, HypothesisTests

BoolVector = Union{BitArray{1}, Array{Bool,1}}


include("singlestats.jl")
include("dafstats.jl")
include("online.jl")

export UnequalVarianceTTest, Daf
end # module
