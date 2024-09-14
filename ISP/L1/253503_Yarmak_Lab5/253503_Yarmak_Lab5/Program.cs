using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using _253503_Yarmak_Lab5.Collections;
using _253503_Yarmak_Lab5.Entities;

namespace _253503_Yarmak_Lab5
{
    internal class Program
    {
        static void Main(string[] args)
        {
            
            InternetOperator mts = new InternetOperator("MTS");
            InternetTariff t1 = new InternetTariff("T1", 536.3);
            InternetTariff t2 = new InternetTariff("T2", 346.3);

            Client Iryna = new Client("Iryna");
            mts.AddClient(Iryna);
            Iryna.AddInternetTariff(t1);
            Iryna.AddInternetTariff(t2);

            Client Veron = new Client("Veronika");
            mts.AddClient(Veron);
            Veron.AddInternetTariff(t1);
            Veron.AddInternetTariff(t2);

            //поиск клиента/ов, заплатившего наибольшую стоимость за услуги.
            mts.TheMostGenerousClient();

            Console.WriteLine($"Oбщие выплаты по тарифу T1: {mts.GeneralPaymentPerTariff(t1)}");
            Console.WriteLine($"Oбщая стоимость реализованного трафика: {mts.GeneralPaymentOfAllTraffic()}");
        }
    }
}
