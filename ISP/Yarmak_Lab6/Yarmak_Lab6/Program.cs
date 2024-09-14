using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System;

namespace Yarmak_Lab6
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
            
            Assembly assembly = Assembly.LoadFrom("ClassLibrary.dll");
            Console.WriteLine(assembly.GetName());
            
            Type type = assembly.GetType("ClassLibrary.FileService`1");
            var getType = type.MakeGenericType(new []{typeof(Employee)});
            
            var instance = Activator.CreateInstance(getType);

            getType.GetMethod("SaveData", BindingFlags.Instance | BindingFlags.Public)
                .Invoke(instance, new object[] { employees, filename });

            var list = (IEnumerable<Employee>)getType.GetMethod("ReadFile", BindingFlags.Instance | BindingFlags.Public)
                .Invoke(instance, new object[] { filename });

            foreach (var item in list)
            {
                Console.WriteLine($"{item.Name}, {item.Age}, {item.IsEmployed}");
            }
            
        }
    }
}