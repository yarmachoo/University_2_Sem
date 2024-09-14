using System.Collections.Generic;
using L4.Entities;
namespace L4
{
    public class MyCustomComparer :IComparer<Art>
    {
        public int Compare(Art x, Art y)
        {
            return x.Name.CompareTo(y.Name);
        }
    }
}