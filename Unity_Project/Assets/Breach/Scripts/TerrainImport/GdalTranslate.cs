using System.IO;
using System.Diagnostics;
using UnityEngine;

public static class GdalTranslate {
    public static string GdalTranslatePath = Path.Combine(Application.streamingAssetsPath,  "gdal/gdal_translate.exe");

    public struct Arguments {
        public string inPath, outPath;
        public int outX, outY;
        public int nodata;
        public float scale;

        public override string ToString() {
            return $"-of ENVI -ot Int16 -outsize {outX} {outY} -a_nodata {nodata} -scale 0 1 0 {scale} {inPath} {outPath}";
        }
    }

    public static void ASCToRaw(Arguments args, out string log, out string err) {
        var proc = Process.Start(GdalTranslatePath, args.ToString());
        proc.WaitForExit();
        log = proc.StandardOutput.ReadToEnd();
        err = proc.StandardError.ReadToEnd();
    }
}
