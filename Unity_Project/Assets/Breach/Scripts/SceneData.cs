using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace Breach.WildWaters
{
    [Serializable]
    public class SceneMetadata
    {
        public string Name;
        public string Path;
    }
    public class SceneData : ScriptableObject
    {
        public List<SceneMetadata> Data;
    }
}
