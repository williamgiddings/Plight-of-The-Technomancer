using UnityEngine;

[CreateAssetMenu( fileName = "New AIFriendlySpawnableUnitParams", menuName = "DataAssets/AI/Spawning/AIFriendlySpawnableUnitParams", order = 1 )]
public class AIFriendlySpawnableUnitParams : ScriptableObject
{
    [Header("Multipliers Only")]
    public CraftableUnit[] CraftableUnitTypes;

}