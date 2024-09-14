using System;
namespace L2.Exceptions
{
    public class EmptyCollectionException : Exception
    {
        public EmptyCollectionException(string message): base(message)
        { }
    }
}