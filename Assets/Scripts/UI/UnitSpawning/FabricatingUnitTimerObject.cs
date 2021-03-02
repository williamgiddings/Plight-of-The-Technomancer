using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FabricatingUnitTimerObject
{
    public AIDelegates.FabricatingUnitTimeUpdated onTimerIntervalUpdated;
    public static AIDelegates.FabricatingUnit onTimerCompleted;
    public static AIDelegates.FabricatingUnit onTimerStarted;

    public float TimeRemaining;
    public float TimerLength;
    public AIFriendlyUnitData Unit;

    private float LastTimerUpdateInterval;
    private float CumulativeTimePassed;

    private System.Guid GUID;

    public FabricatingUnitTimerObject( AIFriendlyUnitData InUnitData, float InTimerLength )
    {
        Unit = InUnitData;
        TimerLength = InTimerLength;
        TimeRemaining = TimerLength;
        onTimerStarted( this );
        GUID = System.Guid.NewGuid();
    }

    public void TickTimer( float DeltaSeconds )
    {
        TimeRemaining -= DeltaSeconds;
        CumulativeTimePassed += DeltaSeconds;

        if ( CumulativeTimePassed - LastTimerUpdateInterval >= 1.0f ) // every one second
        {
            LastTimerUpdateInterval = CumulativeTimePassed;
            onTimerIntervalUpdated( TimeRemaining );
        }

        if ( TimeRemaining <= 0.0f )
        {
            onTimerCompleted( this );
        }
    }

    public static bool operator==( FabricatingUnitTimerObject Obj1, FabricatingUnitTimerObject Obj2 ) => Obj1.GUID == Obj2.GUID;
    public static bool operator!=( FabricatingUnitTimerObject Obj1, FabricatingUnitTimerObject Obj2 ) => !(Obj1.GUID == Obj2.GUID);

}
