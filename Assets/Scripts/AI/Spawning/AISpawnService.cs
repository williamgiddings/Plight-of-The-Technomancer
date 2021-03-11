using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//TODO
//Update UnitSpawnUI to use the collection of available units in here instead of its own collection

public class AISpawnService : GameService
{
    [Header( "Global" )]
    public AIGlobalParams GlobalParams;

    [Header("Enemy Waves")]
    public AIWaveDescParams[] WaveFormations;

    [Header("Friendly Units")]
    public AIFriendlyUnit FriendlyUnitPrefab;
    public AIFriendlySpawnableUnitParams FriendlySpawnableUnits;
    public RectTransform FriendlySpawnRect;

    [Header("Spawn Params")]
    public Vector3 SpawnOrigin;
    public float SpawnRadius;
    public float DestinationRadius;
    public float UnitSpawnSeperation;

    [Header("Debug")]
    public Vector2 DebugNormalisedSpawnCoords;

    //Events
    public event AIDelegates.FriendlyUnitDataDelegate onNewFriendlyUnitAvailible;
    public event AIDelegates.FriendlyUnitDataDelegate onFriendlyUnitNotAvailible;

    private AIWave CurrentWave;
    private AIFriendlyUnitFactory FriendlyUnitFactory;
    private Dictionary<AIFriendlyUnitData, int> AvailableUnitQuantities = new Dictionary<AIFriendlyUnitData, int>();
    private AISurfaceProjectionService ProjectionService;

    public override void InitialiseGameService()
    {
        base.InitialiseGameService();
        FabricatingUnitTimerObject.onTimerCompleted += onUnitFinishedFabricating;
        FriendlyUnitFactory = new AIFriendlyUnitFactory();
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

    private AIEnemyUnit SpawnEnemyAIUnit( AIEnemyUnit UnitType, AIWave AssociatedWave, Vector3 Position )
    {
        AIEnemyUnit Unit = Instantiate<AIEnemyUnit>(
            UnitType,
            Position,
            Quaternion.LookRotation( (Position - SpawnOrigin).normalized, Vector3.up )
            );

        AssociatedWave.AddUnit( Unit );
        return Unit;
    }

    private void SpawnEnemyWave()
    {
        if (CurrentWave != null)
        {
            CurrentWave.TearDown();
        }
        CurrentWave = new AIWave();
        AIWaveDescParams SelectedWave = WaveFormations[0]; // Wave Selection based on current progression
        AIEnemyUnit Unit = SelectedWave.AvailibleUnits.Get( Random.Range( 0, 1 ) );

        int NumUnitsToSpawn = Random.Range( SelectedWave.MinUnitsInWave, SelectedWave.MaxUnitsInWave );

        float SpawnAngle = Random.Range( 0f, 360.0f );

        for ( int i = 0; i < NumUnitsToSpawn; i++ )
        {
            AIEnemyUnit SpawnedUnit = SpawnEnemyAIUnit( Unit, CurrentWave, RandomPointOnUnitCircle( SpawnAngle += UnitSpawnSeperation, SpawnRadius, SpawnOrigin.y ) );
            SpawnedUnit.SetDestination( RandomPointOnUnitCircle( SpawnAngle += UnitSpawnSeperation, DestinationRadius, 0.0f ) );
            SpawnedUnit.Init();
        }
    }

    public Vector3 RandomPointOnUnitCircle( float InDegrees, float Radius, float Height )
    {
        float Radians = InDegrees * Mathf.Deg2Rad;
        float x = Mathf.Sin(Radians) * Radius;
        float z = Mathf.Cos(Radians) * Radius;

        return new Vector3( x, Height, z );
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.F1))
        {
            SpawnEnemyWave();
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
            AIFriendlyUnit NewUnit = FriendlyUnitFactory.CreateNewUnit( FriendlyUnitPrefab, Unit );
            NewUnit.transform.position = new Vector3( X, Y, Z );
            RemoveSpawnableUnit( Unit );
            return true;

        }
        return false;

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
