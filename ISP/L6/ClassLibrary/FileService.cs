using System.IO;
using System.Collections.Generic;
using System.Text.Json;

namespace ClassLibrary
{
    public class FileService<T> : IFileService<T> where T : class
    {
        public IEnumerable<T> ReadFile(string fileName)
        {
            string json = File.ReadAllText(fileName);
            var list = JsonSerializer.Deserialize<List<T>>(json);
            foreach (var i in list)
            {
                yield return i;
            }
        }

        public void SaveData(IEnumerable<T> data, string fileName)
        {
            string json = JsonSerializer.Serialize(data);
            File.WriteAllText(fileName, json);
        }
    }
}