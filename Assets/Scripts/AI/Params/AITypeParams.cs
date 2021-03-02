using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu( fileName = "New AITypeParams", menuName = "DataAssets/AI/AITypeParams", order = 1 )]
public class AITypeParams : ScriptableObject
{
    public GameObject[] AITypes;
}
