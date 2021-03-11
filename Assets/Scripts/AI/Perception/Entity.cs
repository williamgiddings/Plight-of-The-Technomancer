using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Entity : MonoBehaviour
{
    public enum EntityType
    {
        Vehicle,
        Human,
        Structure
    }

    [Header("Entity Settings")]
    public AIPerceptionService.Faction AllignedFaction;
    public EntityType Type;

    public static DelegateUtils.VoidDelegateEntityArg onEntityDestroyed;
    public static DelegateUtils.VoidDelegateEntityArg onEntityCreated;

    protected Damageable DamageableComponent;

    private int ActiveTargetOf;
    private Vector3 CenterOfMass;

    public virtual void Start()
    {
        onEntityCreated( this );
        CacheCenterMass();
        DamageableComponent = GetComponent<Damageable>();
    }

    private void CacheCenterMass()
    {
        Rigidbody Rigid = GetComponent<Rigidbody>();
        if ( Rigid )
        {
            CenterOfMass = Rigid.centerOfMass;
        }
    }

    public Vector3 GetCenterMass()
    {
        return CenterOfMass;
    }

    public void OnDestroy()
    {
        onEntityDestroyed( this );
    }

    public void Target()
    {
        ActiveTargetOf++;
    }

    public void UnTarget()
    {
        if ( ActiveTargetOf > 0 ) ActiveTargetOf--;
    }

    public int TargetedBy()
    {
        return ActiveTargetOf;
    }

    public void TryDealDamage( DamageSource InSource )
    {
        if ( DamageableComponent )
        {
            DamageableComponent.TakeDamage( InSource );
        }
    }
}
