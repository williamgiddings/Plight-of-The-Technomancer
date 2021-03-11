using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public struct DamageSource
{
    public DamageSource( AIEnemyUnitTypes InType, GameObject InInstigator, float InAmount)
    {
        DamageType = InType;
        DamageInstigator = InInstigator;
        DamageAmount = InAmount;
    }

    AIEnemyUnitTypes DamageType;
    GameObject DamageInstigator;
    float DamageAmount;

    public AIEnemyUnitTypes GetDamageType()
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
