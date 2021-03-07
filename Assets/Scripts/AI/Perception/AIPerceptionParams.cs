using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "New AIPerceptionParams", menuName = "DataAssets/AI/AIPerceptionParams", order = 1)]
public class AIPerceptionParams : ScriptableObject
{
    [Header("Targeting")]
    public bool UsePopularityUnBiasing;
    public float MinTargetingTime;
    public float MaxTargetingTime;
    public float MaxTargetingRange;
    public float MaxTargetingAngle;
    public List<Entity.EntityType> Targetable = new List<Entity.EntityType>();
    public float RetargetThreshold;
    
    [Header("Perception")]
    public float EyeHeight;
    public LayerMask TargetingPerceptionLayers;

    [Header("Attack")]
    public float MinAttackAfterTargetTime;
    public float MaxAttackAfterTargetTime;
}
