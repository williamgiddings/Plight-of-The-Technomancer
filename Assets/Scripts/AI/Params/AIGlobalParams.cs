using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public struct StatIconDefinitions
{
    [System.Serializable]
    private struct StatIconDefinition
    {
        public StatTypes.Stat Stat;
        public Sprite StatIcon;
    }

    [SerializeField]
    private List<StatIconDefinition> Definitions;

    public Sprite GetStatIcon( StatTypes.Stat Stat )
    {
        return Definitions.Find( x => x.Stat == Stat ).StatIcon;
    }

}

[CreateAssetMenu( fileName = "New AIGlobalParams", menuName = "DataAssets/AI/AIGlobalParams", order = 1 )]
public class AIGlobalParams : ScriptableObject
{
    [Header("AI Stats")]
    public AIFriendUnitParams FriendlyUnitDefaults;
    public float MinStatScaler;
    public float MaxStatScaler;
    public StatIconDefinitions StatIcons;

}
