using System;
using System.Collections.Generic;
namespace L3.Entities
{
    public class Client
    {
        //у клиента в тарифе вместо стоимости хранится ПОЛНАЯ оплата
        public List<InternetTariff> tariffs;
        private string name;
        public Client(string name)
        {
            this.name = name;
            tariffs = new List<InternetTariff>();
        }

        public void ShowAllTariffs()
        {
            foreach (var item in tariffs)
            {
                Console.WriteLine($"Name:{item.name}, price:{item.pricePerTariff}");
            }
        }

        public string GetName()
        {
            return this.name;
        }

        public bool IsEqual(Client client)
        {
            var isTariffsEquals = (client.tariffs.Count == this.tariffs.Count);
            if (isTariffsEquals)
            {
                for (int i = 0; i < client.tariffs.Count; i++)
                {
                    if (!client.tariffs[i].IsEqual(this.tariffs[i]))
                    {
                        isTariffsEquals = false;
                        break;
                    }
                }
            }

            return (client.name == this.name && isTariffsEquals);
        }

        public double GetAllSum()
        {
            double totalSum = 0.0;
            foreach (var item in tariffs)
            {
                totalSum += item.pricePerTariff;
            }

            return totalSum;
        }
    }
}