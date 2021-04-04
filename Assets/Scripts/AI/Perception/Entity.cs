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

    public static event DelegateUtils.VoidDelegateGenericArg<Entity> onEntityDestroyed;
    public static event DelegateUtils.VoidDelegateGenericArg<Entity> onEntityCreated;
    public GameObject OnDestroyEffect;

    protected Damageable DamageableComponent;

    private int ActiveTargetOf;
    private Vector3 CenterOfMass;

    public void ForceKill()
    {
        if ( DamageableComponent )
        {
            DamageableComponent.ForceKill();
        }
    }

    protected virtual void Start()
    {
        DamageableComponent = GetComponent<Damageable>();
        onEntityCreated( this );
        CacheCenterMass();
    }

    public Damageable GetDamageableComponent()
    {
        return DamageableComponent;
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

    protected virtual void OnDestroy()
    {
        if ( onEntityDestroyed != null) onEntityDestroyed( this );
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
