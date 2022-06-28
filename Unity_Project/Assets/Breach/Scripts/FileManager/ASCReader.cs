using System;
using System.Threading;
using System.Globalization;
using System.IO;
using System.Text.RegularExpressions;
using UnityEngine;

public class ASCReaderData
{
    public Matrix data;
    public float xCenter, yCenter, cellSize, noValue;
}

public class ASCReader {
    static string LINE_SPLIT_RE = @"\r\n|\n\r|\n|\r";

    public static ASCReaderData getDepthPoints(string file) {

        char[] delimiterChars = { ' ', '\t' };

        if (!File.Exists(file)) {
            return null;
        }

        ASCReaderData readData = new ASCReaderData();
        try{
            string textData = File.ReadAllText(file);
            string[] lines = Regex.Split(textData, LINE_SPLIT_RE);

            Debug.Log(lines[0]);
            Debug.Log(lines[1]);

            int NCols = Convert.ToInt32(lines[0].Split(delimiterChars, StringSplitOptions.RemoveEmptyEntries)[1].Trim());
            int MRows = Convert.ToInt32(lines[1].Split(delimiterChars, StringSplitOptions.RemoveEmptyEntries)[1].Trim());

            readData.noValue = Convert.ToSingle(lines[5].Split(delimiterChars, StringSplitOptions.RemoveEmptyEntries)[1].Trim(), CultureInfo.InvariantCulture);
            readData.cellSize = Convert.ToSingle(lines[4].Split(delimiterChars, StringSplitOptions.RemoveEmptyEntries)[1].Trim(), CultureInfo.InvariantCulture);
            readData.yCenter = Convert.ToSingle(lines[3].Split(delimiterChars, StringSplitOptions.RemoveEmptyEntries)[1].Trim(), CultureInfo.InvariantCulture);
            readData.xCenter = Convert.ToSingle(lines[2].Split(delimiterChars, StringSplitOptions.RemoveEmptyEntries)[1].Trim(), CultureInfo.InvariantCulture);

            readData.data = new Matrix(NCols, MRows);

            for (int i = 6; i < lines.Length; i++){
                string[] dataLine = lines[i].Split(delimiterChars, StringSplitOptions.RemoveEmptyEntries);
                if (dataLine.Length == NCols){
                    for (int j = 0; j < dataLine.Length; j++){
                        readData.data[j, i - 6] = Convert.ToSingle(dataLine[j], CultureInfo.InvariantCulture);
                    }
                }
            }

        }
        catch (Exception e)
        {
            Debug.LogError(e);
            readData = null;
        }

        return readData;

    }

    public static ASCReaderData getDataPoints(SemaphoreSlim ioSemaphore, string file) {
        ASCReaderData d = new ASCReaderData();

        char[] delimiterChars = { ' ', '\t' };

        if (!File.Exists(file)) {
            return null;
        }

        try {
            ioSemaphore.Wait();
            string textData = File.ReadAllText(file);
            ioSemaphore.Release();
            string[] lines = Regex.Split(textData, LINE_SPLIT_RE);

            var NCols = Convert.ToInt32(lines[0].Split(delimiterChars, StringSplitOptions.RemoveEmptyEntries)[1].Trim());
            var MRows = Convert.ToInt32(lines[1].Split(delimiterChars, StringSplitOptions.RemoveEmptyEntries)[1].Trim());

            d.noValue = Convert.ToSingle(lines[5].Split(delimiterChars, StringSplitOptions.RemoveEmptyEntries)[1].Trim(), CultureInfo.InvariantCulture);
            d.cellSize = Convert.ToSingle(lines[4].Split(delimiterChars, StringSplitOptions.RemoveEmptyEntries)[1].Trim(), CultureInfo.InvariantCulture);
            d.yCenter = Convert.ToSingle(lines[3].Split(delimiterChars, StringSplitOptions.RemoveEmptyEntries)[1].Trim(), CultureInfo.InvariantCulture);
            d.xCenter = Convert.ToSingle(lines[2].Split(delimiterChars, StringSplitOptions.RemoveEmptyEntries)[1].Trim(), CultureInfo.InvariantCulture);

            d.data = new Matrix(NCols, MRows);

            for (int i = 6; i < lines.Length; i++) {
                string[] dataLine = lines[i].Split(delimiterChars, StringSplitOptions.RemoveEmptyEntries);
                if (dataLine.Length == NCols) {
                    for (int j = 0; j < dataLine.Length; j++) {
                        float val = Convert.ToSingle(dataLine[j], CultureInfo.InvariantCulture);
                        d.data[j, i - 6] = val;
                    }
                }
            }

        } catch (Exception e) {
            Console.WriteLine(e);
            d = null;
        }

        return d;

    }

}
