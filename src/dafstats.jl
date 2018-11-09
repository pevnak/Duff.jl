mutable struct Daf
	present::SingleStats
	absent::SingleStats
	d::Int
end

Daf(d::Int) = Daf(SingleStats(d),SingleStats(d),d);

"""
		function update!(s::Daf,f,mask) 

		updates DAF statistics assuming that mask identifies which 
		samples are present
"""	
function update!(s::Daf,f,mask) 
	update!(s.present,f,mask,false)
	update!(s.absent,f,mask,true)
end


"""
	getmask(d::Daf,p)

	create mask with `p` fraction of samples present
"""
getmask(d::Daf,p) = sample(1:d.d,Int(round(p*d.d)),replace = false)


"""
		meanscore(d::Daf)

		return the basic DAf score --- difference of means when features is present and absent
"""
meanscore(d::Daf) = mean(d.absent) - mean(d.present)


"""
		meanscore(d::Daf)

		return the basic DAf score --- difference of means when features is present and absent
"""
function HypothesisTests.UnequalVarianceTTest(d::Daf)
	meanx, varx, nx = mean(d.present), var(d.present), d.present.n
	meany, vary, ny = mean(d.absent), var(d.absent), d.absent.n
	[HypothesisTests.pvalue(UnequalVarianceTTest(meanx[i], varx[i], nx[i], meany[i], vary[i], ny[i])) for i in 1:length(nx)]
end

function Base.show(io::IO, d::Daf)
	s = meanscore(d)
	p = UnequalVarianceTTest(d)
	println("difference   p-value")
	for i in 1:min(20,length(s))
		println(@sprintf("%+.6f  %.6f",s[i], p[i]))
	end
end