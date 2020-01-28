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

Base.length(s::SingleStats) = length(s.s)

SingleStats(d::Int) = SingleStats(zeros(d),zeros(d),zeros(Int,d))


"""
		update!(s::SingleStats,f,mask,negate::Bool)
		update!(s::SingleStats,f,idx,negate::Bool)

		updates the stats with a value `f` contributing to samples in from `idxs` or `mask`. If `negate` is true, `mask`
		is negated / `idxs` are set to complement of `idxs`
"""
update!(s::SingleStats, f, idxs::Vector{Int}, negate::Bool) = (negate) ? update!(s::SingleStats,f,setdiff(1:length(s.n),idxs)) : update!(s::SingleStats,f,idxs)
update!(s::SingleStats, idxs::Vector{Int}, f, negate::Bool) = (negate) ? update!(s::SingleStats,f,setdiff(1:length(s.n),idxs)) : update!(s::SingleStats,f,idxs)
update!(s::SingleStats, f, mask::BoolVector, negate::Bool) = (negate) ? update!(s::SingleStats, f, .!mask) : update!(s::SingleStats, f, mask)
update!(s::SingleStats, mask::BoolVector, f, negate::Bool) = (negate) ? update!(s::SingleStats, f, .!mask) : update!(s::SingleStats, f, mask)
update!(s::SingleStats, f, mask::BoolVector, negate::Bool, valid_indexes::Vector{Int}) = (negate) ? update!(s::SingleStats, f, .!mask, valid_indexes) : update!(s::SingleStats, f, mask, valid_indexes)
update!(s::SingleStats, mask::BoolVector, f, negate::Bool, valid_indexes::Vector{Int}) = (negate) ? update!(s::SingleStats, f, .!mask, valid_indexes) : update!(s::SingleStats, f, mask, valid_indexes)

update!(s::SingleStats, f, mask::BoolVector, negate::Bool, participate::Vector{Bool}) = (negate) ? update!(s::SingleStats, f, .!mask, participate) : update!(s::SingleStats, f, mask, participate)
update!(s::SingleStats, mask::BoolVector, f, negate::Bool, participate::Vector{Bool}) = (negate) ? update!(s::SingleStats, f, .!mask, participate) : update!(s::SingleStats, f, mask, participate)

update!(s::SingleStats, f, mask::BoolVector, negate::Bool, participate::Vector{Bool}, cluster_index) = (negate) ? update!(s::SingleStats, f, .!mask, participate, cluster_index) : update!(s::SingleStats, f, mask, participate, cluster_index)
update!(s::SingleStats, mask::BoolVector, f, negate::Bool, participate::Vector{Bool}, cluster_index) = (negate) ? update!(s::SingleStats, f, .!mask, participate, cluster_index) : update!(s::SingleStats, f, mask, participate, cluster_index)

function update!(s::SingleStats, f, mask)
	s.s[mask] .+= f
	s.q[mask] .+= f^2
	s.n[mask] .+= 1
end

function update!(s::SingleStats, f, mask::Int)
	s.s[mask] += f
	s.q[mask] += f^2
	s.n[mask] += 1
end

function update!(s::SingleStats, f, mask, valid_indexes::Vector{Int})
	valid_indexes = valid_indexes[mask]
	s.s[valid_indexes] .+= f
	s.q[valid_indexes] .+= f^2
	s.n[valid_indexes] .+= 1
end

function update!(s::SingleStats, f, mask, participate::Vector{Bool})
	for i in findall(participate .& mask)
		s.s[i] += f
		s.q[i] += f^2
		s.n[i] += 1
	end
end

function update!(s::SingleStats, f, mask, participate::Vector{Bool}, cluster_index)
	for j in findall(participate .& mask)
		i = cluster_index[j]
		s.s[i] += f
		s.q[i] += f^2
		s.n[i] += 1
	end
end

Statistics.mean(s::SingleStats) = s.s ./ s.n
Statistics.std(s::SingleStats) = @. sqrt(s.q / s.n - (s.s / s.n)^2)
Statistics.var(s::SingleStats) = @. s.q / s.n - (s.s / s.n)^2
