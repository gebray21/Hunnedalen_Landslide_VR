using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayAudio : MonoBehaviour
{
   private Rigidbody rb;
   private AudioSource audioSource;
   private float Speed;
   public AudioClip debrisFlowClip;
   public float debrisAudioDelayTime = 5f; //time of delay of the debris audio after the debris flow started
   private float debrisAudioStartTime; // total time before the audio stated 8 from the very begining)
    private float timing = 0f;

    private SimulationManager simulationManager;
    private EarlyWarning earlyWarning;
    // Start is called before the first frame update
    void Awake()
    {
        rb = GetComponent<Rigidbody>();
        rb.useGravity = false;
    }

    void Start()
    {
       
        audioSource = GetComponent<AudioSource>();
        simulationManager = GameObject.FindObjectOfType<SimulationManager>();
        earlyWarning = GameObject.FindObjectOfType<EarlyWarning>();
        debrisAudioStartTime = debrisAudioDelayTime + simulationManager.navigationTime + earlyWarning.earlyWarningTime;
        if (audioSource == null)
        {
            Debug.LogError("The AudioSource is empty");
        }
        else
        {
            audioSource.clip = debrisFlowClip;
        }
       audioSource.PlayDelayed(debrisAudioStartTime);

      
    }


    // Update is called once per frame

    float maxSpeed = 10.0f;
   
    //float newEnginePitch = Mathf.Lerp(_minEnginePitch, _maxEnginePitch, speedGearRatio);
    //engineSFX.pitch = newEnginePitch;
                
void Update()
    {
        timing += Time.deltaTime;
        if (timing >= debrisAudioStartTime)
        {
           rb.useGravity = true;
           Speed = rb.velocity.magnitude;
        }
        
        float speedRatio = 0.1f +0.09f*Speed;
        speedRatio = Mathf.Clamp(speedRatio, 0.0f, 1.0f);
        audioSource.volume = speedRatio;
       // Debug.Log(speedRatio);
    }
}
