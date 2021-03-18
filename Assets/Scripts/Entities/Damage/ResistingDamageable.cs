using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ResistingDamageable : Damageable
{
    private StatResistance Resistances;
    public event DelegateUtils.VoidDelegateGenericArg<DamageSource> OnDamageResisted;

    protected override DamageSource ProcessDamageSource( DamageSource InSource )
    {
        DamageSource Source = InSource;
        
        if( Resistances != null )
        {
            if ( StatTypes.GetStatFromDamageType( InSource.GetDamageType(), out StatTypes.Stat HealthStat ) )
            {
                if ( Resistances.TryGetStatBinding( HealthStat, out float Binding ) )
                {
                    Source.ModifyDamage( Binding );
                    OnDamageResisted( InSource );
                }
            }
        }
        //remove
        OnDamageResisted( InSource );
        return Source;
    }

    public void SetResistances( StatResistance InResistances )
    {
        Resistances = InResistances;
    }
}
