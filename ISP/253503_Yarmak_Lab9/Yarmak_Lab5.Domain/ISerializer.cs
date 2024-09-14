using System;
using System.Collections.Generic;
namespace _253503_Yarmak_Lab9.Domain
{
    public interface ISerialiser
    {
        IEnumerable<Restaurant> DeSerializeByLINQ(string fileName);
        IEnumerable<Restaurant> DeSerializeByXML(string fileName);
        IEnumerable<Restaurant> DeSerializeByJSON(string fileName);
        void SerializeByLINQ(IEnumerable<Restaurant> restaurant, string fileName);
        void SerializeByXML(IEnumerable<Restaurant> restaurant, string fileName);
        void SerializeByJSON(IEnumerable<Restaurant> restaurant, string fileName);
    }
}