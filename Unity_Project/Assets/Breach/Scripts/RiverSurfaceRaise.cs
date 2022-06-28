using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RiverSurfaceRaise : MonoBehaviour
{
   // private Transform riverPos;
    public float movementSpeed = 10f;
    private float time = 0;
    public Vector3 Pos;

    // Start is called before the first frame update
    void Start()
    {
        // riverPos = GameObject.Find("river").transform;
        Pos = transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        time += Time.deltaTime * movementSpeed;
        
       /* Pos.y =  1 * (1 - Mathf.Exp(-time));
        transform.position = Pos;*/
    }

    void FixedUpdate()
    {
        Pos.y = 1 * (1 - Mathf.Exp(-time));
        transform.position = Pos;
    }
}
