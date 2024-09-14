using System;

namespace L4.ExtraToolsForFileNaming
{
    public class RandomFileNaming
    {
        public static string RandomFileName(Random random)
        {
            string chars = "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm1234567890";
            char[] name = new char[6];
            for (int i = 0; i < name.Length; i++)
            {
                name[i] = chars[random.Next(name.Length)];
            }

            return new string(name);
        }

        public static string RandomFileExstention(Random random)
        {
            string[] extentions =
            {
                "txt", "rtf", "dat", "inf"
            };
            return extentions[random.Next(extentions.Length)];
        }
    }
}