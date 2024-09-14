using L2.Collections;

namespace L2.Entities
{
    public class Journal
    {
        private MyCustomCollection<string> events;

        public Journal()
        {
            events = new MyCustomCollection<string>();
        }

        public void AddEvents(string name)
        {
            events.Add(name);
        }

        public string ShowAllEvents()
        {
            string str = "";
            foreach (var i in events)
            {
                str += i;
                str += "\n";
            }

            return str;
        }
    }
}