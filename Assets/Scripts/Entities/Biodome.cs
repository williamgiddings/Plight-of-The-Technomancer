using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Biodome : Entity
{
    protected override void Start()
    {
        base.Start();
        DamageableComponent.OnHealthZero += OnDie;
    }

    private void OnDie()
    {
        Debug.Log( "Biodome Destroyed" );
        GameManager.EndGame( GameResult.Fail );
    }

    protected override void OnDestroy()
    {
        base.OnDestroy();
        DamageableComponent.OnHealthZero -= OnDie;
    }
}
