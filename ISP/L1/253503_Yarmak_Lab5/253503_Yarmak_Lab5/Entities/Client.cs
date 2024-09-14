using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using _253503_Yarmak_Lab5.Collections;

namespace _253503_Yarmak_Lab5.Entities
{
    public class Client
    {
        private string name;
        private MyCustomCollection<InternetTariff> internetTariffs;
        private double amountOfMoney=0;

        public Client(string name) 
        {
            internetTariffs = new MyCustomCollection<InternetTariff>();
            this.name = name;
            //this.amountOfMoney += internetTariffs.Current().pricePerMByte;
        }
        
        public string Name
        { get { return name; } }

        public MyCustomCollection<InternetTariff> internetTariff
        {
            get
            {
                return internetTariffs;
            }
        }
        public void AddInternetTariff(InternetTariff internetTariff)
        {
            internetTariffs.Add(internetTariff);
            //Console.WriteLine($"price per mb{internetTariff.pricePerMByte}");
            this.amountOfMoney += internetTariff.pricePerMByte;
        }

        public double GetAmontOfMoney()
        {
            return amountOfMoney;
        }

    }
}
