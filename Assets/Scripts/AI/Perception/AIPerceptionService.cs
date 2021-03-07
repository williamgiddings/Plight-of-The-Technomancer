using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIPerceptionTickAggregator
{
    private List<AIPerceptionComponent> ActivePercievers = new List<AIPerceptionComponent>();
    private MonoBehaviour MonoReference; 
    private bool FinishedTicking = true;

    public AIPerceptionTickAggregator( MonoBehaviour InMonoReference )
    {
        MonoReference = InMonoReference;
    }

    public void Add( AIPerceptionComponent Perciever )
    {
        ActivePercievers.Add( Perciever );
    }

    public void Remove( AIPerceptionComponent Perciever )
    {
        ActivePercievers.Remove( Perciever );
    }

    public void Update()
    {
        if ( FinishedTicking && ActivePercievers.Count > 0 )
        {
            MonoReference.StartCoroutine( TickPercivers() );
        }
    }

    private IEnumerator TickPercivers()
    {
        FinishedTicking = false;
        foreach ( AIPerceptionComponent Perciever in ActivePercievers )
        {
            if ( Perciever )
            {
                Perciever.TickPerception();
                yield return new WaitForFixedUpdate();
            }
            continue;
        }
        FinishedTicking = true;
    }
}

[System.Serializable]
public struct FactionRelation
{
    public AIPerceptionService.Faction Faction;
    public List<AIPerceptionService.Faction> HostileTo;
}


public class AIPerceptionService : GameService
{
    public enum Faction
    {
        Attacker,
        Defender
    }

    public List<FactionRelation> FactionHostileRelations = new List<FactionRelation>();
    
    private Dictionary< Faction, List<Entity> > AllignedUnits = new Dictionary<Faction, List<Entity>>();
    private AIPerceptionTickAggregator TickAggregator;

    private void Start()
    {
        Entity.onEntityCreated += EntityCreated;
        Entity.onEntityDestroyed += EntityDestroyed;
        TickAggregator = new AIPerceptionTickAggregator( this );
    }

    public void RegisterPerciever( AIPerceptionComponent Perciever )
    {
        TickAggregator.Add( Perciever );
    }
    public void UnRegisterPerciever( AIPerceptionComponent Perciever )
    {
        TickAggregator.Remove( Perciever );
    }

    void EntityCreated( Entity NewEntity )
    {
        if ( AllignedUnits.TryGetValue( NewEntity.AllignedFaction, out List<Entity> Entities ) )
        {
            Entities.Add( NewEntity );
        }
        else
        {
            AllignedUnits.Add( NewEntity.AllignedFaction, new List<Entity>() { NewEntity } );
        }
    }

    void EntityDestroyed( Entity OldEntity )
    {
        if ( AllignedUnits.TryGetValue( OldEntity.AllignedFaction, out List<Entity> Entities ) )
        {
            Entities.Remove( OldEntity );
        }
    }

    public List<Entity> GetHostileUnitsForFaction( Faction MyFaction )
    {
        List < Entity > HostileUnits = new List<Entity>();
        FactionRelation Relations = FactionHostileRelations.Find(Relation => Relation.Faction == MyFaction );

        if ( !object.ReferenceEquals(Relations, null) )
        {
            foreach ( Faction Fac in Relations.HostileTo )
            {
                HostileUnits.AddRange( GetAllignedUnits( Fac ) );
            }
        }
        else
        {
            Debug.Log( string.Format( "No faction relations defined for {0}", MyFaction.ToString() ) );
        }
        return HostileUnits;
    }

    public List<Entity> GetAllignedUnits( Faction FactionType )
    {
        return AllignedUnits[FactionType];
    }

    private void Update()
    {
        TickAggregator.Update();
    }
}
