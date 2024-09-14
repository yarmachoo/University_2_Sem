using System.Text;
using System;

namespace ReflectionTest
{
    public class MySimpleAttribute:Attribute
    {
        public int Number { get; set; }
    }
}