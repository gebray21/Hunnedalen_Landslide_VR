using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using TMPro;
using System;

public class MainMenu : MonoBehaviour
{

    public static MainMenu Instance;
    public TMP_Text debugText;
    public TMP_Text settingsText;
    public GameObject loadingPanel;
    // public GameObject creditsPanel;
    // public bool creditsVisible = false;
    //public GameObject[] scenePictures;

    public string sceneLoad = ""; //default is the desktop version 
    private float loadProgress = 0f;
    private string settingsString = "(Default)";
    private string settingsLoadString = "(none)";
    private GameObject myEditorPlayer;
    private GameObject myXRPlayer;
    private GameObject myGraphics;
    private PlayerEffects playersEffects;
    private Transform[] allChildren;


    void Awake()
    {
        /*  if (Instance == null)
          {
              Instance = this;
              DontDestroyOnLoad(gameObject);
          }
          else
          {
              Destroy(gameObject);
          }
        */
        myEditorPlayer = GameObject.Find("EditorPlayer");
        myXRPlayer = GameObject.Find("XRPlayerRig");
        myGraphics = GameObject.Find("Performance");
        if (myEditorPlayer!=null)
       allChildren = myEditorPlayer.GetComponentsInChildren<Transform>();
        
        Scene scene = SceneManager.GetActiveScene();
        playersEffects = GameObject.FindObjectOfType<PlayerEffects>(includeInactive: true);
       if (scene.name == "MainMenu")
       {
            //  playersEffects.enabled = false;
            if (myEditorPlayer != null)
                Destroy(myEditorPlayer);
            if (myGraphics != null)
                Destroy(myGraphics);
            if (myXRPlayer != null)
                Destroy(myXRPlayer);
        }
           
           
    }

    // Start is called before the first frame update
    void Start()
    {
        int qualitySetting = PlayerPrefs.GetInt("QualitySetting", 3);
        if (qualitySetting == 0)
        {
            settingsText.text = "Selected Setting: Low";
        }
        else if (qualitySetting == 1)
        {
            settingsText.text = "Selected Setting: Medium";
        }
        else if (qualitySetting == 2)
        {
            settingsText.text = "Selected Setting: High";
        }
        else if (qualitySetting == 3)
        {
            settingsText.text = "Selected Setting: Ultra";
        }
    }

    // progress loading 
    int loadingDots = 0;
    bool isLoading = false;
    float totalTime = 0f;
    int totalLoadingSeconds = 0;

    // Update is called once per frame
    void Update()
    {

        if (isLoading == true)
        {
            totalTime += Time.deltaTime;
            if (totalTime > 1f)
            {
                totalTime = 0f;
                loadingDots++;
                totalLoadingSeconds++;
            }
            if (loadingDots > 3)
            {
                loadingDots = 1;
            }
            debugText.text = "Loading";
            for (int i = 0; i < loadingDots; i++)
            {
                debugText.text += ".";
            }
            debugText.text += "\n" + ((loadProgress) * 100f).ToString("0.00") + "%";
            //debugText.text += "\n" + totalLoadingSeconds + " seconds...";
        }
        
    }

    //Graphics Quality using Dropdown menu
    public void SetQuality(int qualityIndex)
    {
        QualitySettings.SetQualityLevel(qualityIndex);
    }
   
    //Graphics Quality using Buttuns 

    public void SetLowQuality()
    {
        QualitySettings.SetQualityLevel(0, true);
        PlayerPrefs.SetInt("QualitySetting", 0);

        settingsString = "Low Qual.";
        UpdateSettingsText();
    }

    public void SetMediumQuality()
    {
        QualitySettings.SetQualityLevel(1, true);
        PlayerPrefs.SetInt("QualitySetting", 1);

        settingsString = "Medium Qual.";
        UpdateSettingsText();
    }

    public void SetHighQuality()
    {
        QualitySettings.SetQualityLevel(2, true);
        PlayerPrefs.SetInt("QualitySetting", 2);

        settingsString = "High Qual.";
        UpdateSettingsText();
    }

    public void SetUltraQuality()
    {
        QualitySettings.SetQualityLevel(3, true);
        PlayerPrefs.SetInt("QualitySetting", 3);

        settingsString = "Ultra Qual.";
        UpdateSettingsText();
    }

    public void LaunchDesktopScene()
    {
        //debugText.text = "Loading...";
        //SceneManager.LoadScene("XR_Demo_01_20200509");
        sceneLoad = "Hunnedalen_DSK";
        settingsLoadString = "Scene DSK";
        UpdateSettingsText();
    }
    public void LaunchVRScene()
    {
        sceneLoad = "Hunnedalen_VR";
        settingsLoadString = "Scene VR";
        UpdateSettingsText();
    }

    public void UpdateSettingsText()
    {
        settingsText.text = "" + settingsLoadString + ",\n" + settingsString;
    }

  /*  public void OpenCredits()
    {
        creditsPanel.SetActive(true);
        creditsVisible = true;
    }
*/
    public void Launch()
    {
        debugText.text = "Processing...";
        //SceneManager.LoadScene(sceneLoad);
        isLoading = true;
        loadingPanel.SetActive(true);
        QualitySettings.asyncUploadTimeSlice = 32;
        StartCoroutine(LoadAsyncScene());
    }

    IEnumerator LoadAsyncScene()
    {
        AsyncOperation asyncLoad = SceneManager.LoadSceneAsync(sceneLoad);
        asyncLoad.allowSceneActivation = false;

        while (!asyncLoad.isDone)
        {
            loadProgress = asyncLoad.progress;
            if (asyncLoad.progress >= 0.9f)
            {
                asyncLoad.allowSceneActivation = true;
            }
                yield return null;
        }
    }

    public void CloseApp()
    {
        Application.Quit();
    }
}
