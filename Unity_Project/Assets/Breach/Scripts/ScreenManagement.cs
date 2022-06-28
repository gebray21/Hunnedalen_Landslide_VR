using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;



public class ScreenManagement : MonoBehaviour
{

   
    public bool uiPanelsActive = false;
    public GameObject[] toggleUIPanels;
    public int maxUpdatePerFrame = 8;
    public GameObject audioCarreir;
    private AudioSource audioSource;
    private bool toggleAudioOn = true;
    public GameObject buttonAudioOnImage;
    public GameObject buttonAudioOffImage;
    // Start is called before the first frame update
    void Start()
    {
    
        if (toggleUIPanels != null)
        {
            for (int i = 0; i < toggleUIPanels.Length; i++)
            {
                toggleUIPanels[i].SetActive(uiPanelsActive);
            }
        }

        audioSource = audioCarreir.GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void ToggleUIPanels()
    {
        uiPanelsActive = !uiPanelsActive;

        if (toggleUIPanels != null)
        {
            for (int i = 0; i < toggleUIPanels.Length; i++)
            {
                toggleUIPanels[i].SetActive(uiPanelsActive);
            }
        }
    }

   

    public void ToggleAudio()
    {
        toggleAudioOn = !toggleAudioOn;
        //if (pauseSystem == false)
            UpdateAudio(toggleAudioOn);
    }

    public void UpdateAudio(bool turnOnAudio)
    {
        if (turnOnAudio == true)
        {
            audioSource.Play();
            buttonAudioOnImage.SetActive(true);
            buttonAudioOffImage.SetActive(false);
        }
        else
        {
            audioSource.Stop();
            buttonAudioOnImage.SetActive(false);
            buttonAudioOffImage.SetActive(true);
        }
    }
    public void ExitSceneDSK()
    {
        // TODO: replace with go-to start menu in final application
        //Application.Quit();
        SceneManager.LoadScene("MainMenu");
    }
    public void ExitSceneVR()
    {
        // TODO: replace with go-to start menu in final application
        //Application.Quit();
        SceneManager.LoadScene("VRMenu");
    }
}
