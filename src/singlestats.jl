"""
		SingleStats(d::Int)
		SingleStats(s::Vector{Float64}, q::Vector{Float64}, n::Vector{Int})

		Initiates statistics for a DAF with a tracking only single variable
		`s` holds a the sum of contributions of each sample
		`q` holds a the sum of squares of contributions of each sample
		`n` holds the number of times each sample is updated
"""
mutable struct SingleStats
	s::Vector{Float64}		# sum of the contributions
	q::Vector{Float64}		#	sum of squares of the contribution
	n::Vector{Int}				#	number of times the given element was improved
end

SingleStats(d::Int) = SingleStats(zeros(d),zeros(d),zeros(Int,d))


"""
		update!(s::SingleStats,f,mask,negate::Bool)
		update!(s::SingleStats,f,idx,negate::Bool)
		
		updates the stats with a value `f` contributing to samples in from `idxs` or `mask`. If `negate` is true, `mask`
		is negated / `idxs` are set to complement of `idxs`
"""
update!(s::SingleStats, f, mask::BitVector, negate::Bool) = (negate) ? update!(s::SingleStats,f,.!mask) : update!(s::SingleStats,f,mask)
update!(s::SingleStats, f, idxs::Vector{Int}, negate::Bool) = (negate) ? update!(s::SingleStats,f,setdiff(1:length(s.n),idxs)) : update!(s::SingleStats,f,idxs)

function update!(s::SingleStats, f, mask)
	s.s[mask] .+= f
	s.q[mask] .+= f^2
	s.n[mask] .+= 1
end

Statistics.mean(s::SingleStats) = s.s ./ s.n
Statistics.std(s::SingleStats) = sqrt.(s.q ./ s.n .- (s.s ./ s.n).^2)
Statistics.var(s::SingleStats) = s.q ./ s.n .- (s.s ./ s.n).^2