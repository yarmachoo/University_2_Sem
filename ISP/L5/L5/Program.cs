using System;
using System.Collections.Generic;
using System.Xml;
namespace L5
{
    internal class Program
    {
        public static void Main(string[] args)
        {
            var people = new List<Person>();
            
            XmlDocument xmlDoc = new XmlDocument();
            xmlDoc.Load("D:\\Uni\\ISP\\L5\\L5\\Persons.xml");

            XmlElement xRoot = xmlDoc.DocumentElement;
            if (xRoot != null)
            {
                foreach (XmlNode xNode in xRoot)
                {
                    Person person = new Person();
                    XmlNode attr = xNode.Attributes.GetNamedItem("name");
                    person.name = attr.Value;
                    foreach (XmlNode childNode in xNode.ChildNodes)
                    {
                        if (childNode.Name == "company")
                        {
                            person.company = childNode.Name;
                        }

                        if (childNode.Name == "age")
                        {
                            person.age = int.Parse(childNode.InnerText);
                        }
                    }
                    people.Add(person);
                }
            }

            foreach (var item in people)
            {
                Console.WriteLine($"Name: {item.name}, age: {item.age}, compeny: {item.company}");
            }
        }
    }
}