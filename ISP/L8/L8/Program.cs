using System;
using System.Threading.Tasks;
using System.Threading;
namespace L8
{
    internal class Program
    {
        public static void Main(string[] args)
        {
            Console.WriteLine("Main Starts");
            Task task1 = new Task(() =>
            {
                Console.WriteLine("Task Starts");
                Thread.Sleep(1000); 
                Console.WriteLine("Task Ends");
            });
            task1.RunSynchronously(); // запускаем задачу синхронно
            Console.WriteLine("Main Ends"); // этот вызов ждет завершения задачи task1 
        }
    }
}