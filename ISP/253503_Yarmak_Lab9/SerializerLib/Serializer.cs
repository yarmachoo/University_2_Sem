using System.Collections.Generic;
using System.IO;
using System.Linq;
using _253503_Yarmak_Lab9.Domain;
using System.Text.Json;
using System.Xml.Serialization;
using System.Xml.Linq;

namespace SerializerLib
{
    public class Serializer : ISerialiser
    {
        public IEnumerable<Restaurant> DeSerializeByLINQ(string fileName)
        {
            XDocument xDocument = XDocument.Load(fileName);
            return 
                (from restraunt in xDocument.Descendants("restraunt")
                select new Restaurant(
                (string)restraunt.Element("name"),
                (from kitchen in restraunt.Descendants("kitchen")
                    select new Kitchen(
                        (string)kitchen.Element("ShieffName"),
                        (int)kitchen.Element("AmountOfDishes")
                        )).ToList()
                ));
        }

        public IEnumerable<Restaurant> DeSerializeByXML(string fileName)
        {
            XmlSerializer serializer = new XmlSerializer(typeof(List<Restaurant>));
            using (FileStream fs = new FileStream(fileName, FileMode.OpenOrCreate))
            {
                var restraunts = (List<Restaurant>)serializer.Deserialize(fs);
                foreach (var item in restraunts)
                {
                    yield return item;
                }
            }
        }

        public IEnumerable<Restaurant> DeSerializeByJSON(string fileName)
        {
            string jsonString = File.ReadAllText(fileName);
            var restaurants = JsonSerializer.Deserialize<List<Restaurant>>(jsonString);
            foreach (var item in restaurants)
            {
                yield return item;
            }
        }

        public void SerializeByLINQ(IEnumerable<Restaurant> restaurants, string fileName)
        {
            XDocument xDoc = new XDocument();
            XElement xRestaurants = new XElement("restraunt");
            foreach (Restaurant restaurant in restaurants)
            {
                XElement xRestaurant = new XElement("restraunt");
                xRestaurant.Add(new XElement("name", restaurant.Name));
                XElement xKitchens = new XElement("kitchens");
                foreach (Kitchen kitchen in restaurant.kitchens)
                {
                    XElement xKitchen = new XElement("kitchen");
                    xKitchen.Add(new XElement("ShieffName", kitchen.ShieffName));
                    xKitchen.Add(new XElement ("AmountOfDishes", kitchen.AmountOfDishes));
                    xKitchens.Add(xKitchen);
                }
                xRestaurant.Add(xKitchens);
                xRestaurants.Add(xRestaurant);
            }
            xDoc.Add(xRestaurants);
            xDoc.Save(fileName);
        }

        public void SerializeByXML(IEnumerable<Restaurant> restaurant, string fileName)
        {
            XmlSerializer serializer = new XmlSerializer(typeof(List<Restaurant>));
            using (FileStream fs = new FileStream(fileName, FileMode.OpenOrCreate))
            {
                serializer.Serialize(fs,restaurant);
            }
        }

        public void SerializeByJSON(IEnumerable<Restaurant> restaurant, string fileName)
        {
            string jsonString = JsonSerializer.Serialize(restaurant);
            File.WriteAllText(fileName, jsonString);
        }
    }
}