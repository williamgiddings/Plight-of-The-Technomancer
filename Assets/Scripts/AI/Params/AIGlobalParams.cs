using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu( fileName = "New AIGlobalParams", menuName = "DataAssets/AI/AIGlobalParams", order = 1 )]
public class AIGlobalParams : ScriptableObject
{
    [Header("AI Stats")]
    public AIFriendUnitParams FriendlyUnitDefaults;
    public float MinStatScaler;
    public float MaxStatScaler;

}
