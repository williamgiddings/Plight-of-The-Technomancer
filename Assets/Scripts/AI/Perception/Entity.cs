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

    private int ActiveTargetOf;

    public void Start()
    {
        onEntityCreated( this );
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
}
