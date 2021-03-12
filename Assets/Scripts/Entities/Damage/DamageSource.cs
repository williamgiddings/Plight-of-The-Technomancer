using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public struct DamageSource
{
    public DamageSource( ProjectileTypes InType, GameObject InInstigator, float InAmount)
    {
        DamageType = InType;
        DamageInstigator = InInstigator;
        DamageAmount = InAmount;
    }

    ProjectileTypes DamageType;
    GameObject DamageInstigator;
    float DamageAmount;

    public ProjectileTypes GetDamageType()
    {
        return DamageType;
    }

    public GameObject GetDamageInstigator()
    {
        return DamageInstigator;
    }

    public float GetDamageAmount()
    {
        return DamageAmount;
    }
}
