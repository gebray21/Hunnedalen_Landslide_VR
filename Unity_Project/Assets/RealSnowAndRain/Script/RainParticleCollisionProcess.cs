using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//[ExecuteInEditMode]
public class RainParticleCollisionProcess : MonoBehaviour
{

    public enum intensity
    {
        VeryLight,
        Light,
        Moderate,
        Heavy,
        VeryHeavy,
        Stormy,
        VeryStormy,
        Custom
    }

    // public ParticleSystem RainParticle;

    public ParticleSystem.EmissionModule emissionModule;

    public ParticleSystem.VelocityOverLifetimeModule velocityOverLifetimeModule;

    public ParticleSystem.MainModule mainModule;

    public intensity Intensity;
    private intensity OldIntensity;

    public int CustomRateOverTime = 2000;

    /// <summary>
    /// //////////////////
    /// </summary>
    /// 
    public ParticleSystem particle1;

    public ParticleSystem RainWaterSplash;
    public ParticleSystem RainGroundSplash;

    List<ParticleCollisionEvent> collisionEvents;

    public float CollisionGap = 0;

    public bool UseReverseNormalDirection = true; 

    public GameObject FollowingCamera;
    private Vector3 DistanceFromCamera;


    // Start is called before the first frame update
    void Start()
    {
        particle1 = GetComponent<ParticleSystem>();
        collisionEvents = new List<ParticleCollisionEvent>();

        //////////////

        // SnowParticle.Stop();
        particle1.Clear();

        emissionModule = particle1.emission;
        velocityOverLifetimeModule = particle1.velocityOverLifetime;
        mainModule = particle1.main;

        OldIntensity = Intensity;

        ChangeIntensity();

        // mainModule.prewarm = true;

        particle1.Simulate(mainModule.duration);
        particle1.Play();

        if (FollowingCamera != null)
        {
            DistanceFromCamera = FollowingCamera.transform.position - this.transform.position;
        }
    }

    void OnParticleCollision(GameObject other)
    {

        int numCollisionEvents = 0;
        if (collisionEvents != null)
            numCollisionEvents = particle1.GetCollisionEvents(other, collisionEvents);

        int i = 0;
        while (i < numCollisionEvents)
        {
            if (other.layer == LayerMask.NameToLayer("ground"))
            {
                RainGroundSplash.transform.position = collisionEvents[i].intersection;
                

                RainGroundSplash.transform.TransformDirection( collisionEvents[i].normal);
                Quaternion Q = Quaternion.LookRotation((UseReverseNormalDirection ? 1 : -1) *  collisionEvents[i].normal);

                var main = RainGroundSplash.main;
                main.startRotationX = (Q.eulerAngles.x - 90) * Mathf.Deg2Rad;
                main.startRotationY = (Q.eulerAngles.y) * Mathf.Deg2Rad;
                // main.startRotationZ = Q.eulerAngles.z * Mathf.Deg2Rad;

                if (CollisionGap != 0)
                {
                    RainGroundSplash.transform.position += Q * Vector3.forward * CollisionGap;
                }
                RainGroundSplash.Emit(1);

            }
            else if (other.layer == LayerMask.NameToLayer("water"))
            {
                RainWaterSplash.transform.position = collisionEvents[i].intersection;

                RainWaterSplash.transform.TransformDirection(collisionEvents[i].normal);
                Quaternion Q = Quaternion.LookRotation(collisionEvents[i].normal);

                var main = RainWaterSplash.main;
                main.startRotationX = Q.eulerAngles.x * Mathf.Deg2Rad;
                main.startRotationY = Q.eulerAngles.y * Mathf.Deg2Rad;
                main.startRotationZ = Random.Range(-180f, 180f) * Mathf.Deg2Rad;

                if (CollisionGap != 0)
                {
                    RainWaterSplash.transform.position += Q * Vector3.forward * CollisionGap;
                }
                RainWaterSplash.Emit(1);

            }
            i++;
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (Intensity != OldIntensity)
        {
            ChangeIntensity();
            OldIntensity = Intensity;
        }

        if (Intensity == intensity.Custom && CustomRateOverTime != (int)emissionModule.rateOverTime.constant)
        {
            emissionModule.rateOverTime = CustomRateOverTime;
            CustomRateOverTime = (int)emissionModule.rateOverTime.constant;
        }

        if (FollowingCamera != null)
        {
            this.transform.position = FollowingCamera.transform.position - DistanceFromCamera;
        }

    }

    void ChangeIntensity()
    {
        switch (Intensity)
        {
            case intensity.VeryLight:
                emissionModule.rateOverTime = 300;
                break;

            case intensity.Light:
                emissionModule.rateOverTime = 600;
                break;

            case intensity.Moderate:
                emissionModule.rateOverTime = 1000;
                break;

            case intensity.Heavy:
                emissionModule.rateOverTime = 2000;
                break;

            case intensity.VeryHeavy:
                emissionModule.rateOverTime = 4000;
                break;

            case intensity.Stormy:
                emissionModule.rateOverTime = 6000;
                // velocityOverLifetimeModule.x = new ParticleSystem.MinMaxCurve(-0.8f, -1.5f);
                //velocityOverLifetimeModule.x = new ParticleSystem.MinMaxCurve(-18f, -25f);
                // mainModule.startLifetime = 20;
                break;

            case intensity.VeryStormy:
                emissionModule.rateOverTime = 8000;
                // velocityOverLifetimeModule.x = new ParticleSystem.MinMaxCurve(-0.8f, -1.5f);
                //velocityOverLifetimeModule.x = new ParticleSystem.MinMaxCurve(-18f, -25f);
                // mainModule.startLifetime = 20;
                break;

        }

    }

}
