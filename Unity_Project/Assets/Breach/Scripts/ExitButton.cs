using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class ExitButton : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void ExitScene()
    {
        // TODO: replace with go-to start menu in final application
        //Application.Quit();
        SceneManager.LoadScene("MainMenu");
    }
}
