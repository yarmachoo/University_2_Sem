import numpy as np
from extra_tools import print_equation
from gauss_standart import *

def gaussian_elimination_with_column_selection(matrix_A, vector_b, verbose=1):
    """
    Решает систему линейных уравнений Ax=b методом Гаусса с выбором главного элемента по столбцу.

    :param matrix_A: Матрица A системы линейных уравнений (A*x=b).
    :param vector_b: Вектор правой части системы линейных уравнений (A*x=b).
    :param verbose: Уровень вывода информации (0 - отключен, 1 - основной, 2 - отладочный).
    :return: Вектор корней x.
    """
    matrix_A = np.array(matrix_A, dtype=float)
    vector_b = np.array(vector_b, dtype=float)
    num_equations = matrix_A.shape[0]

    if verbose == 1:
        print('Исходная матрица:')
        print_equation(matrix_A, vector_b)

    for k in range(0, num_equations):

        max_in_column = matrix_A[k, k]
        min_row = k
        for i in range(k + 1, num_equations):
            if abs(matrix_A[i, k]) > abs(max_in_column) and matrix_A[i, k] != 0:
                max_in_column = matrix_A[i, k]
                min_row = i

        matrix_A[[min_row, k]] = matrix_A[[k, min_row]]
        vector_b[[min_row, k]] = vector_b[[k, min_row]]

        if verbose == 1:
            print(f'k={k})')
            print_equation(matrix_A, vector_b)

        matrix_A, vector_b = make_zeros(matrix_A, vector_b, k, verbose)



    return compute_roots(matrix_A, vector_b)