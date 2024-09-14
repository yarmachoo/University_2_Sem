using System;
using System.Collections.Generic;
using System.IO;
using _253503_Yarmak_Lab9.Domain;
using SerializerLib;

namespace _253503_Yarmak_Lab9
{
    internal class Program
    {
        public static void Main(string[] args)
        {
            List<Restaurant> restaurants = new List<Restaurant>();

            Restaurant michel = new Restaurant("Michel");
            michel.AddKitchen(new Kitchen("Ivan", 55));
            michel.AddKitchen(new Kitchen("Siarhey", 12));

            Restaurant cornflowers = new Restaurant("CornFlowers");
            cornflowers.AddKitchen(new Kitchen("Vero", 88));
            cornflowers.AddKitchen(new Kitchen("Ksenia", 99));

            restaurants.Add(michel);
            restaurants.Add(cornflowers);

            Serializer serializer = new Serializer();

            serializer.SerializeByXML(restaurants, "restraunts.xml");
            serializer.SerializeByJSON(restaurants, "restraunts.json");
            serializer.SerializeByLINQ(restaurants, "restraunts.linq");
            
            Stack<bool> comparer = new Stack<bool>();
            foreach (Restaurant restaurant in serializer.DeSerializeByXML("restraunts.xml"))
            {
                Console.WriteLine(restaurant.Name);
                foreach (var kitchen in restaurant.kitchens)
                {
                    Console.WriteLine($"Shieff name: {kitchen.ShieffName}\n" +
                                      $"Amount of dishes: {kitchen.AmountOfDishes}\n");
                }
                if(restaurant.Equals(michel))
                    comparer.Push(true);
                if(restaurant.Equals(cornflowers))
                    comparer.Push(true);
            }
            foreach(var i in comparer)
                Console.WriteLine(i);
            
            if (comparer.Count == 2)
            {
                Console.WriteLine("Прочитанные данные через Xml совпадают с исходной коллекцией");
                comparer.Clear();
            }

            foreach (Restaurant restaurant in serializer.DeSerializeByJSON("restraunts.json"))
            {
                Console.WriteLine(restaurant.Name);
                foreach (var kitchen in restaurant.kitchens)
                {
                    Console.WriteLine($"Shieff name: {kitchen.ShieffName}\n" +
                                      $"Amount of dishes: {kitchen.AmountOfDishes}\n");
                }
                if(restaurant.Equals(michel))
                    comparer.Push(true);
                if(restaurant.Equals(cornflowers))
                    comparer.Push(true);
            }
            if (comparer.Count == 2)
            {
                Console.WriteLine("Прочитанные данные через Xml совпадают с исходной коллекцией");
                comparer.Clear();
            }
            
            foreach (Restaurant restaurant in serializer.DeSerializeByLINQ("restraunts.linq"))
            {
                Console.WriteLine(restaurant.Name);
                foreach (var kitchen in restaurant.kitchens)
                {
                    Console.WriteLine($"Shieff name: {kitchen.ShieffName}\n" +
                                      $"Amount of dishes: {kitchen.AmountOfDishes}\n");
                }

                if (restaurant.Equals(michel))
                {
                    Console.WriteLine(true);
                    comparer.Push(true);
                }
                if(restaurant.Equals(cornflowers))
                    comparer.Push(true);
            }
            if (comparer.Count == 2)
            {
                Console.WriteLine("Прочитанные данные через Xml совпадают с исходной коллекцией");
                comparer.Clear();
            }
            
        }
    }
}