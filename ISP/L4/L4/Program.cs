using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using L4.Entities;
using L4.ExtraToolsForFileNaming;
using System.Linq;

namespace L4
{
    internal class Program
    {
        public static void Main(string[] args)
        {
            var dir = new DirectoryInfo("Yarmak_Lab4");
            if (!dir.Exists)
                dir.Create();
            Random random = new Random();
            
            for (int i = 0; i < 10; i++)
            {
                string fileName = Path.Combine(dir.FullName,
                    $"{RandomFileNaming.RandomFileName(random)}.{RandomFileNaming.RandomFileExstention(random)}");
                File.Create(fileName).Close();
            }

            var files = dir.GetFiles();
            foreach (var file in files)
            {
                Console.WriteLine(
                    $"Файл: <{Path.GetFileNameWithoutExtension(file.Name)}> имеет расширение <{file.Extension}>");
            }

            var artsDir = new DirectoryInfo("Arts");
            if (!artsDir.Exists)
                artsDir.Create();
            string fileWithArtsName = Path.Combine(artsDir.FullName, "arts.txt");
            File.Create(fileWithArtsName).Close();

            List<Art> arts = new List<Art>();
            arts.Add(new Art("freedom", 12345.3));
            arts.Add(new Art("loyalty", 9999999.9));
            arts.Add(new Art("feminity", 788787878.3));
            arts.Add(new Art("love", 8888));
            arts.Add(new Art("friendship", 10000000));

            FileService fileService = new FileService();
            fileService.SaveData(arts, fileWithArtsName);
            string newFileName = "newFile.txt";
            File.Move(fileWithArtsName, newFileName);
            var arts2 = new List<Art>();

            foreach (var art in fileService.ReadFile(newFileName))
            {
                arts2.Add(art);
            }
            File.Delete(newFileName);
            
            MyCustomComparer comparer = new MyCustomComparer();
            var sortedArts = arts2.OrderBy(art => art, comparer).ToList();
            
            Console.WriteLine("Sorted collection by MyCustomComparer");
            foreach (var art in sortedArts)
            {
                Console.WriteLine($"Name:{art.Name}, price:{art.Price}");
            }

            var sortedArts2 = arts2.OrderByDescending(
                art => art.Price).ToList();
            Console.WriteLine("Sorted collection by lyambda");
            foreach (var art in sortedArts2)
            {
                Console.WriteLine($"Name:{art.Name}, price:{art.Price}");
            }
        }
    }
}
