﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class AIAgent : Entity
{
    [Header("Engagement")]
    public Transform[] MuzzleLocations;
    public float DamageOverride = 1.0f;

    protected Vector3 Destination;
    protected AIPerceptionComponent PerceptionComponent;
    [SerializeField]
    protected AIEngagementParams EngagementParams;
    protected bool LookingAtTarget = false;
    protected AIEngager Engager;
    protected float LastEngageTime = 0.0f;
    protected bool ReadyToEngage = true;

    private AISurfaceProjectionService SurfaceProjectionService;

    protected override void Start()
    {
        base.Start();
        
        if ( EngagementParams && Engager == null )
        {
            SetEngagementParams( EngagementParams );
        }

        SurfaceProjectionService = GameState.GetGameService<AISurfaceProjectionService>();
        PerceptionComponent = GetComponent<AIPerceptionComponent>();
        RegisterEvents();
    }

    public void SetEngagementParams( AIEngagementParams EngageParams )
    {
        EngagementParams = EngageParams;
        Engager = new AIEngager(
            this,
            EngagementParams.BarragesPerEngagement,
            ref MuzzleLocations, 
            this as AIEnemyUnit ? DamageOverride * GameState.GetDifficulty() : DamageOverride
    );
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

        DamageableComponent.OnHealthZero += OnDie;
    }

    protected void UnRegisterEvents()
    {
        if ( PerceptionComponent )
        {
            PerceptionComponent.onTargetAquired -= OnPerceptionTargetAquired;
            PerceptionComponent.onTargetLost -= OnPerceptionTargetLost;
        }

        if ( Engager != null )
        {
            Engager.onBarrageFinished -= delegate ( float TimeFinished )
            {
                LastEngageTime = TimeFinished;
                ReadyToEngage = true;
            };
        }

        DamageableComponent.OnHealthZero -= OnDie;
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


    protected override void OnDestroy()
    {
        base.OnDestroy();
        for ( int ChildIndex = 0; ChildIndex < transform.childCount; ChildIndex++ )
        {
            transform.GetChild( ChildIndex ).DOKill(true);
        }
        UnRegisterEvents();
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
        if ( OnDestroyEffect )
        {
            GameObject Effect = CFX_SpawnSystem.GetNextObject( OnDestroyEffect );
            Effect.transform.position = transform.position;
        }
    }
}
