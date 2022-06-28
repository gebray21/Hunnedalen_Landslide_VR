using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class erosionScript : MonoBehaviour
{
   
    // Bool decides if it should start
    public bool start = false;

    public float dynamicAcc;
    public float timer;
    public float stopTimer = 50f;
    //public GameObject Landslide;
    public GameObject stones;
    public float erosionSpeed;
    public Vector3 erosionDirection;
    public float rotationSpeed;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (dynamicAcc <= 10f )
        {
            dynamicAcc += Time.deltaTime / 5f;
        }
        timer += Time.deltaTime;


    }
    
    void FixedUpdate()
    {    
        if ( timer<= stopTimer)
        {
            MoveTerrain();
        }
    }
    
    void MoveTerrain()
    {
        if (stones.transform.parent != transform.root)
        {
            stones.transform.parent = transform.root;
        }
        transform.position += (erosionDirection * erosionSpeed * dynamicAcc);
       
    }
}
