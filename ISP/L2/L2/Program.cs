using System;
using L2.Collections;
using L2.Entities;
using L2.Exceptions;

namespace L2
{
    internal class Program
    {
        public static void Main(string[] args)
        {
            InternetOperator mts = new InternetOperator("MTS");
            InternetTariff t1 = new InternetTariff("T1", 536.3);
            InternetTariff t2 = new InternetTariff("T2", 346.3);

            Client Iryna = new Client("Iryna");
            Client Veron = new Client("Veron");

            Journal journal = new Journal();
            
            mts.AddClientEvent += journal.AddEvents;
            mts.AddClient(Iryna);
            Iryna.AddTrafficEvent += journal.AddEvents;

            mts.AddClientEvent += m=> Console.WriteLine($" --------> {m}");
                
            mts.AddTariffToClient(Iryna, t1);
            mts.AddTariffToClient(Iryna, t2);
            mts.AddTraffic(Iryna, t2, 12.2);
            mts.AddTraffic(Iryna, t1, 13.8);
            Iryna.ShowAllTariffs();
            
            Console.WriteLine("Events are:");
            Console.WriteLine(journal.ShowAllEvents());
            
            mts.AddClient(Veron);
            mts.AddTariffToClient(Veron, t1);
            mts.AddTariffToClient(Veron, t2);
            mts.AddTraffic(Veron, t1, 12.2);
            mts.AddTraffic(Veron, t2, 88.8);

            Iryna.ShowAllTariffs();

            var clients = mts.TheMostGenerousClient();
            Console.WriteLine("The most generous clients:");
            foreach (var item in clients)
            {
                Console.WriteLine($"Name is {item.Name}, payment is {item.Payment}");
            }
            Console.WriteLine("Exception:");
            MyCustomCollection<string> tempCollection = new MyCustomCollection<string>();
            try
            {
                tempCollection.Remove("hello");
            }
            catch (EmptyCollectionException exception)
            {
                Console.WriteLine(exception.Message);
            }
        }
    }
}