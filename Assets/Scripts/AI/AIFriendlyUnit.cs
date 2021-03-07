using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class AIFriendlyUnitData
{
    public string   UnitName;
    
    public float    MaxHealth;
    public float    HeatResistance;
    public float    KineticResistance;
    public float    EnergyResistance;
    public float    BlastResistance;

    public float    DeployTime;
    public float    FireRate;
    public float    TargettingTime;

    public System.Guid GUID { get; }

    public AIFriendlyUnitData() : this(null)
    {

    }

    public List<StatTypes.Stat> GetPositiveStats()
    {
        List < StatTypes.Stat > PositiveStats = new List<StatTypes.Stat>();
        
        foreach ( StatTypes.Stat Stat in StatTypes.StatCollection )
        {
            if ( GetStatBinding( Stat ) > 0.0f )
            {
                PositiveStats.Add( Stat );
            }
        }
        return PositiveStats;
    }

    public AIFriendlyUnitData( AIFriendUnitParams Defaults )
    {
        UnitName = "NoName";
        
        if ( Defaults )
        {
            MaxHealth = Defaults.MaxHealth;
            DeployTime = Defaults.DeployTime;
            FireRate = Defaults.FireRate;
            TargettingTime = Defaults.TargettingTime;
        }

        GUID = System.Guid.NewGuid();
    }

    public override bool Equals( object InObject )
    {
        return this == InObject as AIFriendlyUnitData;
    }

    public static bool operator==( AIFriendlyUnitData ThisObject, AIFriendlyUnitData Other  )
    {
        if ( object.ReferenceEquals( null, ThisObject ) && object.ReferenceEquals( null, Other ) )
        {
            return true;
        }
        else if ( object.ReferenceEquals( null, ThisObject ) || object.ReferenceEquals( null, Other ) )
        {
            return false;
        }
        return ThisObject.GUID == Other.GUID;
    }

    public static bool operator!=( AIFriendlyUnitData ThisObject, AIFriendlyUnitData Other )
    {
        return !( ThisObject == Other);
    }

    public void Combine( AIFriendlyUnitData OtherObject)
    {
        HeatResistance = OtherObject.HeatResistance;
        KineticResistance = OtherObject.KineticResistance;
        EnergyResistance = OtherObject.EnergyResistance;
        BlastResistance = OtherObject.BlastResistance;

        MaxHealth *= OtherObject.MaxHealth;
        DeployTime *= OtherObject.DeployTime;
        FireRate *= OtherObject.FireRate;
        TargettingTime *= OtherObject.TargettingTime;
    }

    public float GetStatBinding( StatTypes.Stat Stat )
    {
        switch ( Stat )
        {
            case StatTypes.Stat.STAT_Health:
                return MaxHealth;
            case StatTypes.Stat.STAT_HeatResistance:
                return HeatResistance;
            case StatTypes.Stat.STAT_EnergyResistance:
                return EnergyResistance;
            case StatTypes.Stat.STAT_KineticResistance:
                return KineticResistance;
            case StatTypes.Stat.STAT_BlastResistance:
                return BlastResistance;
            case StatTypes.Stat.STAT_DeployTime:
                return DeployTime;
            case StatTypes.Stat.STAT_FireRate:
                return FireRate;
            case StatTypes.Stat.STAT_TargettingTime:
                return TargettingTime;
            default:
                return 0.0f;

        }  
    }
}

public class AIFriendlyUnit : AIAgent
{
    public string UnitNickName;

    public static event AIDelegates.FriendlyUnitDelegate onFriendlyUnitDestroyed;
    public static event AIDelegates.FriendlyUnitDelegate onFriendlyUnitSpawned;

    private Optional<AIFriendlyUnitData> UnitData;

    protected override void Start()
    {
        base.Start();
        onFriendlyUnitSpawned( this );
    }

    public AIFriendlyUnitData GetUnitData()
    {
        if ( UnitData )
        {
            return UnitData.Get();
        }
        Debug.Log("Unit Data Not Set!");
        return null;
    }

    public void SetUnitData( AIFriendlyUnitData Modifier )
    {
        AISpawnService SpawnService = GameState.GetGameService<AISpawnService>();

        AIFriendUnitParams DefaultParams = SpawnService?.GlobalParams?.FriendlyUnitDefaults;

        if ( DefaultParams )
        {
            UnitData = new AIFriendlyUnitData( DefaultParams );
            UnitData.Get().Combine(Modifier);
        }
    }

    protected override void OnDie()
    {
        onFriendlyUnitDestroyed( this );
    }

}
