using ClassLibrary;

class Program
{
    public static async Task Main(string[] args)
    {
        List<Biology> biologies = new List<Biology>();
        
        var rnd = new Random();
        for (int i = 0; i < 1000; i++)
        {
            Biology essence = new Biology();
            essence.Id = i;
            essence.Name = $"Essence {i}";
            essence.CanFly = i%2==0;
            biologies.Add(essence);
        }

        StreamService<Biology> streamService = new StreamService<Biology>();

        MemoryStream memoryStream = new MemoryStream();

        streamService.WriteToStreamAsync(memoryStream, biologies);
        Console.WriteLine("hey1");
        Thread.Sleep(100);
        streamService.CopyFromStreamAsync(memoryStream, "file.txt");
        Console.WriteLine("hey2");
        Console.WriteLine(await streamService.GetStatisticsAsync("file.txt", (Biology bio) => bio.CanFly == true));
    }
}


