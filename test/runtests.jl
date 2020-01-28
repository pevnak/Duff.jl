using Duff, Test, Statistics, Random

@testset "testing daf update" begin
	Random.seed!(1234)
	daf = Daf(5)
	Duff.meanscore(daf)
	Duff.update!(daf, 2, Duff.getmask(daf, 0.1))
	Duff.update!(daf, 1, Duff.getmask(daf, 0.2))
	Duff.update!(daf, 0, Duff.getmask(daf, 0.3))
	Duff.update!(daf, 3, Duff.getmask(daf, 0.4))
	Duff.update!(daf, 4, Duff.getmask(daf, 0.5))

	present_mean = mean(daf.present)
	present_var = var(daf.present)
	present_std = std(daf.present)

	@test isnan.(present_mean) == isnan.([NaN, NaN, 4., 7/3, 4/3])
	@test filter(!isnan, present_mean) ≈ [4., 7/3, 4/3]

	@test isnan.(present_var) == isnan.([NaN , NaN, 0., 26/9, 14/9])
	@test filter(!isnan, present_var) ≈ [0., 26/9, 14/9]

	@test isnan.(present_std) == isnan.([NaN , NaN, 0., 26/9, 14/9].^0.5)
	@test filter(!isnan, present_std) ≈ [0., 26/9, 14/9].^0.5

	absent_mean = mean(daf.absent)
	absent_var = var(daf.absent)
	absent_std = std(daf.absent)

	@test isnan.(absent_mean) == isnan.([2., 2., 1.5, 1.5, 3.])
	@test filter(!isnan, absent_mean) ≈ [2., 2., 1.5, 1.5, 3.]

	@test isnan.(absent_var) == isnan.([2., 2., 5/4, 1/4, 1.])
	@test filter(!isnan, absent_var) ≈ [2., 2., 5/4, 1/4, 1.]

	@test isnan.(absent_std) == isnan.([2., 2., 5/4, 1/4, 1.].^0.5)
	@test filter(!isnan, absent_std) ≈ [2., 2., 5/4, 1/4, 1.].^0.5
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

