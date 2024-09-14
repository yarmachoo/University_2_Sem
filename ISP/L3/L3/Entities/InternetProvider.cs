using System.Collections.Generic;
using System.Linq;
using System;

namespace L3.Entities
{
    public class InternetProvider
    {
        public List<Client> clients;
        public Dictionary<string, InternetTariff> tariffs;
        private string name;
        
        public delegate void AddClientDelegate(string message);
        public event AddClientDelegate AddClientEvent;

        public InternetProvider(string name)
        {
            this.name = name;
            clients = new List<Client>();
            tariffs = new Dictionary<string, InternetTariff>();
        }

        public void AddTariff(string name, InternetTariff it)
        {
            tariffs.Add(name, it);
        }
        public void AddClient(Client client)
        {
            clients.Add(client);
            AddClientEvent.Invoke($"Client {client.GetName()} is added");
        }

        public void AddTariffToClient(Client client, InternetTariff tariff, double minutes)
        {
            tariff.pricePerTariff *= minutes;
            foreach (var item in clients)
            {
                if (item.IsEqual(client))
                {
                    item.tariffs.Add(tariff);
                }
            }
        }
        public void ShowSortedInternetTarifs()
        {
            var sortedDictionary = this.tariffs
                .OrderBy(x => x.Value.pricePerTariff)
                .ToDictionary(x => x.Key, x => x.Value.pricePerTariff);
            foreach (var item in sortedDictionary)
            {
                Console.WriteLine($"Name:{item.Key}, price:{item.Value}");
            }
        }
        public double GetTotalTrafficCost()
        {
            double totalSum = 0.0;
            foreach (var item in clients)
            {
                totalSum += item.GetAllSum();
            }
            return totalSum;
        }

        public string NameOfTopPayingClient()
        {
            string name = "";
            double[] payment = new double[clients.Count];
            int i = 0;
            foreach (var item in clients)
            {
                payment[i] = item.GetAllSum();
                i++;
            }

            double maxPayment = payment.Max();
            foreach (var item in clients)
            {
                if (item.GetAllSum() == maxPayment)
                {
                    name = item.GetName();
                    break;
                }
            }
            return name;
        }

        public int GetAmountOfClientsPayingMoreThan(double key)
        {
            int foundedClients = clients
                .Where(cl => cl.GetAllSum() > key)
                .Aggregate(0, (totalCount, client)=>totalCount+1);
            return foundedClients;
        }

        private Dictionary<int, string> fillsTariffs()
        {
            Dictionary<int, string> dict = new Dictionary<int, string>();
            List<string> namesOfTariffs = tariffs.Keys.ToList();
            for (int i = 0; i < tariffs.Count(); i++)
            {
                dict.Add(0, namesOfTariffs[i]);
            }
            return dict;
        }
        public Dictionary<string, int> GetClientCountByTariff()
        {
            var countByTariff = clients
                .SelectMany(client => client.tariffs, (client, tariff) => new { Client = client, Tariff = tariff })
                .GroupBy(item => item.Tariff.name)
                .ToDictionary(group => group.Key, group => group.Count());

            return countByTariff;
        }
    }
}