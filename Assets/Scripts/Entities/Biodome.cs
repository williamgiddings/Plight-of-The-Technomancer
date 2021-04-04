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
    public static event DelegateUtils.VoidDelegateNoArgs OnBiodomeDestroyed;

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
            if ( OnHealthLow != null ) OnHealthLow();
            LowHealthEffects.SetActive( true );
        }    
    }

    private void OnDie()
    {
        Debug.Log( "Biodome Destroyed" );
        if ( OnBiodomeDestroyed != null ) OnBiodomeDestroyed();
        GameManager.EndGame( GameResult.Fail );
    }

    protected override void OnDestroy()
    {
        base.OnDestroy();
        DamageableComponent.OnHealthZero -= OnDie;
        DamageableComponent.OnNormalisedHealthChange -= OnHealthChange;
    }

#if UNITY_EDITOR
    private void Update()
    {
        if ( Input.GetKeyDown( KeyCode.F4 ) )
        {
            OnDie();
        }
    }
#endif
}
