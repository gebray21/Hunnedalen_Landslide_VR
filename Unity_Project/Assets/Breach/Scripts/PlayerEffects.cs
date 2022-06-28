using UnityEngine;
using UnityEngine.Assertions;
using UnityEngine.Rendering;
using UnityEngine.Serialization;

public class PlayerEffects : MonoBehaviour {
    [FormerlySerializedAs("GraphicsManager")] [SerializeField] private SimulationManager SimulationManager;

    [SerializeField] private VolumeProfile UnderwaterProfile;
    [SerializeField] private Volume UnderwaterVolume;

    [Tooltip("The midpoint is at water elevation height")]
    [SerializeField] private float FadeDistance = 0.2f;
    [Tooltip("Useful to set this to camera near plane")]
    [SerializeField] private float Offset = 0.3f;


    [SerializeField] private Rigidbody PlayerBody;
    [Tooltip("Step stride distance (in meters)")]
    [SerializeField] private float StrideLength = 0.3f;
    [Tooltip("If it's been less time than this value between steps, use running sounds (in seconds)")]
    [SerializeField] private float RunningTimeBetweenSteps = 0.5f;
    [Tooltip("Footsteps volume")]
    [SerializeField] private float TerrainFootstepsVolume = 1f;
    [SerializeField] private float WaterFootstepsVolume = 0.5f;

    [SerializeField] private AudioClip[] WalkingTerrainSounds;
    [SerializeField] private AudioClip[] RunningTerrainSounds;
    [SerializeField] private AudioClip[] WalkingWaterSounds;
    [SerializeField] private AudioClip[] RunningWaterSounds;

    private Vector2 lastStepPosition = Vector3.zero;
    private float lastStepTime = 0f;
    private AudioSource FootstepsSource;


    private void Start() {
        SimulationManager ??= FindObjectOfType<SimulationManager>();

        if (SimulationManager == null)
        {
            Debug.LogError("No Water SimulationManager found in scene. Make sure you have added the WaterSimulation prefab to your scene");
            gameObject.SetActive(false);
        }

        if (UnderwaterVolume is null) {
            var go = new GameObject("Underwater Volume");
            UnderwaterVolume = go.AddComponent<Volume>();
            UnderwaterVolume.profile = UnderwaterProfile;
        }

        InitFootstepsSource();
        lastStepPosition = PlayerBody.transform.position;
        lastStepTime = Time.time;
    }

    private void FixedUpdate()
    {
        var waterHeight = SimulationManager.GetWaterHeightAt(transform.position);

        HandleUnderwaterVolume(waterHeight);
        HandleFootsteps(waterHeight);
    }


    private void HandleUnderwaterVolume(float? waterHeight) {
        if (waterHeight.HasValue) {
            var weight = Mathf.Clamp01((1/FadeDistance) * (waterHeight.Value - (transform.position.y - 0.5f*FadeDistance - Offset)));
            UnderwaterVolume.weight = weight;
            UnderwaterVolume.gameObject.SetActive(weight > 0);
        } else
            UnderwaterVolume.gameObject.SetActive(false);
    }

    private void HandleFootsteps(float? waterHeight) {
        float distanceTravelled = Vector2.Distance(lastStepPosition, PlayerPos());
        float timePassed = Time.time - lastStepTime;
        bool running = timePassed < RunningTimeBetweenSteps;
        float distanceNeeded = StrideLength * (running ? 2 : 1);

        if (distanceTravelled >= distanceNeeded) {
            // Debug.Log($"Distance travelled: {distanceTravelled}, distanceNeeded: {distanceNeeded}, currentPos: {PlayerPos()}, lastPos: {lastStepPosition}");
            float terrainHeight = 0f;
            if (Physics.Raycast(transform.position, Vector3.down, out RaycastHit hit, 10f))
                terrainHeight = hit.point.y;
            bool water = waterHeight.HasValue && (waterHeight.Value-0.05f) > terrainHeight;

            PlayFootstep(running, water);
        }
    }

    private void InitFootstepsSource() {
        if (FootstepsSource != null) Destroy(FootstepsSource);

        FootstepsSource = gameObject.AddComponent<AudioSource>();
    }

    private void PlayFootstep(bool running, bool water) {
        var clips = (running, water) switch {
            (false, false) => WalkingTerrainSounds,
            (false, true) => WalkingWaterSounds,
            (true, false) => RunningTerrainSounds,
            (true, true) => RunningWaterSounds,
        };
        var clip = clips[Random.Range(0, clips.Length)];
        FootstepsSource.volume = water ? WaterFootstepsVolume : TerrainFootstepsVolume;
        FootstepsSource.PlayOneShot(clip);

        lastStepPosition = PlayerPos();
        lastStepTime = Time.time;
    }

    private Vector2 PlayerPos() =>
        new Vector2(PlayerBody.transform.position.x, PlayerBody.transform.position.z);
}
