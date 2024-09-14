import numpy as np
from extra_tools import print_equation


def gaussian_elimination(matrix_a, answers_b, verbose=1):
    A = np.array(matrix_a, dtype=float)
    b = np.array(answers_b, dtype=float)
    x = list()
    n = A.shape[0]
    m = A.shape[1]

    if verbose == 1:
        print('Default matrix:')
        print_equation(A, b)

    # forward move
    for k in range(0, n):
        if A[k, k] == 0:
            for i in range(k + 1, n):
                if A[i, i] != 0:
                    A[[i, k]] = A[[k, i]]
                    b[[i, k]] = b[[k, i]]
                    break

        if verbose == 1:
            print(f'k={k})')
            print_equation(A, b)

        A, b = make_zeros(A, b, k, verbose)

    return compute_roots(A, b)


def make_zeros(matrix_a, answers_b, k, verbose=1):
    A = np.array(matrix_a, dtype=float)
    b = np.array(answers_b, dtype=float)
    n = A.shape[0]
    m = A.shape[1]
    base_element = A[k, k]

    for i in range(k + 1, n):
        q = A[i, k] / base_element
        for j in range(k, m):
            A[i, j] = A[i, j] - q * A[k, j]
        b[i] = b[i] - q * b[k]

        if verbose == 2:
            print_equation(A, b)

    return A, b


# reverse move
def compute_roots(matrix_a, answers_b) -> np.array:
    A = np.array(matrix_a, dtype=float)
    b = np.array(answers_b, dtype=float)
    x = list()
    n = A.shape[0]
    m = A.shape[1]

    for i in range(n - 1, -1, -1):
        s = float(b[i])
        for j in range(0, m - i - 1):
            s -= A[i, m - j - 1] * x[j]

        try:
            if A[i, i] == 0:
                raise Exception("Infinity roots :)")
        except Exception:
            print("This equation has infinity roots")
            for m in range(n):
                x.append(0)
            return x

        x_new = s / A[i, i]
        x.append(x_new)

    x.reverse()

    return x