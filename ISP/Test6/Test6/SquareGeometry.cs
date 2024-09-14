namespace Test6
{
    public class SquareGeometry
    {
        public double Height { get; set; }
        public double Length { get; set; }
        public SquareGeometry():this(0,0)
        {}
        public SquareGeometry(double height, double length)=>
        (Height, Length)=(height, length);
        public double GetSquare() => Height*Length;
    }
}