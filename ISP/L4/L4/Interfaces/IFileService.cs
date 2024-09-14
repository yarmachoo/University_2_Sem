using System;
using System.IO;
using System.Collections.Generic;
namespace L4
{
    public interface IFileService<T>
    {
        IEnumerable<T> ReadFile(string fileName);
        void SaveData(IEnumerable<T> data, string fileName);

    }

}