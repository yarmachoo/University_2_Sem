namespace L2.Entities
{
    public class InternetTariff
    {
        public string tariffName {  get; set; }
        public double pricePerMByte {  get; set; }

        private double traffic;
        private double payment;

        public InternetTariff(string tariffName, double pricePerMByte)
        {
            this.tariffName = tariffName;
            this.pricePerMByte = pricePerMByte;
            this.traffic = 0.0;
        }

        public double Traffic { get; set; }

        public double Payment { get; set; }
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