using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Text.Json;
using System.Runtime.Serialization.Json;

namespace ThreadingLibrary
{
    public class StreamService<T> where T:class
    {
        Semaphore sph = new Semaphore(1, 1);

        public async Task WriteToStreamAsync(Stream stream, IEnumerable<Biology> data, IProgress<string> progress)
        {
            sph.WaitOne();
            progress.Report($"Thread is written to stream {Thread.CurrentThread.ManagedThreadId}");
            for (int i = 1; i <= 100; i++)
            {
                Thread.Sleep(10);
                progress.Report($"Thread {Thread.CurrentThread.ManagedThreadId}: {i}%");
            }

            DataContractJsonSerializer js = new DataContractJsonSerializer(typeof(List<Biology>));
            js.WriteObject(stream, data);
            stream.Position = 0;

            progress.Report($"End of writing to stream {Thread.CurrentThread.ManagedThreadId}");
            sph.Release();
        }

        public async Task CopyFromStreamAsync(Stream stream, string filename, IProgress<string> progress)
        {
            sph.WaitOne();
            progress.Report($"Start of writing to stream {Thread.CurrentThread.ManagedThreadId}");
            StreamReader streamReader = new StreamReader(stream);
            string json = streamReader.ReadToEnd();
            await File.WriteAllTextAsync(filename, json);
            for (int i = 1; i <= 100; i++)
            {
                Thread.Sleep(10);
                progress.Report($"Thread {Thread.CurrentThread.ManagedThreadId}: {i}%");
            }
            progress.Report($"End of writting to stream{Thread.CurrentThread.ManagedThreadId}");
            sph.Release();
        }
        public async Task<int> GetStatisticsAsync(string fileName, Func<T, bool> filter)
        {
            
            List<T> list;
            using (var file = File.Open(fileName, FileMode.Open))
            {
                list = await JsonSerializer.DeserializeAsync<List<T>>(file);
            }
            return list.Where(filter).Count();
        }
    }
}
