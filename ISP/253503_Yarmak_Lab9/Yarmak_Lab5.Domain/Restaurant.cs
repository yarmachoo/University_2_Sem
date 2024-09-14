using System;
using System.Collections.Generic;

namespace _253503_Yarmak_Lab9.Domain
{
    public class Restaurant : IEquatable<Restaurant>
    {
        public Restaurant()
        { }

        public List<Kitchen> kitchens { get; set; }
        public string Name { get; set; }

        public Restaurant(string name)
        { 
            this.Name = name;
            kitchens = new List<Kitchen>();
        }

        public Restaurant(string name, List<Kitchen> kitchens)
        {
            this.Name = name;
            this.kitchens = kitchens;
        }

        public void AddKitchen(Kitchen kitchen)
        {
            kitchens.Add(kitchen);
        }
        public bool Equals(Restaurant other)
        {
            if (other == null)
            {
                return false;
            }
            Console.WriteLine($"other name = {other.Name}, name = {Name}");
            // Сравниваем свойства
            if (Name != other.Name)
            {
                return false;
            }

            if (kitchens.Count == other.kitchens.Count)
            {
                for (int i = 0; i < kitchens.Count; i++)
                {
                    if (kitchens[i].ShieffName != other.kitchens[i].ShieffName)
                        return false;
                    if (kitchens[i].AmountOfDishes != other.kitchens[i].AmountOfDishes)
                        return false;
                }
            }
            else return false;

            return true;
        }
    }
}