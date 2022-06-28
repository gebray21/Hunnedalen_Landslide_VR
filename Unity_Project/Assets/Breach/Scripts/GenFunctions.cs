using System;
using System.Threading.Tasks;
using UnityEngine;

public static class GenFunctions
{
    /// <summary>
    /// Given coordinates in the "local" matrix space, returns the height given by the matrix data.
    /// handles interpolation between points in the matrix space AND time in the animation (hence the two matrices and time parameter).
    /// </summary>
    /// <param name="m0">First matrix frame</param>
    /// <param name="m1">Second matrix frame</param>
    /// <param name="t">Time between the two </param>
    /// <param name="p">Position in space to sample</param>
    /// <returns></returns>
    public static float SampleInterpolatedMatrix(Matrix m0, Matrix m1, float t, Vector2 p) {
        var c000 = m0[Mathf.FloorToInt(p.x), Mathf.FloorToInt(p.y)];
        var c100 = m0[Mathf.CeilToInt(p.x), Mathf.FloorToInt(p.y)];
        var c010 = m0[Mathf.FloorToInt(p.x), Mathf.CeilToInt(p.y)];
        var c110 = m0[Mathf.CeilToInt(p.x), Mathf.CeilToInt(p.y)];
        var c001 = m1[Mathf.FloorToInt(p.x), Mathf.FloorToInt(p.y)];
        var c101 = m1[Mathf.CeilToInt(p.x), Mathf.FloorToInt(p.y)];
        var c011 = m1[Mathf.FloorToInt(p.x), Mathf.CeilToInt(p.y)];
        var c111 = m1[Mathf.CeilToInt(p.x), Mathf.CeilToInt(p.y)];

        Vector3 g = new Vector3(p.x - (float)Math.Truncate(p.x), p.y - (float)Math.Truncate(p.y), 1-t);
        Vector3 f = new Vector3(1, 1, 1) - g;

        return
            c000*f.x*f.y*f.z +
            c100*g.x*f.y*f.z +
            c010*f.x*g.y*f.z +
            c110*g.x*g.y*f.z +
            c001*f.x*f.y*g.z +
            c101*g.x*f.y*g.z +
            c011*f.x*g.y*g.z +
            c111*g.x*g.y*g.z;
    }

    // This is annoying but I'm not going to fight with this weak-ass C# type system to make a generic method.
    // Code stays exactly the same, only thing that's changed is the type of the method.
    public static Vector3 SampleInterpolatedVectorArray(Vector3[,] m0, Vector3[,] m1, float t, Vector2 p) {
        var c000 = m0[Mathf.FloorToInt(p.x), Mathf.FloorToInt(p.y)];
        var c100 = m0[Mathf.CeilToInt(p.x), Mathf.FloorToInt(p.y)];
        var c010 = m0[Mathf.FloorToInt(p.x), Mathf.CeilToInt(p.y)];
        var c110 = m0[Mathf.CeilToInt(p.x), Mathf.CeilToInt(p.y)];
        var c001 = m1[Mathf.FloorToInt(p.x), Mathf.FloorToInt(p.y)];
        var c101 = m1[Mathf.CeilToInt(p.x), Mathf.FloorToInt(p.y)];
        var c011 = m1[Mathf.FloorToInt(p.x), Mathf.CeilToInt(p.y)];
        var c111 = m1[Mathf.CeilToInt(p.x), Mathf.CeilToInt(p.y)];

        Vector3 g = new Vector3(p.x - (float)Math.Truncate(p.x), p.y - (float)Math.Truncate(p.y), 1-t);
        Vector3 f = new Vector3(1, 1, 1) - g;

        return
            c000*f.x*f.y*f.z +
            c100*g.x*f.y*f.z +
            c010*f.x*g.y*f.z +
            c110*g.x*g.y*f.z +
            c001*f.x*f.y*g.z +
            c101*g.x*f.y*g.z +
            c011*f.x*g.y*g.z +
            c111*g.x*g.y*g.z;
    }

    /// <summary>
    /// Given a normal expressed as Vector3, encodes it into 3 bytes.
    /// </summary>
    /// <param name="n">The normal. If this vector is not a normal (i.e. not of length 1), the return value is undefined.</param>
    /// <returns>A byte triple encoding of the normal.</returns>
    public static (byte, byte, byte) EncodeNormalizedVector(Vector3 n) {
        n = 0.5f*n + new Vector3(0.5f, 0.5f, 0.5f);
        n *= 255;
        return (Convert.ToByte(n.x), Convert.ToByte(n.y), Convert.ToByte(n.z));
    }

    /// <summary>
    /// Given a normal encoded into 3 bytes, decodes it into Vector3.
    /// </summary>
    /// <param name="r">Byte encoding the X component</param>
    /// <param name="g">Byte encoding the Y component</param>
    /// <param name="b">Byte encoding the Z component</param>
    /// <returns>A vector containing the decoded normal.</returns>
    public static Vector3 DecodeVector3(byte r, byte g, byte b) {
        var n = new Vector3(r, g, b);
        const float inv = 2f / 255f;
        n *= inv;
        n = n - Vector3.one;
        return n;
    }

    /// <summary>
    /// Samples a matrix at a given position (mostly used for debugging)
    /// </summary>
    /// <param name="matrix"></param>
    /// <param name="pos"></param>
    /// <returns></returns>
    public static float SampleMatrix(Matrix matrix, Vector2 pos)
    {
        // There are four pieces of data
        // Our position is in an arbitray location between these corners
        var c00 = matrix[Mathf.FloorToInt(pos.x), Mathf.FloorToInt(pos.y)];   // (0, 0)
        var c10 = matrix[Mathf.CeilToInt(pos.x), Mathf.FloorToInt(pos.y)];    // (1, 0)
        var c01 = matrix[Mathf.FloorToInt(pos.x), Mathf.CeilToInt(pos.y)];   // (0, 1)
        var c11 = matrix[Mathf.CeilToInt(pos.x), Mathf.CeilToInt(pos.y)];    // (1, 1)

        // X component
        var x_comp = pos.x % 1f;
        var y_comp = pos.y % 1f;

        // Using unit square bilinear interpolation
        var result = c00 * (1f - x_comp) * (1 - y_comp) + c10 * x_comp * (1 - y_comp) + c01 * (1 - x_comp) * y_comp + c11 * x_comp * y_comp;
        return result;
    }

    public static Task ParallelForAsync(int start, int max, int poolSize, Action<int> f) {
        var pools = (max-start) / poolSize + 1;
        var tasks = new Task[pools];

        for (int p = 0; p < pools; p++) {
            var lp = p;
            tasks[p] = Task.Factory.StartNew(() => {
                var lower = start + lp*poolSize;
                var upper = Mathf.Min(start + (lp+1)*poolSize, max);
                for (int i = lower; i < upper; i++)
                    f(i);
            });
        }

        return Task.Factory.StartNew(() => Task.WaitAll(tasks));
    }
}
