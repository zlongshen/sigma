!--------------------------------------------------------------------------!
program matrix_tests_5                                                     !
!--------------------------------------------------------------------------!
!     This program tests multiplying two sparse matrices.                  !
!--------------------------------------------------------------------------!

use sigma

implicit none

    ! Matrices and graphs
    class(graph), pointer :: gr, hr, g
    ! Graph edge iterators
    type(graph_edge_cursor) :: cursor
    integer :: num_blocks, num_returned, edges(2,64)
    ! Integer indices
    integer :: i,j,k,l,m,n,d,di,d1,d2,nn
    integer, allocatable :: neighbors(:), more_neighbors(:)
    ! Random numbers and vectors
    real(dp) :: p
    real(dp), allocatable :: x(:), y(:), z(:)
    ! other variables
    logical :: correct, found
    ! command-line arguments
    character(len=16) :: arg
    logical verbose


    ! Get command line arguments to see if we're running in verbose mode
    verbose = .false.
    call getarg(1,arg)
    select case(trim(arg))
        case("-v")
            verbose = .true.
        case("-V")
            verbose = .true.
        case("--verbose")
            verbose = .true.
    end select


    ! Initialize a random seed
    call init_seed()
    nn = 64
    p = 6.0/nn



    !----------------------------------------------------------------------!
    ! Construct reference graphs from which all test graphs are copied     !
    !----------------------------------------------------------------------!
    allocate(ll_graph::gr)
    allocate(ll_graph::hr)
    allocate(cs_graph::g)

    call gr%init(nn,nn,degree=3)
    do i=1,nn
        call gr%add_edge(i,i)

        j = mod(i,nn)+1
        call gr%add_edge(i,j)
        call gr%add_edge(j,i)
    enddo

    call hr%init(gr)
    call graph_product(g,gr,hr)

    allocate(neighbors(g%max_degree))
    call g%get_neighbors(neighbors,16)

    correct = .true.
    do k=1,5
        found = .false.
        j = neighbors(k)

        do i=14,18
            if (j==i) found = .true.
        enddo
        correct = correct .and. found
    enddo

    if (.not.correct) then
        print *, 'Computing graph product failed, should have node 16'
        print *, 'neighboring nodes 14-18; neighbors found:',neighbors
        print *, 'Terminating.'
        call exit(1)
    endif


    !----------------------------------------------------------------------!
    ! Try it with different graphs                                         !
    !----------------------------------------------------------------------!
    call g%free()
    call gr%free()
    call hr%free()
    call gr%init(nn,nn,degree=2)

    do i=1,nn
        call gr%add_edge(i,i)

        j = mod(i,nn)+1
        call gr%add_edge(i,j)
    enddo

    call hr%init(gr,.true.)

    call graph_product(g,gr,hr)

    if (g%ne/=3*nn) then
        print *, 'Graph product does not have the correct number of edges;'
        print *, 'should be',3*nn
        print *, 'Number of edges found:',g%ne
        print *, 'Terminating.'
        call exit(1)
    endif

    if (g%max_degree/=3) then
        print *, 'Degree of graph product incorrect, should have degree = 3'
        print *, 'Degree found:',g%max_degree
        print *, 'Terminating.'
        call exit(1)
    endif

    i = 15
    do di=-1,1
        j = mod(i+di-1,nn)+1

        if (.not.g%connected(i,j)) then
            print *, 'Should have nodes',i,j
            print *, 'connected in g, but they are not!'
            print *, 'Terminating.'
            call exit(1)
        endif
    enddo



    !----------------------------------------------------------------------!
    ! And some more graphs                                                 !
    !----------------------------------------------------------------------!
    call g%free()
    call gr%free()
    call hr%free()
    call gr%init(nn,nn,degree=2)
    call hr%init(nn,nn,degree=2)

    do i=1,nn
        call gr%add_edge(i,i)
        j = mod(i,nn)+1
        call gr%add_edge(i,j)

        k = mod(i+1,nn)+1
        call hr%add_edge(i,j)
        call hr%add_edge(j,k)
    enddo

    call graph_product(g,gr,hr)



    !----------------------------------------------------------------------!
    ! And this time a random graph                                         !
    !----------------------------------------------------------------------!
    call g%free()
    call gr%free()
    call hr%free()
    call gr%init(nn,nn)
    call hr%init(nn,nn)

    allocate(y(nn), z(nn))
    deallocate(neighbors)

    do i=1,nn
        call random_number(y)
        call random_number(z)
        do j=1,nn
            if (y(j)<p) call gr%add_edge(i,j)
            if (z(j)<p) call hr%add_edge(i,j)
        enddo
    enddo

    allocate(neighbors(gr%max_degree), more_neighbors(hr%max_degree))

    call graph_product(g,gr,hr)

    ! First test that every edge of gr*hr is in g
    do i=1,nn
        d1 = gr%degree(i)
        call gr%get_neighbors(neighbors,i)
        do l=1,d1
            k = neighbors(l)

            d2 = hr%degree(k)
            call hr%get_neighbors(more_neighbors,k)
            do m=1,d2
                j = more_neighbors(m)

                if (.not.g%connected(i,j)) then
                    print *, 'Have nodes',i,k,'connected in gr'
                    print *, ' and nodes',k,j,'connected in hr'
                    print *, 'so we should have nodes',i,j
                    print *, 'connected in g = gr*hr, but they are not!'
                    call exit(1)
                endif
            enddo
        enddo
    enddo

    ! Then test that every edge of g is in gr*hr
    cursor = g%make_cursor(0)
    num_blocks = (cursor%final-cursor%start)/64+1
    do n=1,num_blocks
        call g%get_edges(edges,cursor,64,num_returned)

        do l=1,num_returned
            i = edges(1,l)
            j = edges(2,l)

            found = .false.

            d = gr%degree(i)
            call gr%get_neighbors(neighbors,i)
            do m=1,d
                k = neighbors(m)

                if (hr%connected(k,j)) found = .true.
            enddo

            if (.not.found) then
                print *, 'Have nodes',i,j,'connected in g, but there is no'
                print *, 'node k such that ',i,'<-> k in gr, k<->',j,'in hr'
                print *, 'Terminating.'
                call exit(1)
            endif
        enddo
    enddo


end program matrix_tests_5