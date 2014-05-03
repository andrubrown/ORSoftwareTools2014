# In this step we restructure the code to re-use a single
# vector for storing the current gradient, instead of
# allocating a new vector on each iteration of the algorithm.

# In Julia, the function A_mul_B!(y,Q,x) sets y <- Q*x

function genF(Q)
    function f_and_fgrad(x,grad_out)
        A_mul_B!(grad_out,Q,x)
        return (1/2)*dot(x,grad_out)
    end
end

function gradDescent(f_and_fgrad, startX)

    const stepsize = 1.0
    const sigma = 0.1

    x = copy(startX)
    grad = similar(x)
    gradnew = similar(x)
    fval = f_and_fgrad(x,grad)::Float64
    fvalnew = 0.0
    k = 0

    gradnorm = norm(grad)
    niter = 1
    while gradnorm > 1e-4
        # step in the direction of -grad using the Armijo rule
        k = 0
        BLAS.axpy!(-stepsize/2^k,grad,x)
        fvalnew = f_and_fgrad(x, gradnew)::Float64
        while fval - fvalnew < -sigma*(stepsize/2^k)*dot(grad,grad)
            k += 1
            BLAS.axpy!(stepsize/2^(k-1)-stepsize/2^k,grad,x)
            fvalnew = f_and_fgrad(x, gradnew)::Float64
        end
        if niter % 5000 == 0
            println("Iter: $niter Obj. val: $fval Gradient norm: $gradnorm")
        end
        fval = fvalnew
        grad, gradnew = gradnew, grad
        
        gradnorm = norm(grad)
        niter += 1
    end
    println("Converged")
    #print("Solution: ");show(x);println()

end

dim = 100
srand(10) # fix random seed
R = rand(dim,dim)
f_and_fgrad = genF(R'*R)

gradDescent(f_and_fgrad, ones(dim)) # run once to exclude compilation time
@profile @time gradDescent(f_and_fgrad, ones(dim))
Profile.print(format=:flat)

