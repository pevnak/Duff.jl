using Duff, Test, Statistics, StableRNGs

rng = StableRNG(0)

@testset "testing daf update" begin
	daf = Daf(5)
	Duff.meanscore(daf)
	Duff.update!(daf, 2, Duff.getmask(rng, daf, 0.1))
	Duff.update!(daf, 1, Duff.getmask(rng, daf, 0.2))
	Duff.update!(daf, 0, Duff.getmask(rng, daf, 0.3))
	Duff.update!(daf, 3, Duff.getmask(rng, daf, 0.4))
	Duff.update!(daf, 4, Duff.getmask(rng, daf, 0.5))

	present_mean = mean(daf.present)
	present_var = var(daf.present)
	present_std = std(daf.present)

	# isapprox with kwarg nans=true is equal to comparing this
	# @test isnan.(present_mean) == isnan.(expected_mean)
	# @test filter(!isnan, present_mean) ≈ filter(!isnan, expected_mean)
	@test present_mean ≈ [NaN, 8/3, 0., 0., 7/2] nans=true
	@test present_var ≈ [NaN, 14/9, 0., 0., 1/4] nans=true
	@test present_std ≈ .√([NaN, 14/9, 0., 0., 1/4]) nans=true

	absent_mean = mean(daf.absent)
	absent_var = var(daf.absent)
	absent_std = std(daf.absent)

	@test absent_mean ≈ [2., 1., 5/2, 5/2, 1.] nans=true
	@test absent_var ≈ [2., 1., 5/4, 5/4, 2/3] nans=true
	@test absent_std ≈ .√([2., 1., 5/4, 5/4, 2/3]) nans=true
end


@testset "testing daf update" begin
	daf = Daf(5)
	Duff.update!(daf, 2, [true, true, true, false, false], [true, false, true, false, true])
	@test daf.present.n ≈ [1, 0, 1, 0, 0]
	@test daf.present.s ≈ [2, 0, 2, 0, 0]
	@test daf.present.q ≈ [4, 0, 4, 0, 0]

	@test daf.absent.n ≈ [0, 0, 0, 0, 1]
	@test daf.absent.s ≈ [0, 0, 0, 0, 2]
	@test daf.absent.q ≈ [0, 0, 0, 0, 4]
end

@testset "testing daf update with cluster indices" begin
	daf = Daf(3)
	Duff.update!(daf, 2, [true, true, true, false, false], [true, false, true, false, true], [1, 2, 3, 2, 1])
	@test daf.present.n ≈ [1, 0, 1]
	@test daf.present.s ≈ [2, 0, 2]
	@test daf.present.q ≈ [4, 0, 4]

	@test daf.absent.n ≈ [1, 0, 0]
	@test daf.absent.s ≈ [2, 0, 0]
	@test daf.absent.q ≈ [4, 0, 0]
end

@testset "testing update daf by a specific index" begin
	daf = Daf(3)
	Duff.update!(daf, 2, true, 1)
	Duff.update!(daf, 3, false, 2)
	@test daf.present.n ≈ [1, 0, 0]
	@test daf.present.s ≈ [2, 0, 0]
	@test daf.present.q ≈ [4, 0, 0]

	@test daf.absent.n ≈ [0, 1, 0]
	@test daf.absent.s ≈ [0, 3, 0]
	@test daf.absent.q ≈ [0, 9, 0]
end
