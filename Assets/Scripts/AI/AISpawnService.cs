using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AISpawnService : GameService
{
    [Header("Waves")]
    public AIWaveDescParams[] WaveFormations;

    [Header("Spawn Params")]
    public Vector3 SpawnOrigin;
    public float SpawnRadius;
    public float DestinationRadius;
    public float UnitSpawnSeperation;

    private AIWave CurrentWave;

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

}
