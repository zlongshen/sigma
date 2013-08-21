module sparse_matrices

use types
use graphs

implicit none



!--------------------------------------------------------------------------!
type, abstract :: sparse_matrix                                            !
!--------------------------------------------------------------------------!
    integer :: nrow, ncol, nnz, max_degree
    logical :: pos_def
    logical :: assembled
contains
    procedure(init_matrix_ifc), deferred    :: init
    procedure(assemble_ifc), deferred       :: assemble
    procedure(mat_neighbors_ifc), deferred  :: neighbors
    procedure(get_value_ifc), deferred      :: get_value
    procedure(set_value_ifc), deferred      :: set_value, add_value
    procedure(sub_matrix_add_ifc), deferred :: sub_matrix_add
    procedure(permute_matrix_ifc), deferred :: left_permute, right_permute
    procedure(matvec_ifc), deferred         :: matvec, matvec_t
    generic :: matmul => matvec
    generic :: matmul_t => matvec_t
end type sparse_matrix


!--------------------------------------------------------------------------!
abstract interface                                                         !
!--------------------------------------------------------------------------!
    subroutine init_matrix_ifc(A,nrow,ncol)
        import :: sparse_matrix
        class(sparse_matrix), intent(inout) :: A
        integer, intent(in) :: nrow, ncol
    end subroutine init_matrix_ifc

    subroutine assemble_ifc(A,g)
        import :: sparse_matrix, graph
        class(sparse_matrix), intent(inout) :: A
        class(graph), pointer, intent(in) :: g
    end subroutine assemble_ifc

    subroutine mat_neighbors_ifc(A,i,nbrs)
        import :: sparse_matrix
        class(sparse_matrix), intent(in) :: A
        integer, intent(in)  :: i
        integer, intent(out) :: nbrs(:)
    end subroutine mat_neighbors_ifc

    function get_value_ifc(A,i,j)
        import :: sparse_matrix, dp
        class(sparse_matrix), intent(in) :: A
        integer, intent(in) :: i,j
        real(dp) :: get_value_ifc
    end function get_value_ifc

    subroutine set_value_ifc(A,i,j,val)
        import :: sparse_matrix, dp
        class(sparse_matrix), intent(inout) :: A
        integer, intent(in) :: i,j
        real(dp), intent(in) :: val
    end subroutine set_value_ifc

    subroutine sub_matrix_add_ifc(A,B)
        import :: sparse_matrix
        class(sparse_matrix), intent(inout) :: A
        class(sparse_matrix), intent(in)    :: B
    end subroutine sub_matrix_add_ifc

    subroutine permute_matrix_ifc(A,p)
        import :: sparse_matrix
        class(sparse_matrix), intent(inout) :: A
        integer, intent(in) :: p(:)
    end subroutine permute_matrix_ifc

    subroutine matvec_ifc(A,x,y)
        import :: sparse_matrix, dp
        class(sparse_matrix), intent(in) :: A
        real(dp), intent(in)  :: x(:)
        real(dp), intent(out) :: y(:)
    end subroutine matvec_ifc
end interface



!--------------------------------------------------------------------------!
type :: sparse_matrix_pointer                                              !
!--------------------------------------------------------------------------!
    class(sparse_matrix), pointer :: A

end type sparse_matrix_pointer




end module sparse_matrices