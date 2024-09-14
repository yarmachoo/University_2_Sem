using System;

namespace MCHA_1L
{
    internal class Program
    {
        public static double[,] Transpose(double[,] matrix)
        {
            int rows = matrix.GetLength(0);
            int columns = matrix.GetLength(1);
        
            double[,] transposed = new double[columns, rows];
        
            for (int i = 0; i < rows; i++)
            {
                for (int j = 0; j < columns; j++)
                {
                    transposed[j, i] = matrix[i, j];
                }
            }
        
            return transposed;
        }
        public static double[] Solve(double[,] A, double[] b)
        {
            int n = A.GetLength(0);
            double[] x = new double[n];

            // Создаем расширенную матрицу [A | b]
            double[,] augmentedMatrix = new double[n, n + 1];
            for (int i = 0; i < n; i++)
            {
                for (int j = 0; j < n; j++)
                {
                    augmentedMatrix[i, j] = A[i, j];
                }

                augmentedMatrix[i, n] = b[i];
            }

            // Приводим матрицу к ступенчатому виду
            for (int i = 0; i < n; i++)
            {
                // Поиск максимального элемента в текущем столбце
                int maxRow = i;
                double maxVal = Math.Abs(augmentedMatrix[i, i]);
                for (int k = i + 1; k < n; k++)
                {
                    double absVal = Math.Abs(augmentedMatrix[k, i]);
                    if (absVal > maxVal)
                    {
                        maxRow = k;
                        maxVal = absVal;
                    }
                }

                // Обмен строками
                if (maxRow != i)
                {
                    for (int k = i; k <= n; k++)
                    {
                        double temp = augmentedMatrix[i, k];
                        augmentedMatrix[i, k] = augmentedMatrix[maxRow, k];
                        augmentedMatrix[maxRow, k] = temp;
                    }
                }

                // Проверка на вырожденность
                if (Math.Abs(augmentedMatrix[i, i]) < 1e-10)
                {
                    throw new InvalidOperationException("Система уравнений вырождена.");
                }

                // Приведение к ступенчатому виду
                for (int j = i + 1; j < n; j++)
                {
                    double factor = augmentedMatrix[j, i] / augmentedMatrix[i, i];
                    for (int k = i; k <= n; k++)
                    {
                        augmentedMatrix[j, k] -= factor * augmentedMatrix[i, k];
                    }
                }
            }

            // Обратный ход метода Гаусса
            for (int i = n - 1; i >= 0; i--)
            {
                double sum = 0.0;
                for (int j = i + 1; j < n; j++)
                {
                    sum += augmentedMatrix[i, j] * x[j];
                }

                x[i] = (augmentedMatrix[i, n] - sum) / augmentedMatrix[i, i];
            }

            return x;
        }

        public static void Main(string[] args)
        {
            double[,] C = new double[,]
            {
                {0.2, 0, 0.2, 0, 0},
                {0, 0.2, 0, 0.2, 0},
                {0.2, 0, 0.2, 0, 0.2},
                {0, 0.2, 0, 0.2, 0},
                {0, 0, 0.2, 0, 0.2}
            };

            double[,] D = new double[,]
            {
                {2.33, 0.81, 0.67, 0.92, -0.53},
                {-0.53, 2.33, 0.81, 0.67, 0.92},
                {0.92, -0.53, 2.33, 0.81, 0.67},
                {0.67, 0.92, -0.53, 2.33, 0.81},
                {0.81, 0.67, 0.92, -0.53, 2.33 }
            };

            double[] b = new double[]
            {
                4.2, 4.2, 4.2, 4.2, 4.2
            };
            
            //b = Transpose(b);
            int n = C.GetLength(0);
            double[,] A = new double[n, n];

            // Вычисляем A = 14 * C + D
            for (int i = 0; i < n; i++)
            {
                for (int j = 0; j < n; j++)
                {
                    A[i, j] = 14 * C[i, j] + D[i, j];
                }
            }

            double[] x = Solve(A, b);

            Console.WriteLine("Решение системы A*x=b:");
            for (int i = 0; i < x.Length; i++)
            {
                Console.WriteLine($"x[{i}] = {x[i]:0.0000}");
            }
        }
    }
}