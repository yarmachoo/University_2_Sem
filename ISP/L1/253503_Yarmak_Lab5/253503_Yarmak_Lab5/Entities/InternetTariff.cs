using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace _253503_Yarmak_Lab5.Entities
{
    public class InternetTariff
    {
        public string tariffName {  get; set; }
        public double pricePerMByte {  get; set; }

        public InternetTariff(string tariffName, double pricePerMByte)
        {
            this.tariffName = tariffName;
            this.pricePerMByte = pricePerMByte;
        }

        public bool IsInternetTarifEqual(InternetTariff tempInternetTarif)
        {
            return (this.tariffName == tempInternetTarif.tariffName && this.pricePerMByte == tempInternetTarif.pricePerMByte);
        }

        public static InternetTariff operator + (InternetTariff left, InternetTariff right)
        {
            return new InternetTariff("Total", left.pricePerMByte + right.pricePerMByte);
        }
    }
}
