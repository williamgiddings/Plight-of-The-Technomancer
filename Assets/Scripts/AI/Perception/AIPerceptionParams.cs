using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "New AIPerceptionParams", menuName = "DataAssets/AI/AIPerceptionParams", order = 1)]
public class AIPerceptionParams : ScriptableObject
{
    [Header("Targeting")]
    public bool UsePopularityUnBiasing;
    public float TargetingTime;
    public float MaxTargetingRange;
    public float MaxTargetingAngle;

    [Header("Target Selection")]
    public List<Entity.EntityType> Targetable = new List<Entity.EntityType>();
    public float RetargetThreshold;
    public float DistanceScoreWeighting = 1.0f;
    public float AngleScoreWeighting = 1.0f;
    public float TargetableTypePickiness = 1.0f;
    
    [Header("Perception")]
    public float EyeHeight;
    public LayerMask TargetingPerceptionLayers;

    [Header("Attack")]
    public float MinAttackAfterTargetTime;
    public float MaxAttackAfterTargetTime;
}
