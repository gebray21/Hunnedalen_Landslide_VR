using System;
using System.Runtime.Serialization;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class Matrix : ISerializable {

	private int n;
	private int m;
	private float[,] Me;

	public Matrix(int n, int m) {
		if (n <= 0 || m <= 0) {
			throw new ArgumentException("Matrix dimensions must be positive");
		}
		this.n = n;
		this.m = m;
		Me = new float[n, m];
	}

    public Matrix(float[] um) {
        if (um.Length <= 0) {
            throw new ArgumentException("Matrix dimensions must be positive");
        }
        this.n = um.Length;
        this.m = 1;
        Me = new float[n, m];
        for(int i = 0; i<n; i++) {
            Me[i, 0] = um[i];
        }
    }

    public Matrix (float[,] rawdata, int _n, int _m) {
        Me = rawdata;
        n = _n;
        m = _m;
    }

    public Matrix(Matrix other) : this(other.RawData.Clone() as float[,], other.N, other.M) {
    }


    public float[,] RawData {
        get => Me;
    }

    //indices start from one
    public float this[int i, int j] {
		get { return Me[i, j]; }
		set { Me[i, j] = value; }
	}

	public int N { get { return n; } }
	public int M { get { return m; } }


    // Sample value w/ bilinear interpolation
    public float Sample(float i, float j) {
        int i0 = Mathf.FloorToInt(i);
        int j0 = Mathf.FloorToInt(j);
        int i1 = Mathf.CeilToInt(i);
        int j1 = Mathf.CeilToInt(j);

        float x00 = Me[i0, j0];
        float x01 = Me[i0, j1];
        float x10 = Me[i1, j0];
        float x11 = Me[i1, j1];

        float di = i - i0;
        float dj = j - j0;

        return di*dj*x11 + di*(1-dj)*x10 + (1-di)*dj*x01 + (1-di)*(1-dj)*x00;
    }

    // Applies a function component-wise in-place.
    public void Map(Func<float, float> f) {
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < m; j++) {
                Me[i, j] = f(Me[i, j]);
            }
        }
    }

    // Applies a function component-wise, making a copy of the original data
    public static Matrix MapC(Matrix a, Func<int, int, float, float> f) {
        Matrix b = new Matrix(a.N, a.M);

        for (int i = 0; i < a.N; i++) {
            for (int j = 0; j < a.M; j++) {
                b[i, j] = f(i, j, a[i, j]);
            }
        }

        return b;
    }

    // ****** Binary Serialization ******
    public Matrix(SerializationInfo info, StreamingContext context) {
        n = info.GetInt32("n");
        m = info.GetInt32("m");

        float[] data = (float[]) info.GetValue("data", typeof(float[]));
        Me = new float[n, m];
        for (int i = 0; i < n; i++)
            for (int j = 0; j < m; j++)
                Me[i, j] = data[i*m + j];
    }

    public virtual void GetObjectData(SerializationInfo info, StreamingContext context) {
        info.AddValue("n", n);
        info.AddValue("m", m);

        float[] mat = new float[n*m];
        for (int i = 0; i < n; i++)
            for (int j = 0; j < m; j++)
                mat[i*m + j] = Me[i, j];
        info.AddValue("data", mat);
    }

    // ****** Static Functions ******
    public static Matrix MatrixMultiply(Matrix A, Matrix B) {
        Matrix c = new Matrix(A.N, B.M);
        if (A.M == B.N) {
            for (int i = 0; i < c.N; i++) {
                for (int j = 0; j < c.M; j++) {
                    c[i, j] = 0;
                    for (int k = 0; k < A.M; k++) { // OR k<b.GetLength(0)
                        c[i, j] += A[i, k] * B[k, j];
                    }
                }
            }
        } else {
            return null; //Console.WriteLine("\n Number of columns in First Matrix should be equal to Number of rows in Second Matrix.");
        }
        return c;
    }

    public static Matrix MatrixTranspose(Matrix m) {
        Matrix t = new Matrix(m.M, m.N);
        for (int i = 0; i < m.N; i++) {
            for (int j = 0; j < m.M; j++) {
                t[j, i] = m[i, j];
            }
        }
        return t;
    }

    public static Matrix IdentityMatrix(int a, int b) {
        Matrix M = new Matrix(a, b);
        for (int i = 0; i < M.N; i++) {
            for (int j = 0; j < M.M; j++) {
                if (i == j) {
                    M[i, j] = 1;
                } else {
                    M[i, j] = 0;
                }
            }
        }
        return M;
    }

    public static Matrix Add(Matrix A, Matrix B) {
        if (A.M == B.M && A.N == B.N) {
            Matrix a = new Matrix(A.N, A.M);
            for (int i = 0; i < A.N; i++) {
                for (int j = 0; j < A.M; j++) {
                    a[i, j] = A[i, j] + B[i, j];
                }
            }
            return a;
        } else {
            Debug.Log("Matrix not equal in size...");
            return null;
        }
    }

    public static Matrix Substract(Matrix A, Matrix B) {
        if (A.M == B.M && A.N == B.N) {
            Matrix a = new Matrix(A.N, A.M);
            for (int i = 0; i < A.N; i++) {
                for (int j = 0; j < A.M; j++) {
                    a[i, j] = A[i, j] - B[i, j];
                }
            }
            return a;
        } else {
            Debug.Log("Matrix not equal in size...");
            return null;
        }
    }

    // Scales a matrix. Mostly useful for scaling down to a smaller dimension, as it doesn't perform any interpolation.
    public static Matrix Scale(Matrix A, int newN, int newM) {
        Matrix B = new Matrix(newN, newM);
        Vector2 scale = new Vector2(A.N / (float)newN, A.M / (float)newM);
        for (int i = 0; i < newN; i++) {
            for (int j = 0; j < newM; j++) {
                B[i, j] = A[Mathf.RoundToInt(i*scale.x), Mathf.RoundToInt(j*scale.y)];
            }
        }
        return B;
    }

    // Scales a matrix, using bilinear filtering.
    public static Matrix ScaleBilinear(Matrix A, int newN, int newM) {
        Matrix B = new Matrix(newN, newM);
        Vector2 scale = new Vector2((A.N-1) / (float)newN, (A.M-1) / (float)newM);
        for (int i = 0; i < newN; i++)
            for (int j = 0; j < newM; j++)
                B[i, j] = A.Sample(i*scale.x, j*scale.y);
        return B;
    }

    // ****** Debug Functions ******

    public static void PrintMatrix(Matrix M) {
        string message = "";
        for (int i = 0; i < M.N; i++) {
            for (int j = 0; j < M.M; j++) {
                message += "," + M[i, j].ToString();
            }
            message += "\n";
        }
        Debug.Log(message);
    }

}
