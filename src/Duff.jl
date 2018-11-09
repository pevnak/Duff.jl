module Duff
using Statistics, StatsBase, Printf, HypothesisTests
include("singlestats.jl")
include("dafstats.jl")
include("online.jl")

export UnequalVarianceTTest, Daf
end # module
