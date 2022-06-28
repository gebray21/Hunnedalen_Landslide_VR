using UnityEngine;

public class TerrainImportTool : MonoBehaviour {
    public enum HeightmapResolutions {
        _32 = 32,
        _64 = 64,
        _128 = 128,
        _256 = 256,
        _512 = 512,
        _1024 = 1024,
        _2048 = 2048,
        _4096 = 4096
    }

    [Tooltip("File to load")]
    [SerializeField] private string InputFile;

    [Tooltip("Resolution of the .raw heightmap. Only power of 2 in the range [32...4098] are allowed and the result is a square heightmap.")]
    [SerializeField] HeightmapResolutions Resolution;

    [Tooltip("Value to be used for cells with missing data")]
    [SerializeField] int NoDataValue = 0;

    [Tooltip("Width of the terrain")]
    [SerializeField] float Width;

    [Tooltip("Breadth of the terrain")]
    [SerializeField] float Length;

    [Tooltip("This is required by the Unity terrain component and needs to be set to the highest value the entire terrain can obtain. For 16-bit formats, with Scaling of 100, that is 65535/100.")]
    [SerializeField] float MaximumHeight = 65535 / 100f;

    [Tooltip("Where to store the .raw heightmap before loading it into the Unity terrain component")]
    [SerializeField] private string OutputFile;

    [Tooltip("Terrain to load height data into. If empty, a new one will be created.")]
    [SerializeField] public Terrain TargetTerrain;

    [Tooltip("If enabled, transposes the heightmap matrix, essentially flipping the terrain along the diagonal.")]
    [SerializeField] public bool TransposeTerrain = true;

    [Tooltip("If enabled, mirrors the terrain along the X axis.")]
    [SerializeField] public bool MirrorX = true;

    [Tooltip("If enabled, mirrors the terrain along the Y axis.")]
    [SerializeField] public bool MirrorY = false;
}
