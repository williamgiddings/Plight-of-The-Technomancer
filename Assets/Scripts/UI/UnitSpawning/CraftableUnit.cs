using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class CraftableUnit
{
    [Header("Unit Data")]
    public AIFriendlyUnitData Data;
    
    [Header("Fabrication Settings")]
    public int FabricationCost;
    public float FabricationTime;
}
