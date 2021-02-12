using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum DamageTypes
{
    Explosion,
    Crushed,
    Shot,
    Unknown
}

public struct DamageSource
{
    public DamageSource( DamageTypes InType, GameObject InInstigator, float InAmount)
    {
        DamageType = InType;
        DamageInstigator = InInstigator;
        DamageAmount = InAmount;
    }

    DamageTypes DamageType;
    GameObject DamageInstigator;
    float DamageAmount;

    public DamageTypes GetDamageType()
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
