using UnityEngine;

public class AIUnitFactory
{
    private AINamingService NamingService;
    private Vector3 SpawnOrigin;

    public AIUnitFactory( Vector3 InSpawnOrigin )
    {
        SpawnOrigin = InSpawnOrigin;
    }

    public AIFriendlyUnit CreateNewFriendlyUnit( AIFriendlyUnit UnitPrefab, AIFriendlyUnitData Data, AIEngagementParams Engagement )
    {
        AIFriendlyUnit NewUnit = GameObject.Instantiate<AIFriendlyUnit>(UnitPrefab);
        NewUnit.SetUnitData( Data );
        NewUnit.SetEngagementParams( Engagement );

        if ( GameState.TryGetGameService<AINamingService>( out AINamingService NamingService ) )
        {
            NewUnit.UnitNickName = NamingService.GetName();
        }

        return NewUnit;
    }


    public AIEnemyUnit SpawnEnemyAIUnit( AIEnemyUnit UnitType, AIWave AssociatedWave, Vector3 Position, AIEnemyUnitParams Params )
    {
        AIEnemyUnit Unit = GameObject.Instantiate<AIEnemyUnit>(
            UnitType,
            Position,
            Quaternion.LookRotation( (Position - SpawnOrigin).normalized, Vector3.up )
            );
        
        Unit.SetUnitParams(Params);
        Unit.SetEngagementParams( Params.EngagementParams );

        AssociatedWave.AddUnit( Unit );
        return Unit;
    }
}