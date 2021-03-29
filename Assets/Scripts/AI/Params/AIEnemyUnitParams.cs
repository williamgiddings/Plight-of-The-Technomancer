using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu( fileName = "New AIEnemyUnitParams", menuName = "DataAssets/AI/AIEnemyUnitParams", order = 1 )]
public class AIEnemyUnitParams : ScriptableObject
{
    public float MoveSpeed;
    public float DamageModifier = 1.0f;
    public AIEngagementParams EngagementParams;
}
