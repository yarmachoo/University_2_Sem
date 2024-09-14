namespace L5
{
    public class Person
    {
        public string name { get; set; }
        public int age { get; set; }
        public string company { get; set; } 

        public Person(string name, int age, string company)
        {
            this.age = age;
            this.name = name;
            this.company = company;
        }
        public Person()
        {}
    }
}