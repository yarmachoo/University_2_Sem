using L6.Entities;
using L6.Interfaces;
using System.IO;
using System.Collections.Generic;
using System.Text.Json;


using System;

namespace L6.FileService
{
    public class FileService:IFileService<Employee>
    {
        public IEnumerable<Employee> ReadFile(string fileName)
        {
            string json = File.ReadAllText(fileName);
            var list = JsonSerializer.Deserialize<List<Employee>>(json);
            foreach (var i in list)
            {
                yield return i;
            }
        }

        public void SaveData(IEnumerable<Employee> data, string fileName)
        {
            string json = JsonSerializer.Serialize(data);
            File.WriteAllText(fileName,json);
        }
    }
}