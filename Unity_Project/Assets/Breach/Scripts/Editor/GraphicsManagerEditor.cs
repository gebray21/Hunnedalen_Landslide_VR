using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(SimulationManager))]
public class GraphicsManagerEditor : Editor
{
    private int nextFrame = 0;
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        SimulationManager mgr = (SimulationManager) target;

        GUILayout.Space(25);
        GUILayout.Label("Current frame: " + mgr.AnimationFrame);
        GUILayout.BeginHorizontal();
        GUILayout.Label("Next frame");
        nextFrame = Convert.ToInt32(GUILayout.TextField(nextFrame.ToString(), GUILayout.MaxWidth(100)));
        if (GUILayout.Button("Set")) {
            mgr.AnimationFrame = nextFrame;
        }
        GUILayout.EndHorizontal();
    }
}
