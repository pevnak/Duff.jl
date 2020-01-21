using Revise
using Duff, Flux, MLDataPattern, DataFrames, FileIO, ArgParse, Statistics
using Duff: onlinedaf, meanscore

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
function onestep(mask, model, opt, dataprovider, ps)
	x, y = getobs.(dataprovider())
	zeroitems!(x, mask)
	f = Flux.crossentropy(max.(softmax(model(x))),Flux.onehotbatch(y,1:2))
	Flux.Optimise.update!(opt, ps, gradient(() -> f, ps))
	isnan(f) && error("nan in the model")
	f
end

X = readlines("example/madelon_train.data") .|> (x->(x |> split .|> x->parse(Int, x))) |> x->hcat(x...)
Y = readlines("example/madelon_train.labels") .|> x->parse(Int, x)
Y[Y.==-1] .= 2
dim = size(X,1)
p, nprobes, bs = 0.1, Int(1e5), 100
trndata,tstdata = splitobs(shuffleobs((X,Y)), 0.5)
model = Flux.Chain(Dense(dim,settings[:k],relu), [Dense(settings[:k],settings[:k],relu) for _ in 1:settings[:l]]..., Dense(settings[:k],2))
opt = Flux.ADAM()
ps = params(model)
daf = onlinedaf(dim, mask -> onestep(mask, model, opt, () -> randobs(trndata,bs), ps), p, nprobes)

score = meanscore(daf)
