mutable struct Daf
	present::SingleStats
	absent::SingleStats
	d::Int
end

Daf(d::Int) = Daf(SingleStats(d),SingleStats(d),d);

Base.length(daf::Daf) = length(daf.present)

"""
		function update!(s::Daf,f,mask)

		updates DAF statistics assuming that mask identifies which
		samples are present
"""

function update!(s::Daf, f, present::Bool, i::Int) 
	if present
		update!(s.present, f, i)
	else
		update!(s.absent, f, i)
	end
end

function update!(s::Daf, f, mask, valid_indices) 
	update!(s.present, f, mask, false, valid_indices)
	update!(s.absent, f, mask, true, valid_indices)
end

function update!(s::Daf, f, mask) 
	update!(s.present, f, mask, false)
	update!(s.absent, f, mask, true)
end

function update!(s::Daf, f, mask, valid_indices, cluster_index) 
	update!(s.present, f, mask, false, valid_indices, cluster_index)
	update!(s.absent, f, mask, true, valid_indices, cluster_index)
end


"""
	getmask(d::Daf,p)

	create mask with `p` fraction of samples present
"""
getmask(d::Daf,p::Real) = getmask(d, round(Int, p*d.d))
getmask(d::Daf,p::Int) = sample(1:d.d, p, replace = false)


"""
		meanscore(d::Daf)

		return the basic DAf score --- difference of means when features is present and absent
"""
meanscore(d::Daf) = mean(d.present) - mean(d.absent)


"""
		meanscore(d::Daf)

		return the basic DAf score --- difference of means when features is present and absent
"""
function HypothesisTests.UnequalVarianceTTest(d::Daf, μ0 = 0)
	meanx, varx, nx = mean(d.present), var(d.present), d.present.n
	meany, vary, ny = mean(d.absent), var(d.absent), d.absent.n
	xbar = meanx .- meany
	stderr = @. sqrt(max(1e-12, varx / nx + vary / ny))
	stderr = @. sqrt(max(1e-12, varx / nx + vary / ny))
	t = @. (xbar - μ0) / stderr
	df = @. (varx / nx + vary / ny)^2 / ((varx / nx)^2 / (nx - 1) + (vary / ny)^2 / (ny - 1))
	[df[i] > 0 ? HypothesisTests.pvalue(UnequalVarianceTTest(nx[i], ny[i], xbar[i], df[i], stderr[i], t[i], μ0)) : df[i] for i in 1:length(nx)]
end

function Base.show(io::IO, d::Daf)
	s = meanscore(d)
	try
		p = UnequalVarianceTTest(d)
		show(io, "difference   p-value")
		for i in 1:min(20,length(s))
			show(io, @sprintf("%+.6f  %.6f",s[i], p[i]))
		end
	catch ArgumentError
 		show(io, "P value test fails.")
	end
end
