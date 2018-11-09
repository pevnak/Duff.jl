
onlinedaf(d::Int, onestep, p, n, warmup::Int = 0, breakpoints = 100) = onlinedaf!(Daf(d), onestep, p, n, warmup = warmup, breakpoints = breakpoints)

"""
		onlinedaf!(daf, onestep, p, n, warmup::Int = 0)

		opdate daf `n`-times with mask containing `p` fraction of features
		`onestep` is a function `(mask) -> f` which accepts mask as a feature
		and return value of the criterion used in daf
"""
function onlinedaf!(daf, onestep, p, n; warmup::Int = 0, breakpoints = 100, cb = () -> (), logfile = nothing)
	meanf, start_t = 0.0, time_ns()
	logio = (logfile != nothing) ? open(logfile, "w") : nothing
	for i in 1:n
		mask = getmask(daf, p)
		f = onestep(mask) 
		logio != nothing && println(logio, i," ",f ," ", join(mask, " "))
		meanf += f 
		i > warmup && update!(daf,f,mask)
		if mod(i, breakpoints) == 0
			@printf("%d: mean error %g (%.2fs)\n", i, meanf/breakpoints,(time_ns() - start_t)/(1e9*breakpoints))
			# gc();gc();gc();gc();gc();gc();
	  #   run(pipeline(`/bin/cat /proc/meminfo`, `/bin/grep MemFree`))
			meanf, start_t = 0.0, time_ns()
			cb()
		end
	end
	logio != nothing && close(logio)
	daf
end