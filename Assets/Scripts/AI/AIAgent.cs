using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class AIAgent : Entity
{
    protected Vector3 Destination;
    protected AIPerceptionComponent PerceptionComponent;

    protected bool LookingAtTarget = false;

    private AISurfaceProjectionService SurfaceProjectionService;

    public override void Start()
    {
        base.Start();
        SurfaceProjectionService = GameState.GetGameService<AISurfaceProjectionService>();
        PerceptionComponent = GetComponent<AIPerceptionComponent>();
        DamageableComponent.OnHealthZero += OnDie;
        RegisterEvents();
    }

    protected void RegisterEvents()
    {
        if ( PerceptionComponent )
        {
            PerceptionComponent.onTargetAquired += OnPerceptionTargetAquired;
            PerceptionComponent.onTargetLost += OnPerceptionTargetLost;
        }
    }

    protected virtual void LookAtTarget()
    {

    }

    protected virtual void OnPerceptionTargetAquired( Entity InEntity )
    {

    }

    protected virtual void OnPerceptionTargetLost()
    {

    }


    protected virtual void OnDestroy()
    {
        transform.DOKill();
    }

    public Damageable GetDamageableComponent()
    {
        return DamageableComponent;
    }

    protected virtual void UpdatePosition()
    {
        if ( SurfaceProjectionService )
        {
            Vector3 SurfaceNormal;
            transform.position = SurfaceProjectionService.GetProjectedPosition( transform.position, -1.0f, out SurfaceNormal );
        }
    }

    public void SetDestination( Vector3 InDestination )
    {
        Destination = InDestination;
    }

    protected virtual void OnDie()
    {

    }
}
