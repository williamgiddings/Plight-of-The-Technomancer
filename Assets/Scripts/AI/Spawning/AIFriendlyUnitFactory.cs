using UnityEngine;

public class AIFriendlyUnitFactory
{
    private AINamingService NamingService;

    public AIFriendlyUnit CreateNewUnit( AIFriendlyUnit UnitPrefab, AIFriendlyUnitData Data )
    {
        AIFriendlyUnit NewUnit = GameObject.Instantiate<AIFriendlyUnit>(UnitPrefab);
        NewUnit.SetUnitData( Data );

        AINamingService NamingService = GameState.GetGameService<AINamingService>();

        if ( NamingService )
        {
            NewUnit.UnitNickName = NamingService.GetName();
        }

        return NewUnit;
    }
}