using System.Collections.Generic;

namespace ClassLibrary
{
    public interface IFileService<T> where T : class
    {
        public IEnumerable<T> ReadFile(string FileName);
        public void SaveData(IEnumerable<T> data, string fileName);
    }
}