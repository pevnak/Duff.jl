using Revise
using Duff, Flux, MLDataPattern, DataFrames, FileIO, ArgParse, Statistics
using Duff: onlinedaf

s = ArgParseSettings()
s.description = ""
@add_arg_table s begin
    ("--batchsize"; default=100;arg_type=Int);
    ("--fiterations"; default=100000;arg_type=Int);
    ("--eiterations"; default=10000;arg_type=Int);
    ("-k"; default=20;arg_type=Int);
    ("-l"; default=0;arg_type=Int);
    ("--warmup"; default=0;arg_type=Int);
end
settings = parse_args(ARGS, s; as_symbols=true)


#############################################################################
#			At first, we create a function which performs one iteration of the algorithms
#############################################################################
zeroitems!(x, mask::Vector{Int}) = x[setdiff(1:size(x,1),mask),:] .= 0
function onestep(mask, model, opt, dataprovider)
	x, y = getobs.(dataprovider())
	zeroitems!(x, mask)
	f = Flux.crossentropy(max.(softmax(model(x))),Flux.onehotbatch(y,1:2))
	Flux.Tracker.back!(f)
	opt()
	isnan(Flux.data(f)) && error("nan in the model")
	Flux.data(f)
end

loaddataset(f) = (load(f,"data"),load(f,"labels"))
X,Y =  loaddataset("/Users/tpevny/Work/Data/featureselection/madelon_train_nips_500.jld2")
dim = size(X,1)
p, nprobes, bs = 0.1, Int(1e5), 100
trndata,tstdata = splitobs(shuffleobs((X,Y)), 0.5)
model = Flux.Chain(Dense(dim,settings[:k],relu), [Dense(settings[:k],settings[:k],relu) for _ in 1:settings[:l]]..., Dense(settings[:k],2))
opt = Flux.ADAM(params(model))
daf = onlinedaf(dim, mask -> onestep(mask, model, opt, () -> randobs(trndata,bs)), p, nprobes)

function trainmodel!(model,idx,data)
	opt = Flux.ADAM(params(model))
	for x in data
		xx = getobs(x)
		onestep(model,opt,xx[1][idx,:],xx[2])
	end
end

evaluatemodel(m,idx,x,y) = mean(Flux.argmax(softmax(m(x[idx,:]))) .!= y)
function evaluatefmodel(m,idx,x,y) 
	x[setdiff(1:size(x,1),idx),:] .= 0
	mean(Flux.argmax(softmax(m(x))) .!= y)
end

#############################################################################
#		Evaluate the model by training the model on subset of features
#############################################################################
score = mscore(dafstats)
I = sortperm(score,rev=true)
data = RandomBatches(trndata,settings[:batchsize],settings[:eiterations])
df = [];
for i in 1:length(I)
	idx = I[1:i]
	model = Flux.Chain(Dense(i,dim,relu),Dense(dim,dim,relu),Dense(dim,4,relu),Dense(4,2))
	trainmodel!(model,idx,data)
	e = evaluatemodel(model,idx,getobs(tstdata)...)
	ef = evaluatefmodel(fmodel,idx,getobs(tstdata)...)
	push!(df,DataFrame(features = i, feature = I[i], score = score[i], error = e, ferror = ef))
end

display(vcat(df...))

