using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TerrainEdit : MonoBehaviour
{
    public Terrain terrain;
    private TerrainData terrainData;
    // Start is called before the first frame update
  
    void Start()
    {
        terrainData = terrain.terrainData;
       
        Debug.Log(terrainData.size.x);

    }

    // Update is called once per frame
    void Update()
    {
        
        editTerrain();
    }

    private void editTerrain()
    {

        int heightmapWidth = terrainData.heightmapResolution; //terrainData.size.x;
        int heightmapHeight = terrainData.heightmapResolution;
        float[,] heights= terrainData.GetHeights(0,0,heightmapWidth,heightmapHeight);
        for (int z = 0; z < heightmapHeight; z++)
        {
            for (int x=0; x < heightmapWidth; x++)
            {
                float cos = Mathf.Cos(x);
                float sin = Mathf.Sin(z);
                heights[x, z] = (cos - sin) / 150; 
            }
        }
        terrainData.SetHeights(0, 0, heights);
    }
}
