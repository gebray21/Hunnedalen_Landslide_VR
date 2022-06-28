using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestructibleHouse : MonoBehaviour {
    [SerializeField] private int DestroyOnFrame = -1;

    private SimulationManager SimulationManager;
    private GameObject[] Destructibles;


    void Start() {
        List<GameObject> dests = new List<GameObject>();

        for (int i = 0; i < transform.childCount; i++) {
            var c = transform.GetChild(i);
            if (!c.gameObject.isStatic && c.TryGetComponent<Collider>(out _))
                dests.Add(c.gameObject);
        }

        Destructibles = dests.ToArray();

        if (DestroyOnFrame >= 0)
            SimulationManager.OnFrameChanged += CheckForDestruction;
    }

    public void Destruct() {
        StartCoroutine(DoDestruct());
    }

    private IEnumerator DoDestruct() {
        foreach (var d in Destructibles) {
            d.AddComponent<Rigidbody>();
            yield return null;
        }
    }


    private void CheckForDestruction(object sender, int frame) {
        if (frame == DestroyOnFrame) {
            Destruct();
            SimulationManager.OnFrameChanged -= CheckForDestruction;
        }
    }
}
