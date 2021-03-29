using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : Entity
{
    protected override void Start()
    {
        base.Start();
        DamageableComponent.OnHealthZero += OnDie;
    }

    private void OnDie()
    {
        Debug.Log("Player Died");
        GameManager.EndGame( GameResult.Fail );
    }

    protected override void OnDestroy()
    {
        base.OnDestroy();
        for ( int ChildIndex = 0; ChildIndex < transform.childCount; ChildIndex++ )
        {
            transform.GetChild( ChildIndex ).DOKill();
        }
        
        if ( DamageableComponent )
        {
            DamageableComponent.OnHealthZero -= OnDie;
        }
    }
}
