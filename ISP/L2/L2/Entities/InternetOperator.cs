using L2.Collections;
using System;
namespace L2.Entities
{
    public class InternetOperator
    {
        private MyCustomCollection<Client> clients;
        private MyCustomCollection<InternetTariff> tariffs;
        private string nameOfOperator;

        public delegate void AddClientDelegate(string message);

        public event AddClientDelegate AddClientEvent;

        public InternetOperator(string nameOfOperator) 
        { 
            this.nameOfOperator = nameOfOperator;   
            clients = new MyCustomCollection<Client>();
        }
        public string NameOfOperator 
        { get {  return nameOfOperator; } }

        public void AddClient(Client client)
        {
            clients.Add(client);
            AddClientEvent.Invoke($"Client {client.Name} is added");
        }

        public void AddTraffic(Client client, InternetTariff tariff, double time)
        {
            for (int i = 0; i < clients.Count; i++)
            {
                if (clients[i].IsClientEqual(client))
                {
                    clients[i].AddTraffic(tariff, time);
                }
            }
        }

        public void AddTariffToClient(Client client, InternetTariff tariff)
        {
            for (int i = 0; i < clients.Count; i++)
            {
                if (clients[i].IsClientEqual(client))
                {
                    clients[i].AddTariff(tariff);
                }
            }
        }

        public MyCustomCollection<Client> TheMostGenerousClient()
        {
            MyCustomCollection<Client> tempClients = new MyCustomCollection<Client>();
            double tempPayment = clients[0].Payment;
            for (int i = 0; i < clients.Count; i++)
            {
                if (clients[i].Payment > tempPayment)
                {
                    tempPayment = clients[i].Payment;
                }
            }
            for (int i = 0; i < clients.Count; i++)
            {
                if (clients[i].Payment == tempPayment)
                {
                    tempClients.Add(clients[i]);
                }
            }

            return tempClients;
        }

        public void ShowTheMostGenerousClient(MyCustomCollection<Client> Clients)
        {
            Console.WriteLine($"The most generous client(-s):");
            for (int i = 0; i < Clients.Count; i++)
            {
                Console.WriteLine($"name is {Clients[i].Name}, end payment is {Clients[i].Payment}");
                
            }
        }

        public void ShowAll()
        {
            foreach (var client in clients)
            {
                Console.WriteLine($"name is {client.Name}, end payment is {client.Payment}");
            }
        }
        
    }
}