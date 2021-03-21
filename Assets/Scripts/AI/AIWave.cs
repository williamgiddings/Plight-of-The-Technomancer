using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIWave
{
    public int ID { get; }
    public event DelegateUtils.VoidDelegateNoArgs onComplete;
    
    private List<AIEnemyUnit> ActiveEnemyUnits = new List<AIEnemyUnit>();

    public AIWave( int WaveIndex )
    {
        ID = WaveIndex;
    }

    public void AddUnit( AIEnemyUnit Unit )
    {
        ActiveEnemyUnits.Add( Unit );
        Unit.SetAssociatedWave( this );
    }

    private void RemoveUnit( AIEnemyUnit Unit )
    {
        ActiveEnemyUnits.Remove( Unit );
    }

    public void OnUnitDestroyed( AIEnemyUnit Unit )
    {
        RemoveUnit( Unit );
        if ( ActiveEnemyUnits.Count == 0 )
        {
            WaveComplete();
        }
    }

    private void WaveComplete()
    {
        onComplete();
    }

    public void TearDown()
    {
        List<AIEnemyUnit> Units = new List<AIEnemyUnit>( ActiveEnemyUnits );

        foreach( AIEnemyUnit Unit in Units )
        {
            Unit.ForceKill();
        }
    }
}
