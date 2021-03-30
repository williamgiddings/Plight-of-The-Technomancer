using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Biodome : Entity
{
    [SerializeField]
    private GameObject LowHealthEffects;
    [SerializeField]
    private float LowHealthEffectThreshold;

    public static event DelegateUtils.VoidDelegateNoArgs OnHealthLow;

    protected override void Start()
    {
        base.Start();
        DamageableComponent.OnHealthZero += OnDie;
        DamageableComponent.OnNormalisedHealthChange += OnHealthChange;
    }

    private void OnHealthChange( float NewNormalisedHealth )
    {
        if ( NewNormalisedHealth <= LowHealthEffectThreshold )
        {
            OnHealthLow();
            LowHealthEffects.SetActive( true );
        }
        
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
        DamageableComponent.OnNormalisedHealthChange -= OnHealthChange;
    }
}
