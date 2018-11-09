using SparseArrays, Test

@testset "testing multiplication of sparse matrix with a mask on rows" begin
	A = [1 2 3; 0 1 0]
	B = sparse([0 1 2; 1 0 1; 1 0 0])
	@test mul(A, B) == A*B
	@test mul(A, B) == mul(A,B, [1,2,3])
	Bz = sparse([0 0 0; 1 0 1; 1 0 0])
	@test mul(A, Bz) == mul(A,B, [2,3])
	Bz = sparse([0 1 2; 0 0 0; 1 0 0])
	@test mul(A, Bz) == mul(A,B, [1,3])
	Bz = sparse([0 1 2; 1 0 1; 0 0 0])
	@test mul(A, Bz) == mul(A,B, [1,2])
end