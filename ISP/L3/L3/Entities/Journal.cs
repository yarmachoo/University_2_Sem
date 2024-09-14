using System;
using System.Collections.Generic;

namespace L3.Entities
{
    public class Journal
    {
        private List<string> events;
        public Journal()
        {
            events = new List<string>();
        }

        public void AddEvents(string log)
        {
            events.Add(log);
        }

        public string ShowAllEvents()
        {
            string str = "";
            foreach (var item in events)
            {
                str += item + "\n";
            }
            return str;
        }
    }
}