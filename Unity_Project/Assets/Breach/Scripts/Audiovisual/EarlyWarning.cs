using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using System;

public class EarlyWarning : MonoBehaviour
{
    public GameObject UiObject; //warning canvas
    public GameObject[] ScreenInfo; //reference to the screen information 
    public float earlyWarningTime = 30f;
    public bool TimerOn = false;
    public TMP_Text TimerText;
    private float Timer=0f;
    private float timeLeft;
    void Start()
    {
        if (ScreenInfo != null)
        {
            for (int i = 0; i < ScreenInfo.Length; i++)
            {
                ScreenInfo[i].SetActive(false);
            }
        }       
        UiObject.SetActive(true);
        timeLeft = earlyWarningTime;
        TimerOn = true;
     }

    // Update is called once per frame
    void Update()
    {
       if (TimerOn)
       {
         if (Timer <= earlyWarningTime)
         {
            Timer += Time.deltaTime;
            timeLeft = earlyWarningTime - Timer;
            updateTimer(timeLeft);
         }
         else
         {
            UiObject.SetActive(false);
              for (int i = 0; i < ScreenInfo.Length; i++)
                {
                    ScreenInfo[i].SetActive(true);
                }
            }
         
       }                    
    }

    void updateTimer(float myTime)
    {
      myTime += 1;
        float minutes = Mathf.FloorToInt(myTime / 60);
        float seconds = Mathf.FloorToInt(myTime % 60);
        TimerText.text = string.Format("{0:00}:{1:00}", minutes, seconds);
    }

}

