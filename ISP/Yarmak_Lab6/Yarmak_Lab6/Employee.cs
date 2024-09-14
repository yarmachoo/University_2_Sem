namespace Yarmak_Lab6
{
    public class Employee
    {
        public int Age { get; set; }
        
        public bool IsEmployed { get; set; }
        public string Name { get; set; }

        public Employee(){}

        public Employee(int age, string name, bool isEmployed)
        {
            this.Age = age;
            this.Name = name;
            this.IsEmployed = isEmployed;
        }
    }
}