using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// [ExecuteInEditMode]
public class SnowParticleCollisionProcess : MonoBehaviour
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

    // public ParticleSystem SnowParticle;

    public ParticleSystem.EmissionModule emissionModule;

    public ParticleSystem.VelocityOverLifetimeModule velocityOverLifetimeModule;

    public ParticleSystem.MainModule mainModule;

    public intensity Intensity;
    private intensity OldIntensity;

    public int CustomRateOverTime = 200;


    /// <summary>
    /// 
    /// </summary>

    public ParticleSystem particle1;

    public ParticleSystem SnowWaterSplash;
    public ParticleSystem SnowGroundSplash;

    // public ParticleSystem SnowGroundParticle;

    List<ParticleCollisionEvent> collisionEvents;

    public float CollisionGap = 0;

    public GameObject FollowingCamera;
    private Vector3 DistanceFromCamera;

    // float MaxV;

    // Start is called before the first frame update
    void Start()
    {
        particle1 = GetComponent<ParticleSystem>();
        collisionEvents = new List<ParticleCollisionEvent>();

        /*
        var main = particle1.main;
        ParticleSystemRenderer pr = particle1.GetComponentInChildren<ParticleSystemRenderer>();        
        // MaxV = ( Mathf.Max(pr.mesh.bounds.size.x, pr.mesh.bounds.size.y, pr.mesh.bounds.size.z) * main.startSize.constant ) / 2.05f;
        MaxV = ( pr.mesh.bounds.size.y * main.startSize.constant) / 3f;
        print("MaxV=" + MaxV);
        */

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
                emissionModule.rateOverTime = 30;
                break;

            case intensity.Light:
                emissionModule.rateOverTime = 60;
                break;

            case intensity.Moderate:
                emissionModule.rateOverTime = 100;
                break;

            case intensity.Heavy:
                emissionModule.rateOverTime = 200;
                break;

            case intensity.VeryHeavy:
                emissionModule.rateOverTime = 400;
                break;

            case intensity.Stormy:
                emissionModule.rateOverTime = 600;
                //velocityOverLifetimeModule.x = -30;
                //mainModule.startLifetime = 15;
                break;

            case intensity.VeryStormy:
                emissionModule.rateOverTime = 900;
                //velocityOverLifetimeModule.x = -30;
                //mainModule.startLifetime = 15;
                break;
        }

    }

    void OnParticleCollision(GameObject other)
    {

        int numCollisionEvents = 0;
        if ( collisionEvents != null )
            numCollisionEvents = particle1.GetCollisionEvents(other, collisionEvents);

        int i = 0;
        while (i < numCollisionEvents)
        {
            if (other.layer == LayerMask.NameToLayer("ground"))
            {
                SnowGroundSplash.transform.position = collisionEvents[i].intersection;

                //SnowGroundSplash.transform.TransformDirection(collisionEvents[i].normal);
                Quaternion Q = Quaternion.LookRotation(collisionEvents[i].normal);

                var main = SnowGroundSplash.main;
                main.startRotationX = Q.eulerAngles.x * Mathf.Deg2Rad;
                main.startRotationY = Q.eulerAngles.y * Mathf.Deg2Rad;
                main.startRotationZ =  Random.Range(-180f, 180f) * Mathf.Deg2Rad;

                if (CollisionGap != 0)
                {
                    // Vector3 targetForward = Q * Vector3.forward;
                    // SnowGroundSplash.transform.position += SnowGroundSplash.transform.forward * CollisionGap;
                    SnowGroundSplash.transform.position += Q * Vector3.forward * CollisionGap;
                }

                SnowGroundSplash.Emit(1);

            }
            else if (other.layer == LayerMask.NameToLayer("water"))
            {
                SnowWaterSplash.transform.position = collisionEvents[i].intersection;

                //SnowWaterSplash.transform.TransformDirection(collisionEvents[i].normal);
                Quaternion Q = Quaternion.LookRotation(collisionEvents[i].normal);

                var main = SnowWaterSplash.main;
                main.startRotationX = Q.eulerAngles.x * Mathf.Deg2Rad;
                main.startRotationY = Q.eulerAngles.y * Mathf.Deg2Rad;
                main.startRotationZ = Random.Range(-180f, 180f) * Mathf.Deg2Rad;

                if (CollisionGap != 0)
                {
                    // Vector3 targetForward = Q * Vector3.forward;
                    // SnowGroundSplash.transform.position += SnowGroundSplash.transform.forward * CollisionGap;
                    SnowWaterSplash.transform.position += Q * Vector3.forward * CollisionGap;
                }

                SnowWaterSplash.Emit(1);

            }
            i++;
        }
    }


}
