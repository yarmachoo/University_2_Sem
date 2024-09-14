using System;
using System.Reflection;

namespace ReflectionTest
{
    internal class Program
    {
        public static void Main(string[] args)
        {
            Student student = new Student();
            Type type = student.GetType();

            var properties = type.GetProperties();
            foreach (PropertyInfo propertyInfo in properties)
            {
                var attributes = propertyInfo.GetCustomAttributes(typeof(MySimpleAttribute), false);
                if (attributes.Length > 0)
                {
                    var attribute = (MySimpleAttribute)attributes[0];
                    Console.WriteLine($"Priperty name: {propertyInfo.Name}, attribute value: {attribute.Number}");
                }
            }
            /*Student student = new Student();
            Type type = student.GetType();*/
            /*Type type = typeof(Student);

            ConstructorInfo constructorInfo = type.GetConstructor(new Type[] { });
            object student = constructorInfo.Invoke(new object[] { });

            var fields = type.GetFields(BindingFlags.NonPublic | BindingFlags.Instance);
            foreach (FieldInfo fieldInfo in fields)
            {
                if (fieldInfo.Name == "temp")
                {
                    var value = fieldInfo.GetValue(student);
                    Console.WriteLine($"Before: {value}");

                    fieldInfo.SetValue(student, 15);
                    value = fieldInfo.GetValue(student);
                    Console.WriteLine($"After: {value}");
                }
            }*/
            /*Type type = Type.GetType("ReflectionTest.Student");
            var members = type.GetMembers(BindingFlags.NonPublic | BindingFlags.Instance);
            foreach (MemberInfo memberInfo in members)
            {
                Console.WriteLine(memberInfo.Name);
            }*/

        }
    }
}