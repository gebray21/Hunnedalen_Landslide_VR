using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using System;

public class Flickering : MonoBehaviour
{
    public bool isFlickering= false;
    public float delayRoadWarningTime = 30f; //time delay after which the warning should be applied
    private float startRoadWarningTime;
    public TMP_Text boardText;
    public GameObject leftLight;
    public GameObject rightLight;
    public float timeDelay=1f;
    private float currentTime =0f;
    private SimulationManager simulationManager;
    private EarlyWarning earlyWarning;
    private TrafficMapMove[] trafficMoveObjects;

    // Update is called once per frame

    void Start()
    {
        simulationManager = GameObject.FindObjectOfType<SimulationManager>();
        earlyWarning = GameObject.FindObjectOfType<EarlyWarning>();
        startRoadWarningTime = delayRoadWarningTime + simulationManager.navigationTime + earlyWarning.earlyWarningTime;
        trafficMoveObjects = GameObject.FindObjectsOfType<TrafficMapMove>();
    }
    void Update()
    {
        currentTime += Time.deltaTime;
        if (isFlickering == false && currentTime > startRoadWarningTime)
        {
            StartCoroutine(FlickeringLight());
        }
        if(currentTime > startRoadWarningTime)
        {
            for (int i = 0; i < trafficMoveObjects.Length; i++)
            {
                trafficMoveObjects[i].enabled = false;
            }
        }
        
        // Debug.Log($"current time is :{currentTime}");
    }
    IEnumerator FlickeringLight()
    {
        isFlickering = true;
        // this.gameObject.GetComponent<Light>().enabled = false;
        leftLight.GetComponent<Renderer>().enabled = true;
        rightLight.GetComponent<Renderer>().enabled = true;
        boardText.GetComponent<TextMeshProUGUI>().enabled = true;
        // timeDelay = Random.Range(0.01f, 0.5f);
        yield return new WaitForSeconds(timeDelay);
        //this.gameObject.GetComponent<Light>().enabled = true;
        leftLight.GetComponent<Renderer>().enabled = false;
        rightLight.GetComponent<Renderer>().enabled = false;
        boardText.GetComponent<TextMeshProUGUI>().enabled = false;
        //timeDelay = Random.Range(0.01f, 0.5f);
        yield return new WaitForSeconds(timeDelay);
        isFlickering = false;
    }
}
