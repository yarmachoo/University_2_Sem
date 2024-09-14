using System.Collections;
using System.Collections.Generic;

namespace L6.Interfaces
{
    public interface IFileService<T> where T : class
    {
        IEnumerable<T> ReadFile(string FileName);
        void SaveData(IEnumerable<T> data, string fileName);
    }
}