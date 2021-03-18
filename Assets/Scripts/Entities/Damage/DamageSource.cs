using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public struct DamageSource
{
    public DamageSource( ProjectileTypes InType, GameObject InInstigator, float InAmount ) 
        : this( InType, InInstigator, InAmount, GetSafeInstigatorPosition( InInstigator ) )
    {
    }

    private static Vector3 GetSafeInstigatorPosition( GameObject Object )
    {
        if ( Object )
        {
            return Object.transform.position;
        }
        return Vector3.zero;
    }

    public DamageSource( ProjectileTypes InType, GameObject InInstigator, float InAmount, Vector3 InOrigin )
    {
        DamageType = InType;
        DamageInstigator = InInstigator;
        DamageAmount = InAmount;
        DamageOrigin = InOrigin;
    }


    ProjectileTypes DamageType;
    GameObject DamageInstigator;
    float DamageAmount;
    Vector3 DamageOrigin;

    public ProjectileTypes GetDamageType()
    {
        return DamageType;
    }

    public GameObject GetDamageInstigator()
    {
        return DamageInstigator;
    }

    public void ModifyDamage( float Modifier )
    {
        DamageAmount /= Modifier;
    }

    public float GetDamageAmount()
    {
        return DamageAmount;
    }

    public Vector3 GetDamageOrigin()
    {
        return DamageOrigin;
    }
}
