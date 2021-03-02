using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu( fileName = "New AIWaveDescParams", menuName = "DataAssets/AI/AIWaveDescParams", order = 1 )]
public class AIWaveDescParams : ScriptableObject
{
    public int MaxUnitsInWave;
    public int MinUnitsInWave;
    public WeightedCollection<AIEnemyUnit> AvailibleUnits;

}
