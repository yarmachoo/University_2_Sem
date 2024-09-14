using System.Reflection;
using System;
namespace Test6
{
    class Program{
        public static void Main(string[] args)
        {
            Assembly asm = Assembly.LoadFrom("Test6.dll");
            Type type = asm.GetTy1pe("Test6.SquareGeometry");

            var geom1 = asm.CreateInstance("Geometry.SquareGeometry");
            var geom2 = Activator.CreateInstance(type,
                new object[] { 10, 15 });
            var meth = asm.GetType("Test6.SquareGeometry")
                .GetMethod("GetSquare");
            var result = meth.Invoke(geom2, null);
        }
    }
}