using System;
using System.Collections.Generic;
using System.Linq;
namespace L3.Entities
{
    public class InternetTariff
    {
        public string name { get; set; }
        public double pricePerTariff { get; set; }

        public InternetTariff(string name, double pricePerTariff)
        {
            this.pricePerTariff = pricePerTariff;
            this.name = name;
        }

        public bool IsEqual(InternetTariff tariff)
        {
            return (tariff.name == this.name && tariff.pricePerTariff == this.pricePerTariff);
        }
    }
}