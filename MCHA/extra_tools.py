import numpy as np


def print_matrix(matrix):
    A = np.array(matrix)
    n = A.shape[0]
    m = A.shape[1]

    for i in range(n):
        for j in range(m):
            print('{:>6}'.format(A[i, j]), end='')
        print('\n')


def print_equation(matrix_a, answers_b):
    A = np.array(matrix_a)
    b = np.array(answers_b)

    n = A.shape[0]
    m = A.shape[1]

    for i in range(n):
        for j in range(m):
            print(f'{A[i,j]:>6.14f}', end='')
        print(f' | {b[i]:>6.14f}')
    print('\n')


def print_x(ls):
    ls = np.array(ls)
    print(f'X = [', end='')

    for i in ls:
        print(f'{i:>8.14f},', end='')
    print(f']')




