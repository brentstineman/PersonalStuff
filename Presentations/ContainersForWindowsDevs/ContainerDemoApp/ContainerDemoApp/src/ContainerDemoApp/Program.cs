using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ContainerDemoApp
{
    public class Program
    {
        public static void Main(string[] args)
        {
            Console.WriteLine("**********************************");
            for (int x = 0; x<=5; x++)
                Console.WriteLine("**");

            // insert message here
            Console.WriteLine("*****    Hello there!");

            for (int x = 0; x <= 5; x++)
                Console.WriteLine("**");
            Console.WriteLine("**********************************");
        }
    }
}
