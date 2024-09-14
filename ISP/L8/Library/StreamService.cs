using System;
using System.Threading;
using System.Threading.Tasks;
using System.Text.Json;
using System.Linq;
using System.Collections.Generic;
using System.IO;

namespace Library
{
    public class StreamService<T> where T : class
    {
        public async Task WriteToStreamAsync(Stream stream, IEnumerable<T> data)
        {
            Console.WriteLine($"Starting write to stream {Thread.CurrentThread.ManagedThreadId}");
            lock (stream)
            {
                JsonSerializer.SerializeAsync(stream, data);
            }

            Console.WriteLine($"Ending write to stream {Thread.CurrentThread.ManagedThreadId}");
        }

        public async Task CopyFromStreamAsync(Stream stream, string fileName)
        {
            Console.WriteLine($"Starting write to file {Thread.CurrentThread.ManagedThreadId}");
            await using (var file = File.Open(fileName, FileMode.Create, FileAccess.ReadWrite))
            {
                stream.Position = 0;
                lock (stream)
                {
                    stream.CopyToAsync(file);
                }
            }

            Console.WriteLine($"Ending write to file {Thread.CurrentThread.ManagedThreadId}");
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