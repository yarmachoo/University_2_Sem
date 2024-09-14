namespace _253503_Yarmak_Lab9.Domain
{
    public class Kitchen
    {
        public string ShieffName { get; set; }
        public int AmountOfDishes { get; set; }
        public Kitchen(){}

        public Kitchen(string ShieffName, int AmountOfDishes)
        {
            this.ShieffName = ShieffName;
            this.AmountOfDishes = AmountOfDishes;
        }
    }
}