using System;
using System.Collections.Generic;
using System.Linq;
namespace Testing
{
    internal class Program
    {
        public static void Main(string[] args)
        {
            List<Book> books = new List<Book>();
            Book book1 = new Book();
            book1.Id = 1234;
            book1.Name = "Hello";
            book1.Pages = 12;
            
            books.Add(book1);
            
            Book book2 = new Book();
            book2.Id = 4444;
            book2.Name = "Hi";
            book2.Pages = 90;
            
            books.Add(book2);
            
            Book book3 = new Book();
            book3.Id = 5555;
            book3.Name = "Booo";
            book3.Pages = 1000000;
            
            books.Add(book3);

            var filteredBooks = from b in books
                where b.Pages >= 30
                select new
                {
                    Name = b.Name,
                    TotalPages = b.Pages
                };
            foreach (var b in filteredBooks)
            {
                Console.WriteLine($"{b.Name}: {b.TotalPages}");
            }

            var filteredBooks2 = books
                .Where(b => b.Pages > 30)
                .GroupBy(b => b.Name);
            
            foreach (var b in filteredBooks2)
            {
                Console.WriteLine($"{b.Key}");
                foreach (var book in b)
                {
                    Console.WriteLine($"---{book.Id}");
                }
            }
        }
    }
}