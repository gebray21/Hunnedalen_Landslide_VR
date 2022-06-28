using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrafficMapMove : MonoBehaviour
{

    public TrafficMapNode currentNode = null;

    // Start is called before the first frame update
    void Start()
    {
        if (currentNode == null)
        {
            // search through all nodes to know which is cloest to car at the start
            TrafficMapNode[] nodeList = GameObject.FindObjectsOfType<TrafficMapNode>();
            float nearestDistance = 9999;
            TrafficMapNode nearestNode = nodeList[0];
            for (int i = 0; i < nodeList.Length; i++)
            {
                if (Vector3.Distance(nodeList[i].GetThisNode().position,this.transform.position) < nearestDistance)
                {
                    nearestDistance = Vector3.Distance(nodeList[i].GetThisNode().position, this.transform.position);
                    nearestNode = nodeList[i];
                }

            }
            currentNode = nearestNode;
        }

        nextNode = currentNode;
        currentNode.currentCar = this.transform;

        aniController = this.GetComponent<Animator>();

        originalSpeed = speed;

    }

    public TrafficMapNode nextNode = null;
    public float distanceInTime = 1f;
    private float currentTime = 0f;
    public float speed = 5f;
    float originalSpeed = 5f;
    public float worldSpeed = 1f;
    public bool rotateToNextNode = false;
    public float rotateSpeed = 10f;
    public float nearEnough = 0.2f;

    public Transform[] rotateTires;

    private Animator aniController = null;

    // Update is called once per frame
    void Update()
    {
        UpdateMove();
    }

    private bool isVisible = true;
    private void OnBecameInvisible()
    {
        isVisible = false;
    }

    private void OnBecameVisible()
    {
        isVisible = true;
    }

    public int idleVar = -1;
    public int runAwayState = 0;

    public void UpdateMove()
    {
        if (isVisible == false)
        {
            return;
        }

        if (runAwayState > 0)
        {
            UpdateRunAwayState();
            return;
        }

        // if, accidently, 2+ cars are in the same space, only move 1 at a time to spread them out again
        if (currentNode.currentCar != this.transform)
        {
            if (currentNode.currentCar == null)
            {
                currentNode.currentCar = this.transform;
            } else
            {
                if (aniController != null)
                {
                    aniController.SetInteger("IdleVar", 1);
                    idleVar = 1;
                }
            }
            return;
        }

        // if "currentNode" is not enabled, find next available "nextNode" to move to
        if (currentNode.GetThisNode().gameObject.activeInHierarchy == false)
        {
            //distanceInTime = 0.5f;
            nextNode = currentNode.GetFarNode().GetComponent<TrafficMapNode>();
            this.transform.position
                    = Vector3.Lerp(this.transform.position, nextNode.GetThisNode().position, 0.1f);
            if (Vector3.Distance(this.transform.position, nextNode.GetThisNode().position) < nearEnough)
            {
                currentNode.currentCar = null;
                currentNode = nextNode;
                if (currentNode.currentCar == null)
                {
                    currentNode.currentCar = this.transform;
                }
                if (currentNode.goToNode.GetComponent<TrafficMapNode>().currentCar != null)
                {
                    if (aniController != null)
                    {
                        aniController.SetInteger("IdleVar", 1);
                        idleVar = 1;
                    }
                    return;
                }
                nextNode = currentNode.goToNode.GetComponent<TrafficMapNode>();
                if (currentNode.teleportToNode == true)
                {
                    this.transform.position = nextNode.transform.position;
                }
                else
                {
                    distanceInTime = Vector3.Distance(currentNode.GetThisNode().position, nextNode.GetThisNode().position) * (1f / speed * worldSpeed);
                    currentTime = 0f;
                    if (nextNode.currentCar != this.transform)
                    {
                        if (nextNode.currentCar == null)
                        {
                            nextNode.currentCar = this.transform;
                        }
                        return;
                    }
                    this.transform.position
                        = Vector3.Lerp(currentNode.GetThisNode().position, nextNode.GetThisNode().position, currentTime / distanceInTime);
                }
            }
            return;
            /*currentNode = currentNode.goToNode.GetComponent<TrafficMapNode>();
             currentNode.currentCar = this.transform;
             if (currentNode.goToNode.GetComponent<TrafficMapNode>().currentCar != null)
             {
                return;
             }
             nextNode = currentNode.goToNode.GetComponent<TrafficMapNode>();
             distanceInTime = 0.5f;*/
        }

        // if "nextNode" is not enabled, don't move
        if (nextNode.GetThisNode().gameObject.activeInHierarchy == false)
        {
            if (aniController != null)
            {
                aniController.SetInteger("IdleVar", 1);
                idleVar = 1;
                /*Debug.Log(aniController.GetCurrentAnimatorStateInfo(0).fullPathHash + " == " + Animator.StringToHash("HumanoidWalk"));
                if (aniController.GetCurrentAnimatorStateInfo(0).fullPathHash == Animator.StringToHash("HumanoidWalk"))
                {
                    aniController.SetTrigger(Animator.StringToHash("HumanoidIdle"));
                }*/
            }
            return;
        }
        if (aniController != null)
        {
            aniController.SetInteger("IdleVar", 0);
            idleVar = 0;
            /*if (aniController.GetCurrentAnimatorStateInfo(0).fullPathHash == Animator.StringToHash("HumanoidIdle"))
            {
                aniController.SetTrigger(Animator.StringToHash("HumanoidWalk"));
            }*/
        }

        // else, check if you've already reached the "nextNode," if so, update to find next node to go to
        currentTime += Time.deltaTime;
        if (Vector3.Distance(this.transform.position, nextNode.GetThisNode().position) < nearEnough)
        {
            currentNode.currentCar = null;
            currentNode = nextNode;
            if (currentNode.currentCar == null)
            {
                currentNode.currentCar = this.transform;
            }
            if (currentNode.goToNode2 != null)
            {
                int randNum = Random.Range(0, 2);
                if (randNum == 0)
                {
                    if (currentNode.goToNode.GetComponent<TrafficMapNode>().currentCar != null)
                    {
                        if (aniController != null)
                        {
                            aniController.SetInteger("IdleVar", 1);
                            idleVar = 1;
                        }
                        return;
                    }
                    nextNode = currentNode.goToNode.GetComponent<TrafficMapNode>();
                    if (nextNode.currentCar == null)
                    {
                        nextNode.currentCar = this.transform;
                    }
                } else if (randNum == 1)
                {
                    if (currentNode.goToNode2.GetComponent<TrafficMapNode>().currentCar != null)
                    {
                        if (aniController != null)
                        {
                            aniController.SetInteger("IdleVar", 1);
                            idleVar = 1;
                        }
                        return;
                    }
                    nextNode = currentNode.goToNode2.GetComponent<TrafficMapNode>();
                    if (nextNode.currentCar == null)
                    {
                        nextNode.currentCar = this.transform;
                    }
                }
            }
            else
            {
                if (currentNode.goToNode.GetComponent<TrafficMapNode>().currentCar != null)
                {
                    if (aniController != null)
                    {
                        aniController.SetInteger("IdleVar", 1);
                        idleVar = 1;
                    }
                    return;
                }
                nextNode = currentNode.goToNode.GetComponent<TrafficMapNode>();
                if (nextNode.currentCar == null)
                {
                    nextNode.currentCar = this.transform;
                }
            }
            if (currentNode.teleportToNode == true)
            {
                this.transform.position = nextNode.transform.position;
            }
            else
            {
                float randomMultiplier = Random.Range(0.8f, 1.2f);
                distanceInTime
                    = Vector3.Distance(currentNode.GetThisNode().position,
                    nextNode.GetThisNode().position)
                    * (1f / speed * worldSpeed) * randomMultiplier;

                currentTime = 0f;

                if (nextNode.currentCar != this.transform)
                {
                    if (nextNode.currentCar == null)
                    {
                        nextNode.currentCar = this.transform;
                    }
                    return;
                }

                this.transform.position
                    = Vector3.Lerp(currentNode.GetThisNode().position, nextNode.GetThisNode().position, currentTime / distanceInTime);
            }
            return;
        }

        // else, move towards the next node
        if (nextNode.currentCar != this.transform)
        {
            if (nextNode.currentCar == null)
            {
                nextNode.currentCar = this.transform;
            }
            return;
        }
        this.transform.position
            = Vector3.Lerp(currentNode.GetThisNode().position, nextNode.GetThisNode().position, currentTime / distanceInTime);
        if (rotateToNextNode == true)
        {
            Vector3 lookPos = nextNode.transform.position - this.transform.position;
            lookPos = new Vector3(lookPos.x, 0f, lookPos.z);
            Quaternion newRotation = Quaternion.LookRotation(lookPos);
            this.transform.rotation = Quaternion.Lerp(this.transform.rotation, newRotation, Time.deltaTime * rotateSpeed);
        }
        for (int i = 0; i < rotateTires.Length; i++)
        {
            rotateTires[i].Rotate(new Vector3(Time.deltaTime * 1000f, 0, 0));
        }
        return;
    }

    public void ResetNextNodeSpeed()
    {
        distanceInTime
                    = Vector3.Distance(currentNode.GetThisNode().position,
                    nextNode.GetThisNode().position)
                    * (1f / speed * worldSpeed);
    }

    public void UpdateSpeed(float newSpeed)
    {
        worldSpeed = 1.0f / newSpeed;

        if (aniController != null)
        {
            aniController.speed = newSpeed;
        }
    }

    public void UpdateAniSpeed(float newSpeed)
    {
        if (aniController != null)
        {
            aniController.speed = newSpeed;
        }
    }

    Vector3 runAwayPosition = Vector3.zero;
    Vector3 previousRunAwayPosition = Vector3.zero;
    float runAwayTime = 0f;

    public void SetRunAwayState()
    {
        if (aniController != null)
        {
            Debug.Log("SetRunAwayState called for a person!");
            /* Generate position to run to, if near a collapsing building
                How to know if we are near a collapsing building? 
                1) If "nextNode" or "next -> nextNode" or "next -> next -> nextNode" are newly disabled, then generate position in opposite direction of nextNode.
                2) If "currentNode" is newly disabled, then generate position in same direction as nextNode. 
                3) Else, ignore and don't set this state.
            */
            /*bool forwardBlocked = false;
            bool backwardBlocked = false;
            if (currentNode.GetThisNode().gameObject.activeInHierarchy == false)
            {
                backwardBlocked = true;
            }
            if (currentNode.goToNode.gameObject.activeInHierarchy == false 
                || currentNode.goToNode.GetComponent<TrafficMapNode>().goToNode.gameObject.activeInHierarchy == false
                || currentNode.goToNode.GetComponent<TrafficMapNode>().goToNode.GetComponent<TrafficMapNode>().goToNode.gameObject.activeInHierarchy == false
                || currentNode.goToNode.GetComponent<TrafficMapNode>().goToNode.GetComponent<TrafficMapNode>().goToNode.GetComponent<TrafficMapNode>().goToNode.gameObject.activeInHierarchy == false)
            {
                forwardBlocked = true;
            }
            if (backwardBlocked == true)
            {
                currentNode.currentCar = null;
                currentNode = currentNode.goToNode.GetComponent<TrafficMapNode>();
                currentNode.currentCar = this.transform;
                runAwayPosition = currentNode.transform.position + new Vector3(Random.Range(-2f, 2f), 0f, Random.Range(-2f, 2f));
                previousRunAwayPosition = this.transform.position;
                distanceInTime = Vector3.Distance(previousRunAwayPosition, runAwayPosition) * (1f / speed * 1.5f * worldSpeed);
                currentTime = 0f;

                runAwayState = 1;
                aniController.SetInteger("IdleVar", 2);
                idleVar = 2;

            } else if (forwardBlocked == true)
            {
                runAwayPosition = currentNode.transform.position + new Vector3(Random.Range(-3f, 3f), 0f, Random.Range(-3f, 3f));
                previousRunAwayPosition = this.transform.position;
                distanceInTime = Vector3.Distance(previousRunAwayPosition, runAwayPosition) * (1f / speed * 1.5f * worldSpeed);
                currentTime = 0f;

                runAwayState = 1;
                aniController.SetInteger("IdleVar", 2);
                idleVar = 2;
            }*/
            /*if (currentNode.GetThisNode().gameObject.activeInHierarchy == false)
            {
                runAwayPosition = currentNode.goToNode.transform.position + this.transform.forward*2f + new Vector3(Random.Range(-3f, 3f), 0f, Random.Range(-3f, 3f));
                currentNode.currentCar = null;
                currentNode = currentNode.goToNode.GetComponent<TrafficMapNode>();
                currentNode.currentCar = this.transform;
            }
            else
            {
                runAwayPosition = currentNode.transform.position + this.transform.forward*2f + new Vector3(Random.Range(-3f, 3f), 0f, Random.Range(-3f, 3f));
            }
            previousRunAwayPosition = this.transform.position;
            distanceInTime = Vector3.Distance(previousRunAwayPosition, runAwayPosition) * (1f / speed * 0.5f * worldSpeed);
            currentTime = 0f;

            runAwayState = 1;
            aniController.SetInteger("IdleVar", 2);
            idleVar = 2;*/
            bool forwardBlocked = false;
            bool backwardBlocked = false;
            if (currentNode.GetThisNode().gameObject.activeInHierarchy == false)
            {
                backwardBlocked = true;
            }
            if (currentNode.goToNode.gameObject.activeInHierarchy == false
                || currentNode.goToNode.GetComponent<TrafficMapNode>().goToNode.gameObject.activeInHierarchy == false
                || currentNode.goToNode.GetComponent<TrafficMapNode>().goToNode.GetComponent<TrafficMapNode>().goToNode.gameObject.activeInHierarchy == false
                || currentNode.goToNode.GetComponent<TrafficMapNode>().goToNode.GetComponent<TrafficMapNode>().goToNode.GetComponent<TrafficMapNode>().goToNode.gameObject.activeInHierarchy == false)
            {
                forwardBlocked = true;
            }
            if (backwardBlocked == true)
            {
                currentNode.currentCar = null;
                currentNode = currentNode.goToNode.GetComponent<TrafficMapNode>();
                currentNode.currentCar = this.transform;
                runAwayPosition = currentNode.transform.position + new Vector3(Random.Range(-1f, 1f), 0f, Random.Range(-1f, 1f));
                previousRunAwayPosition = this.transform.position;
                distanceInTime = Vector3.Distance(previousRunAwayPosition, runAwayPosition) * (1f / speed * 0.5f * worldSpeed);
                currentTime = 0f;

                runAwayState = 1;
                aniController.SetInteger("IdleVar", 2);
                idleVar = 2;
                runAwayTime = 0f;

            }
            else if (forwardBlocked == true)
            {
                runAwayPosition = currentNode.transform.position + (-this.transform.forward * 6f) + new Vector3(Random.Range(-1f, 1f), 0f, Random.Range(-1f, 1f));
                previousRunAwayPosition = this.transform.position;
                distanceInTime = Vector3.Distance(previousRunAwayPosition, runAwayPosition) * (1f / speed * 0.5f * worldSpeed);
                currentTime = 0f;

                runAwayState = 2;
                aniController.SetInteger("IdleVar", 2);
                idleVar = 2;
                runAwayTime = 0f;
            } else
            {
                currentNode.currentCar = null;
                currentNode = currentNode.goToNode.GetComponent<TrafficMapNode>();
                currentNode.currentCar = this.transform;
                runAwayPosition = currentNode.transform.position + new Vector3(Random.Range(-1f, 1f), 0f, Random.Range(-1f, 1f));
                previousRunAwayPosition = this.transform.position;
                distanceInTime = Vector3.Distance(previousRunAwayPosition, runAwayPosition) * (1f / speed * 0.5f * worldSpeed);
                currentTime = 0f;

                runAwayState = 1;
                aniController.SetInteger("IdleVar", 2);
                idleVar = 2;
                runAwayTime = 0f;
            }
        }
    }

    public void UpdateRunAwayState()
    {
        /*
         *  0) Repeat 1),2) a second time before 3) (collapsing buildings also have delay; else, people run and walk again before building has collapsed)
            1) Move towards generated position to run to.
            2) When position is reached, walk towards "currentNode" that was previously used.
            3) When position of current node is reached, turn off this state and continue with normal logic.
         */
        currentTime += Time.deltaTime;
        runAwayTime += Time.deltaTime;

        if ((runAwayState == 1 || runAwayState == 2) && runAwayTime > 8f)
        {
            aniController.SetInteger("IdleVar", 1);
            idleVar = 1;
            runAwayState = 3;

            runAwayPosition = currentNode.transform.position;
            previousRunAwayPosition = this.transform.position;
            distanceInTime = Vector3.Distance(previousRunAwayPosition, runAwayPosition) * (1f / speed * worldSpeed);
            currentTime = 0f;
            runAwayTime = 0f;
        }

        if (runAwayState == 1)
        {
            // if moving forward, follow node path. Else, go back to current node.
            this.transform.position
                = Vector3.Lerp(previousRunAwayPosition, runAwayPosition, currentTime / distanceInTime);
            if (rotateToNextNode == true)
            {
                Vector3 lookPos = runAwayPosition - this.transform.position;
                lookPos = new Vector3(lookPos.x, 0f, lookPos.z);
                Quaternion newRotation = Quaternion.LookRotation(lookPos);
                this.transform.rotation = Quaternion.Lerp(this.transform.rotation, newRotation, Time.deltaTime * rotateSpeed);
            }
            if (Vector3.Distance(this.transform.position, runAwayPosition) < nearEnough)
            {
                currentNode.currentCar = null;
                currentNode = currentNode.goToNode.GetComponent<TrafficMapNode>();
                currentNode.currentCar = this.transform;

                runAwayPosition = currentNode.transform.position + new Vector3(Random.Range(-1f, 1f), 0f, Random.Range(-1f, 1f));
                previousRunAwayPosition = this.transform.position;
                distanceInTime = Vector3.Distance(previousRunAwayPosition, runAwayPosition) * (1f / speed * 0.5f * worldSpeed);
                currentTime = 0f;
            }
        }
        else if (runAwayState == 2)
        {
            // else, run back to current node.
            this.transform.position
                 = Vector3.Lerp(previousRunAwayPosition, runAwayPosition, currentTime / distanceInTime);
            if (rotateToNextNode == true)
            {
                Vector3 lookPos = runAwayPosition - this.transform.position;
                lookPos = new Vector3(lookPos.x, 0f, lookPos.z);
                Quaternion newRotation = Quaternion.LookRotation(lookPos);
                this.transform.rotation = Quaternion.Lerp(this.transform.rotation, newRotation, Time.deltaTime * rotateSpeed);
            }
            if (Vector3.Distance(this.transform.position, runAwayPosition) < nearEnough)
            {
                runAwayPosition = currentNode.transform.position;
                previousRunAwayPosition = this.transform.position;
                distanceInTime = Vector3.Distance(previousRunAwayPosition, runAwayPosition) * (1f / speed * 0.5f * worldSpeed);
                currentTime = 0f;
            }
        }
        else if (runAwayState == 3)
        {
            // walk calmly back to current node.
            this.transform.position
                = Vector3.Lerp(previousRunAwayPosition, runAwayPosition, currentTime / distanceInTime);
            if (rotateToNextNode == true)
            {
                Vector3 lookPos = runAwayPosition - this.transform.position;
                lookPos = new Vector3(lookPos.x, 0f, lookPos.z);
                Quaternion newRotation = Quaternion.LookRotation(lookPos);
                this.transform.rotation = Quaternion.Lerp(this.transform.rotation, newRotation, Time.deltaTime * rotateSpeed);
            }
            if (Vector3.Distance(this.transform.position, runAwayPosition) < nearEnough)
            {
                currentTime = 0f;
                runAwayState = 0;

                nextNode = currentNode.goToNode.GetComponent<TrafficMapNode>() ;
                distanceInTime = Vector3.Distance(currentNode.transform.position, nextNode.transform.position) * (1f / speed * worldSpeed);

            }

        }
    }

    public void SimpleSetRunAwayState(bool turnOn)
    {
        if (turnOn == true)
        {
            runAwayState = 1;
            aniController.SetInteger("IdleVar", 2);
            idleVar = 2;
            speed = originalSpeed * 2f;
        } else
        {
            runAwayState = 0;
            aniController.SetInteger("IdleVar", 0);
            idleVar = 0;
            speed = originalSpeed;
        }
    }
}
