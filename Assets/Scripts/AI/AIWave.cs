using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIWave
{
    List<AIEnemyUnit> ActiveEnemyUnits = new List<AIEnemyUnit>();

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
        Debug.Log("Wave Defeated");
    }

    public void TearDown()
    {
        foreach( AIEnemyUnit Unit in ActiveEnemyUnits)
        {
            GameObject.Destroy( Unit );
        }
    }
}
