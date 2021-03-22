using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIWaveSpawnService : GameService
{
    [Header("Enemy Units")]
    public AIWaveDescParams[] WaveFormations;
    public List<EnemyUnitParamBinding> UnitTypes =  new List<EnemyUnitParamBinding>();

    [Header("Spawn Params")]
    public float SpawnRadius;
    public float DestinationRadius;
    public float UnitSpawnSeperation;

    //Events
    public event AIDelegates.AIWaveDelegate OnWaveBegin;
    public event AIDelegates.AIWaveDelegate OnWaveEnd;
    public event DelegateUtils.VoidDelegateFloatArg OnIntermissionStart;
    public event DelegateUtils.VoidDelegateFloatArg OnIntermissionUpdate;

    private AIWave CurrentWave;
    private int CurrentWaveIndex;
    private AISpawnService SpawnService;
    private AISurfaceProjectionService SurfaceProjectionService;

    protected override void Begin()
    {
        base.Begin();
        SpawnService = GameState.GetGameService<AISpawnService>();
        SurfaceProjectionService = GameState.GetGameService<AISurfaceProjectionService>();
        GameState.onGameStateFinishedInitialisation += onGameStateFinishedInitialisation;
        CurrentWaveIndex = -1;
    }

    private void onGameStateFinishedInitialisation()
    {
        StartIntermission( 10.0f );
    }

    private void SpawnEnemyWave( uint WaveIndex )
    {
        if ( CurrentWave != null )
        {
            CurrentWave.TearDown();
        }
        CurrentWave = new AIWave( CurrentWaveIndex );
        CurrentWave.onComplete += WaveComplete;

        AIWaveDescParams SelectedWave = WaveFormations[WaveIndex]; // Wave Selection based on current progression
        AIEnemyUnit Unit = SelectedWave.AvailibleUnits.Get( Random.Range( 0, 1 ) );
        List<AIEnemyUnitTypes> AvailableUnitTypes = GetNUnitTypes(SelectedWave.NumUnitTypes);

        int NumUnitsToSpawn = Random.Range( SelectedWave.MinUnitsInWave, SelectedWave.MaxUnitsInWave );
        float SpawnAngle = Random.Range( 0f, 360.0f );

        for ( int i = 0; i < NumUnitsToSpawn; i++ )
        {
            AIEnemyUnitTypes RandomType = AvailableUnitTypes[Random.Range(0, AvailableUnitTypes.Count)];

            Vector3 Location = RandomPointOnUnitCircle( SpawnAngle += UnitSpawnSeperation, SpawnRadius, 30.0f );
            Vector3 SpawnOrigin = SurfaceProjectionService.GetProjectedPosition(Location, 1.0f, out Vector3 Normal );
            
            AIEnemyUnit SpawnedUnit = SpawnService.TrySpawnEnemyUnit( Unit, RandomType, GetParamsForType( RandomType ), CurrentWave, SpawnOrigin );

            if ( SpawnedUnit )
            {
                SpawnedUnit.SetDestination( RandomPointOnUnitCircle( SpawnAngle += UnitSpawnSeperation, DestinationRadius, 0.0f ) );
            }
        }
    }

    public Vector3 RandomPointOnUnitCircle( float InDegrees, float Radius, float Height )
    {
        float Radians = InDegrees * Mathf.Deg2Rad;
        float x = Mathf.Sin(Radians) * Radius;
        float z = Mathf.Cos(Radians) * Radius;

        return new Vector3( x, Height, z );
    }


    private List<AIEnemyUnitTypes> GetNUnitTypes( int N )
    {
        List<AIEnemyUnitTypes> Types = new List<AIEnemyUnitTypes>();

        if ( UnitTypes.Count > 0 )
        {
            for ( int i = 0; i < N; i++ )
            {
                Types.Add( UnitTypes[Random.Range( 0, UnitTypes.Count - 1 )].Type );
            }
        }
        return Types;
    }

    private AIEnemyUnitParams GetParamsForType( AIEnemyUnitTypes Type )
    {
        EnemyUnitParamBinding ParamBinding = UnitTypes.Find( ParamBinding => ParamBinding.Type == Type );
        if ( ParamBinding != null )
        {
            return ParamBinding.Params;
        }
        return null;
    }

    private void StartIntermission( float Duration )
    {
        if ( OnIntermissionStart != null ) OnIntermissionStart( Duration );

        StartCoroutine( WaitForIntermission( Duration ) );
    }

    private IEnumerator WaitForIntermission( float Duration )
    {
        float TimeRemaining = Duration;
        float Tick = 1.0f;
        while( Duration > 0.0f )
        {
            if (OnIntermissionUpdate!=null) OnIntermissionUpdate( Duration );
            Duration -= Tick;
            yield return new WaitForSeconds( Tick );
        }
        if ( OnIntermissionUpdate != null ) OnIntermissionUpdate( 0.0f );
        AdvanceWave();
    }

    private void WaveComplete()
    {
        OnWaveEnd( CurrentWave );
        StartIntermission( 40.0f );
    }

    private void AdvanceWave()
    {
        CurrentWaveIndex++;
        SpawnEnemyWave( ( uint ) Mathf.Clamp( CurrentWaveIndex, 0, WaveFormations.Length - 1 ) );
        OnWaveBegin( CurrentWave );
        Debug.Log( string.Format( "Wave {0} Started", CurrentWaveIndex ) );
    }

    protected override void OnDestroy()
    {
        base.OnDestroy();
        if ( CurrentWave != null )
        {
            CurrentWave.onComplete -= WaveComplete;
        }
        GameState.onGameStateFinishedInitialisation -= onGameStateFinishedInitialisation;
    }
}
