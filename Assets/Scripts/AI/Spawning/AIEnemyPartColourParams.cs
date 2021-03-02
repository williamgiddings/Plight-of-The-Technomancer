using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public struct AIEnemyColourDesc
{
    public Color Colour;
    public string ColourName;

    public static bool operator ==( AIEnemyColourDesc ThisDesc, AIEnemyColourDesc OtherDesc ) => ThisDesc.ColourName.Equals( OtherDesc.ColourName );
    public static bool operator !=( AIEnemyColourDesc ThisDesc, AIEnemyColourDesc OtherDesc ) => !( ThisDesc == OtherDesc );
}

[CreateAssetMenu( fileName = "New AIEnemyPartColourParams", menuName = "DataAssets/AI/Spawning/AIFriendUnitParams", order = 1 )]
public class AIEnemyPartColourParams : ScriptableObject
{
    public WeightedCollection<int> NumPartRecolours;

    [Header("Colours")]
    public AIEnemyColourDesc[] AvailableColours;
}
