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
    }
}
