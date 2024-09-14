namespace DefaultNamespace;

public class InternetOperator
{
    private MyCustomCollection<Client> clients;
        private string nameOfOperator;

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
        }
        //поиск клиента, заплатившего наибольшую сумму
        public MyCustomCollection<Client> TheMostGenerousClient()//наиболее щедрый клиент
        {
            double maxPrice = clients.Current().GetAmontOfMoney();
            MyCustomCollection<Client> tempClients = new MyCustomCollection<Client>();
            int amountOfClients = clients.Length();
            
            //Цикл ищет максимальный траффик
            while(amountOfClients-- >0)
            {
                if (maxPrice < clients.Current().GetAmontOfMoney())
                {
                    maxPrice = clients.Current().GetAmontOfMoney();
                }
                if(amountOfClients>0)
                    clients.Next();
            };
            clients.Reset();
            amountOfClients = clients.Length();

            //Цикл делает список из клиентов с максимальным трафиком
            while(amountOfClients-- > 0)
            {
                if(clients.Current().GetAmontOfMoney()==maxPrice)
                {
                    tempClients.Add(clients.Current());
                }
                if (amountOfClients > 0)
                {
                    clients.Next();
                }
            }
            clients.Reset();
            int amountOfTempClients = tempClients.Length();
            tempClients.Reset();

            //Цикл выводит на экран список клиентов с макс трафиком
            Console.WriteLine($"Клиент(-ы) с максимальным траффиком ({maxPrice}):");
            while (amountOfTempClients-- >0)
            {

                Console.WriteLine($"{tempClients.Current().Name}");
                tempClients.Next();
            }
            return tempClients;
        }

        public double GeneralPaymentPerTariff(InternetTariff internetTariff)
        {
            double generalPayment = 0;
            int amountOfClients = clients.Length();
            for(int i = 0; i<amountOfClients; i++)
            {
                MyCustomCollection<InternetTariff> tempTariff = clients[i].internetTariff;
                int amountOfTariffs = tempTariff.Length();
                for(int j = 0; j<amountOfTariffs; j++)
                {
                    if (tempTariff[j].IsInternetTarifEqual(internetTariff))
                    {
                        generalPayment += tempTariff[j].pricePerMByte;
                    }
                }
            }
            return generalPayment;
        }

        public double GeneralPaymentOfAllTraffic()
        {
            double generalPayment = 0;
            int amountOfClients = clients.Length();
            InternetTariff generalPaymentOfTariff = new InternetTariff("", 0);

            for (int i = 0; i < amountOfClients; i++)
            {
                MyCustomCollection<InternetTariff> tempTariff = clients[i].internetTariff;
                int amountOfTariffs = tempTariff.Length();
                for (int j = 0; j < amountOfTariffs; j++)
                {
                    generalPaymentOfTariff = generalPaymentOfTariff + tempTariff[j];
                }
            }
            
            return generalPaymentOfTariff.pricePerMByte;

        }

}