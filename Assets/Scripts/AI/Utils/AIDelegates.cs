using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class AIDelegates
{
    //Units
    public delegate void FriendlyUnitDataDelegate( AIFriendlyUnitData Unit );
    public delegate void FriendlyUnitDelegate( AIFriendlyUnit SpawnedUnit );
    public delegate void FriendlyUnitCoordDelegate( Optional<Vector2> UnitCoord );
    
    //Fabrication
    public delegate void FabricatingUnitTimeUpdated( float TimeRemaining );
    public delegate void FabricatingUnit( FabricatingUnitTimerObject Unit );
    public delegate void FriendlyCraftableUnitDataDelegate( CraftableUnit Unit );

    //Waves
    public delegate void AIWaveDelegate( AIWave NewWave );
}
