import numpy as np
from extra_tools import *

from gauss_standart import gaussian_elimination
from gauss_column_selection import gaussian_elimination_with_column_selection
from gauss_full_matrix_selection import gaussian_elimination_with_pivoting

import tests
import task

A = task.A
b = task.b

cond_A = np.linalg.cond(task.A)
print(f'Column_Selection: Condition number of A: {cond_A}')

print('Исходная система уравнений:')
print_equation(A, b)

print(f'Решение методом Гаусса без модификаций')
y = gaussian_elimination(A, b, 0)
print_x(gaussian_elimination(A, b, 0))
#print_x(gaussian_elimination_with_column_selection(A, b, 0))

print(f'\nРешение методом Гаусса с выбором главного элемента по столбцу')
print_x(gaussian_elimination_with_column_selection(A, b, 0))

print(f'\nРешение методом Гаусса с выбором главного элемента по всей матрице')
print_x(gaussian_elimination_with_pivoting(A, b, 0))

#print(f'\nПодставим полученные значения в исходную функцию')
#x = np.linalg.solve(A, b)
#temp = np.dot(A, y)
#print_x(temp)



