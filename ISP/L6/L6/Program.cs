using System.Collections.Generic;
using System.IO;
using L6.Entities;
using System.Reflection;
using System;
using L6.FileService;

namespace L6
{
    internal class Program
    {
        public static void Main(string[] args)
        {
            List<Employee> employees = new List<Employee>();
            
            employees.Add(new Employee(12, "1", true));
            employees.Add(new Employee(33, "2", true));
            employees.Add(new Employee(62, "3", false));
            employees.Add(new Employee(11, "4", true));
            employees.Add(new Employee(24, "5", true));

            string filename = "Emplyees.json";

            //Assembly assembly = Assembly.LoadFrom("ClassLibrary.dll");
            string assemblyPath = "ClassLibrary.dll";
            if (File.Exists(assemblyPath))
            {
                try
                {
                    Assembly assembly1 = Assembly.LoadFrom(assemblyPath);

                    try
                    {
                        foreach (Type typ in assembly1.GetTypes())
                        {
                            Console.WriteLine($" typ.FullName : :))){typ.FullName}");
                        }
                    }
                    catch (ReflectionTypeLoadException ex)
                    {
                        Console.WriteLine("Ошибка при загрузке одного или более типов:");

                        foreach (Exception loaderException in ex.LoaderExceptions)
                        {
                            Console.WriteLine(loaderException.Message);
                        }
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Ошибка при загрузке сборки: {ex.Message}");
                }
            }
            else
            {
                Console.WriteLine("Файл сборки не найден.");
            }
            
            Assembly assembly = Assembly.LoadFrom("ClassLibrary.dll");
            Console.WriteLine(assembly.GetName());
            
            Type type = assembly.GetType("ClassLibrary.FileService`1");
            
            var getType = type.MakeGenericType(new []{typeof(Employee)});
            
            var instance = Activator.CreateInstance(getType);

            getType.GetMethod("SaveData")
                .Invoke(instance, new object[] { employees, filename });

            var list = (IEnumerable<Employee>)getType.GetMethod("ReadFile")
                .Invoke(instance, new object[] { filename });

            foreach (var item in list)
            {
                Console.WriteLine($"{item.Name}, {item.Age}, {item.IsEmployed}");
            }
            
        }
    }
}