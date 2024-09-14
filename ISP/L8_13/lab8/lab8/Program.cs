using ThreadingLibrary;

class Program
{

    static async Task Main(string[] args)
    {
        StreamService<Biology> ss = new StreamService<Biology>();
        MemoryStream ms = new MemoryStream();
        Progress<string> progress = new Progress<string>();
        progress.ProgressChanged += (s,e) => Console.WriteLine(e);
        
        List<Biology> biologies = new List<Biology>();

        for (int i = 0; i < 1000; i++)
        {
            
            Biology essence = new Biology();
            essence.Id = i;
            essence.Name = $"Essence {i}";
            essence.CanFly = i%2==0;
            biologies.Add(essence);
        }
        Task task1=ss.WriteToStreamAsync(ms,biologies,progress);
        await Task.Delay(1000);
        Task task2=ss.CopyFromStreamAsync(ms,"file.json",progress);
        await Task.WhenAll(task1,task2);
        int a = await ss.GetStatisticsAsync("file.json",(obj)=>obj.CanFly==true);

        Console.WriteLine(a);
    }
}