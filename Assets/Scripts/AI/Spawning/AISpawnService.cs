using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class EnemyUnitParamBinding
{
    public AIEnemyUnitTypes Type;
    public AIEnemyUnitParams Params;
}


public class AISpawnService : GameService
{
    [Header( "Global" )]
    public AIGlobalParams GlobalParams;

    [Header("Friendly Units")]
    public AIFriendlyUnit FriendlyUnitPrefab;
    public AIFriendlySpawnableUnitParams FriendlySpawnableUnits;
    public RectTransform FriendlySpawnRect;

    [Header("Spawn Params")]
    public Vector3 SpawnOrigin;

    [Header("Debug")]
    public Vector2 DebugNormalisedSpawnCoords;

    //Events
    public event AIDelegates.FriendlyUnitDataDelegate onNewFriendlyUnitAvailible;
    public event AIDelegates.FriendlyUnitDataDelegate onFriendlyUnitNotAvailible;

    private AIUnitFactory UnitFactory;
    private Dictionary<AIFriendlyUnitData, int> AvailableUnitQuantities = new Dictionary<AIFriendlyUnitData, int>();
    private AISurfaceProjectionService ProjectionService;

    protected override void Begin()
    {
        FabricatingUnitTimerObject.onTimerCompleted += onUnitFinishedFabricating;
        UnitFactory = new AIUnitFactory( SpawnOrigin );
    }

    void onUnitFinishedFabricating( FabricatingUnitTimerObject TimedObject )
    {
        AddSpawnableUnit( TimedObject.Unit );
    }

    public void AddSpawnableUnit( AIFriendlyUnitData NewUnit )
    {
        onNewFriendlyUnitAvailible( NewUnit );

        int CurrentUnitQuanity;

        if ( AvailableUnitQuantities.TryGetValue( NewUnit, out CurrentUnitQuanity ) )
        {
            CurrentUnitQuanity++;
        }
        else
        {
            AvailableUnitQuantities.Add( NewUnit, 1 );
        }
    }

    public void RemoveSpawnableUnit( AIFriendlyUnitData InUnit )
    {
        onFriendlyUnitNotAvailible( InUnit );

        int CurrentUnitQuanity;

        if ( AvailableUnitQuantities.TryGetValue( InUnit, out CurrentUnitQuanity ) )
        {
            if ( --CurrentUnitQuanity <= 0)
            {
                AvailableUnitQuantities.Remove( InUnit );
            }
        }
    }

    public bool TrySpawnFriendlyUnit( AIFriendlyUnitData Unit, Vector2 NormalisedSpawnCoordinates )
    {
        float StartX = -(FriendlySpawnRect.rect.width / 2);
        float StartY = -(FriendlySpawnRect.rect.height / 2);
        float X = StartX+(FriendlySpawnRect.rect.width * NormalisedSpawnCoordinates.x);
        float Z = StartY+(FriendlySpawnRect.rect.height * NormalisedSpawnCoordinates.y);
        float Y = GetOrSetProjectionService().GetGlobalDownCastDepth( new Vector2( X, Z ) );

        if (Unit != null)
        {
            AIFriendlyUnit NewUnit = UnitFactory.CreateNewFriendlyUnit( FriendlyUnitPrefab, Unit, GlobalParams.FriendlyUnitDefaults.Engagement );
            NewUnit.transform.position = new Vector3( X, Y, Z );
            RemoveSpawnableUnit( Unit );
            return true;

        }
        return false;
    }

    public AIEnemyUnit TrySpawnEnemyUnit( AIEnemyUnit Unit, AIEnemyUnitTypes UnitType, AIEnemyUnitParams Params, AIWave Wave, Vector3 Location )
    {
        AIEnemyUnit SpawnedUnit = UnitFactory.SpawnEnemyAIUnit( Unit, Wave, Location, Params );
        SpawnedUnit.SetUnitType( UnitType );
        SpawnedUnit.SetDestination( Location );
        
        return SpawnedUnit;
    }

    private AISurfaceProjectionService GetOrSetProjectionService()
    {
        if( ProjectionService )
        {
            return ProjectionService;
        }
        ProjectionService = GameState.GetGameService<AISurfaceProjectionService>();
        return ProjectionService;
    }

    public ref CraftableUnit[] GetCraftableUnits()
    {
        return ref FriendlySpawnableUnits.CraftableUnitTypes;
    }

}
