using System;
using System.Linq;
using L3.Entities;

namespace L3
{
    internal class Program
    {
        public static void Main(string[] args)
        {
            InternetProvider mts = new InternetProvider("mts");
            InternetTariff a1 = new InternetTariff("a1", 91.1);
            InternetTariff a2 = new InternetTariff("a2", 6.9);
            InternetTariff a3 = new InternetTariff("a3", 67.3);
            
            Client iryna = new Client("Iryna");
            Client evgeni = new Client("Yauheni");
            
            Journal journal = new Journal();
            
            mts.AddClientEvent += journal.AddEvents;
            mts.AddClient(iryna);
            mts.AddTariff("a1",a1);
            mts.AddTariff("a2",a2);
            mts.AddTariff("a3",a3);
            Console.WriteLine($"Отсортированные тарифы");
            mts.ShowSortedInternetTarifs();
            
            mts.AddTariffToClient(iryna, a1, 12.2);
            mts.AddTariffToClient(iryna, a2, 66.2);
            mts.AddTariffToClient(iryna, a3, 172.2);
            
            Console.WriteLine($"Тарифы Ирины");
            iryna.ShowAllTariffs();
            
            mts.AddClient(evgeni);
            
            mts.AddTariffToClient(evgeni, a1, 55555.6);
            Console.WriteLine($"Тарифы Eвгения");
            evgeni.ShowAllTariffs();
            
            Console.WriteLine($"Полная стоимость траффика оператора:{mts.GetTotalTrafficCost()} MByte");
            Console.WriteLine($"Клиент заплативший наибольшую сумму: {mts.NameOfTopPayingClient()}");
            Console.WriteLine($"Количество клиентов, заплативший больше 20: {mts.GetAmountOfClientsPayingMoreThan(20.0)}"
                );
            
            var countByTariff = mts.GetClientCountByTariff();
            foreach (var kvp in countByTariff)
            {
                Console.WriteLine($"Тариф '{kvp.Key}': {kvp.Value} клиентов");
            }
            
            Console.WriteLine("Events are:");
            Console.WriteLine(journal.ShowAllEvents());
        }
    }
}