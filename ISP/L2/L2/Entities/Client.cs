using System;
using L2.Collections;
namespace L2.Entities
{
    public class Client
    {
        private string name;
        private double payment;

        public delegate void AddTrafficDelegate(string message);

        public event AddTrafficDelegate AddTrafficEvent;
        
        private MyCustomCollection<InternetTariff> tariffs;
        
        public Client(string name) 
        {
            this.name = name;
            this.payment = 0.0;
            tariffs = new MyCustomCollection<InternetTariff>();
        }

        public string Name
        {
            get { return name; }
        }

        public double Payment { get; set; }

        public MyCustomCollection<InternetTariff> Tariffs
        {
            get { return tariffs;}
        }

        public bool IsClientEqual(Client tempClient)
        {
            return (this.name == tempClient.name);
        }
        
        public void AddTariff(InternetTariff tariff)
        {
            tariffs.Add(tariff);
        }

        private void setPaymentPerTariff(InternetTariff tariff, double time)
        {
            tariff.Payment = time * tariff.Traffic;
        }
        public void AddTraffic(InternetTariff tariff, double time)
        {
            int i;
            for (i = 0; i < tariffs.Count; i++)
            {
                if (tariffs[i].IsInternetTarifEqual(tariff))
                {
                    break;
                }
            }

            if (i < tariffs.Count)
            {
                tariffs[i].Traffic = time;
                setPaymentPerTariff(tariff, time);
                Payment += tariffs[i].Payment;
                AddTrafficEvent?.Invoke($"Tariff: {tariff.tariffName}, time: {time} is added");
            }
            else
            {
                // Обработка случая, когда тариф не найден
                Console.WriteLine($"Tariff {tariff.tariffName} not found for client {Name}");
            }
        }

        public void ShowAllTariffs()
        {
            for(int i = 0; i<tariffs.Count; i++)
            {
                Console.WriteLine($"{i+1} tariff is: {tariffs[i].tariffName}, traffic is {tariffs[i].Traffic}\n " +
                                  $"payment is: {tariffs[i].Payment}");
            }
        }
    }
}