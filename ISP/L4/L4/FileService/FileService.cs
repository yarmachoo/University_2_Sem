using System;
using System.IO;
using System.Collections.Generic;
using System.Text;
using L4.Entities;
namespace L4

{
    public class FileService : IFileService<Art>
    {
        public IEnumerable<Art> ReadFile(string fileName)
        {
            if (!File.Exists(fileName))
            {
                throw new FileNotFoundException($"File {fileName} not found");
            }
            using (var fileStream = new FileStream(fileName, FileMode.Open, FileAccess.Read))
            using (var reader = new BinaryReader(fileStream))
            {
                while (fileStream.Position < fileStream.Length)
                {
                    double price;
                    string name;
                    try
                    {
                        price = reader.ReadDouble();
                        name = reader.ReadString();
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine($"Error reading exception: {e.Message}");
                        yield break;
                    }

                    yield return new Art(name, price);
                }
            }
        }
        public void SaveData(IEnumerable<Art> data, string fileName)
        {
            using(var fileStream = new FileStream(fileName, FileMode.Create, FileAccess.Write))
            using (var binaryWriter = new BinaryWriter(fileStream))
            {
                foreach (var art in data)
                {
                    double price = art.Price;
                    string name = art.Name;
                    try
                    {
                        binaryWriter.Write(price);
                        binaryWriter.Write(name);
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine(e.Message);
                        break;
                    }
                }
            }
        }
    }
}