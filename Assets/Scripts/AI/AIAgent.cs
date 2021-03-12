﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class AIAgent : Entity
{
    [Header("Engagement")]
    public Transform[] MuzzleLocations;
    
    protected Vector3 Destination;
    protected AIPerceptionComponent PerceptionComponent;
    [SerializeField]
    protected AIEngagementParams EngagementParams;
    protected bool LookingAtTarget = false;
    protected AIEngager Engager;
    protected float LastEngageTime = 0.0f;
    protected bool ReadyToEngage = true;

    private AISurfaceProjectionService SurfaceProjectionService;

    public override void Start()
    {
        base.Start();
        SurfaceProjectionService = GameState.GetGameService<AISurfaceProjectionService>();
        PerceptionComponent = GetComponent<AIPerceptionComponent>();
        DamageableComponent.OnHealthZero += OnDie;
        Engager = new AIEngager( this, EngagementParams.BarragesPerEngagement, ref MuzzleLocations );
        RegisterEvents();
    }

    public void SetEngagementParams( AIEngagementParams EngageParams )
    {
        EngagementParams = EngageParams;
    }

    protected void RegisterEvents()
    {
        if ( PerceptionComponent )
        {
            PerceptionComponent.onTargetAquired += OnPerceptionTargetAquired;
            PerceptionComponent.onTargetLost += OnPerceptionTargetLost;
        }

        if (Engager != null)
        {
            Engager.onBarrageFinished += delegate ( float TimeFinished ) 
            {
                LastEngageTime = TimeFinished;
                ReadyToEngage = true;
            };
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

    void FinishedEngaging( float TimeStamp )
    {

    }

    protected virtual void OnDie()
    {

    }
}
