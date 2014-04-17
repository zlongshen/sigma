program poisson

use sigma
use fem
use omp_lib

implicit none

    ! variables for constructing the computational mesh
    character(len=64) :: filename
    class(graph), pointer :: g
    real(dp), allocatable :: x(:,:)
    integer, allocatable :: bnd(:), ele(:,:), mask(:)

    ! variables for the stiffness and mass matrices
    type(sparse_matrix) :: A, B

    ! variables for solving the linear system
    class(linear_solver), pointer :: solver
    real(dp), allocatable :: u(:), f(:), r(:), z(:), p(:)

    ! other variables
    integer :: nn, ne, n, next
    ! integer, allocatable :: nbrs(:)


!--------------------------------------------------------------------------!
! Read in the triangular mesh and assemble the matrices                    !
!--------------------------------------------------------------------------!
    call get_environment_variable('SIGMA',filename)
    filename = trim(filename)//'/examples/meshes/circle.1'
    call read_triangle_mesh(g,x,bnd,ele,filename)

    nn = g%n
    ne = g%ne

    allocate(mask(sum(bnd)))
    next = 0
    do n=1,nn
        if (bnd(n)==1) then
            next = next+1
            mask(next) = n
        endif
    enddo

    call A%init(nn,nn,'row',g)
    call B%init(nn,nn,'row',g)


!--------------------------------------------------------------------------!
! Fill in the stiffness and mass matrices                                  !
!--------------------------------------------------------------------------!
    call laplacian2d(A,x,ele)
    call mass2d(B,x,ele)

    do n=1,size(mask)
        call A%add_value(mask(n),mask(n),1.0d8)
    enddo


!--------------------------------------------------------------------------!
! Allocate vectors for the RHS & solution                                  !
!--------------------------------------------------------------------------!
    allocate(u(nn),f(nn),z(nn),r(nn),p(nn))

    f = 1.0_dp
    u = 0.0_dp
    call B%matvec(f,u)
    f = u
    u = 0.0_dp


!--------------------------------------------------------------------------!
! Solve the linear system                                                  !
!--------------------------------------------------------------------------!
    solver => cg(nn,1.0d-12)
    call solver%init(A)

    call solver%solve(A,u,f)
!    print *, 'CG iterations to solve system:',solver%iterations
    print *, 'Range of solution:',minval(u),maxval(u)



end program
