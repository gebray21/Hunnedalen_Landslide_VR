using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrafficMapNode : MonoBehaviour
{

    public Transform goToNode = null;
    public Transform goToNode2 = null;
    public Transform goFarNode = null;
    public Transform thisNode = null;
    public Transform currentCar = null;
    public bool teleportToNode = false;

    // Start is called before the first frame update
    void Start()
    {
        thisNode = this.transform;
    }

    // Update is called once per frame
    /*void Update()
    {
        
    }*/

    public Transform GetThisNode()
    {
        if (thisNode == null)
        {
            thisNode = this.transform;
        }
        return thisNode;
    }

    public Transform GetFarNode()
    {
        if (goFarNode == null)
        {
            goFarNode = goToNode;
        }
        return goFarNode;
    }
}
