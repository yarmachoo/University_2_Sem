import numpy as np
from extra_tools import print_equation
from gauss_standart import *
import numpy as np


def compute_shifted_roots(matrix_a, answers_b, shifted_x) -> np.array:
    return np.matmul(shifted_x, compute_roots(matrix_a, answers_b))


def gaussian_elimination_with_pivoting(matrix_a, answers_b, verbose=1):

    A = np.array(matrix_a, dtype=float)
    b = np.array(answers_b, dtype=float)
    x = list()
    n = A.shape[0]
    m = A.shape[1]
    shifting_x = np.eye(b.shape[0])

    if verbose == 1:
        print('Default matrix:')
        print_equation(A, b)

    # forward move
    for k in range(0, n):

        max_element = A[k, k]
        max_element_row = k
        max_element_col = k
        for i in range(k, n):
            for j in range(k, m):
                if abs(A[i, j]) > abs(max_element):
                    max_element = A[i, j]
                    max_element_row = i
                    max_element_col = j

        A[[k, max_element_row]] = A[[max_element_row, k]]
        b[[k, max_element_row]] = b[[max_element_row, k]]
        A[:, [max_element_col, k]] = A[:, [k, max_element_col]]
        shifting_x[:, [k, max_element_col]] = shifting_x[:, [max_element_col, k]]

        if verbose == 2:
            print(f'helper: \n')
            print(shifting_x)

        base_element = A[k, k]

        if verbose == 1:
            print(f'k = {k})\n')
            print(f'max element = {max_element}')
            print_equation(A, b)

        A, b = make_zeros(A, b, k, verbose)

        cond_A = np.linalg.cond(A)
        #print(f'Matrix_Selection Condition number of A: {cond_A}')

    return compute_shifted_roots(A, b, shifting_x)