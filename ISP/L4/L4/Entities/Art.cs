namespace L4.Entities
{
    public class Art
    {
        public string Name { get; set; }
        public double Price { get; set; }

        public Art()
        {
            this.Name = "";
            this.Price = 0.0;
        }

        public Art(string name, double price)
        {
            this.Name = name;
            this.Price = price;
        }
    }
}