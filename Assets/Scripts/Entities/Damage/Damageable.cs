using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class Damageable : MonoBehaviour
{
    [Header( "Asset" )]
    public DamageableParams HealthParams;

    public delegate void HealthZeroDelegate( DamageSource Source );
    public static event HealthZeroDelegate OnHealthZero;

    private float Health = 0;

    private List<DamageSource> DamageHistory = new List<DamageSource>();

    void OnEnable()
    {
        if ( HealthParams )
        {
            Health = HealthParams.MaxHealth;
        }
        else
        {
            Debug.Log( "Health Params not Set!" );
        }
    }

    #if UNITY_EDITOR
    void OnDrawGizmosSelected()
    {
        if ( HealthParams )
        {
            Gizmos.color = new Color( 0, 1, 0, 0.5f );
            Gizmos.DrawSphere( transform.position+ transform.up*0.5f, 1.0f );
            UnityEditor.Handles.Label( transform.position, string.Format( "Health: {0}/{1}", Health, HealthParams.MaxHealth ) );
        }
    }
    #endif

    public void TakeDamage( DamageSource InDamage )
    {
        if ( HealthParams && Health > 0 )
        {
            DamageHistory.Add( InDamage );
            Health -= InDamage.GetDamageAmount();

            if ( Health <= 0 )
            {
                Debug.Log( string.Format( "{0} was Destroyed by {1}'s {2}", gameObject.name, InDamage.GetDamageInstigator().name, InDamage.GetDamageType().ToString() ) );
                OnHealthZero( InDamage );
            }
        }
    }

}
