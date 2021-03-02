using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class AIDelegates
{
    public delegate void FriendlyUnitDataDelegate( AIFriendlyUnitData Unit );
    public delegate void FriendlyUnitDelegate( AIFriendlyUnit SpawnedUnit );
    public delegate void FriendlyCraftableUnitDataDelegate( CraftableUnit Unit );
    public delegate void FriendlyUnitCoordDelegate( Optional<Vector2> UnitCoord );
    public delegate void FabricatingUnitTimeUpdated( float TimeRemaining );
    public delegate void FabricatingUnit( FabricatingUnitTimerObject Unit );
}
