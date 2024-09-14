namespace ReflectionTest
{
    public class Student
    {
        private int temp = 7;
        public string Name { get; set; }
        
        [MySimple(Number = 5)]
        public string Age { get; set; }
    }
}