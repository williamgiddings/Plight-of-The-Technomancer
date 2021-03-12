using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu( fileName = "New AIFriendUnitParams", menuName = "DataAssets/AI/AIFriendUnitParams", order = 1 )]
public class AIFriendUnitParams : ScriptableObject
{
    public AIFriendlyUnit DefaultObject;
    public AIEngagementParams Engagement;

    [Header("Health")]
    public float MaxHealth;

    [Header("Actions")]
    public float DeployTime;
    public float FireRate;
    public float TargettingTime;

}
