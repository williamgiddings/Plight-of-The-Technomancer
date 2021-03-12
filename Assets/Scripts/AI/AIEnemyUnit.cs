using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIEnemyUnit : AIAgent
{
    public AIEnemyUnitParams Params;

    private EnemyVATAnimator Animator;
    private AIWave AssociatedWave;

    [Header("Aiming Visual")]
    public Transform Head;
    public float MinAimPitch;
    public float MaxAimPitch;

    private Entity CacheEntityTarget;

    public void Init()
    {
        Animator = GetComponent<EnemyVATAnimator>();
        StartCoroutine( HeadToShootingPosition() );
    }

    public override void Start()
    {
        base.Start();
        PerceptionComponent.SetHeadTransform( Head.transform );
    }

    protected override void LookAtTarget()
    {
        LookingAtTarget = false;
        Quaternion NewRotation = GetTurretRotation();
        
        Head.DORotate( NewRotation.eulerAngles, PerceptionComponent.PerceptionParams.TargetingTime ).onComplete += delegate() 
        { 
            LookingAtTarget = true; 
        };
    }

    private void FixedUpdate()
    {
        if ( CacheEntityTarget && LookingAtTarget )
        {
            Head.rotation = GetTurretRotation();

            if ( ReadyToEngage && Time.time >= (LastEngageTime + EngagementParams.Cooldown) )
            {
                ReadyToEngage = false;
                Engager.Engage( CacheEntityTarget );
            }
        }
    }

    protected override void OnPerceptionTargetAquired( Entity InEntity )
    {
        CacheEntityTarget = InEntity;
        LookAtTarget();
    }

    protected override void OnPerceptionTargetLost()
    {
        CacheEntityTarget = null;
        LookingAtTarget = false;

        Head.DOLocalRotate( Vector3.zero, PerceptionComponent.PerceptionParams.TargetingTime );
    }

    Quaternion GetTurretRotation()
    {
        Vector3 TurretLookPos = CacheEntityTarget.transform.position - Head.transform.position;
        float NewAnglePitch = -TurretLookPos.y;
        NewAnglePitch = Mathf.Clamp( NewAnglePitch, MinAimPitch, MaxAimPitch );
        Quaternion NewRotation = Quaternion.LookRotation(new Vector3(TurretLookPos.x, 0.0f, TurretLookPos.z ) ) * Quaternion.Euler( NewAnglePitch, 0.0f, 0.0f );
        
        return NewRotation;
    }

    private void Damageable_OnHealthZero( DamageSource Source )
    {
        AssociatedWave.OnUnitDestroyed( this );
        Destroy( gameObject );
    }

    public void SetAssociatedWave( AIWave InWave )
    {
        AssociatedWave = InWave;
    }

    public AIWave GetAssociatedWave()
    {
        return AssociatedWave;
    }

    private IEnumerator HeadToShootingPosition()
    {
        Animator.SetState( EnemyVATAnimator.EnemyAnimState.Walking );
        while ( Vector3.Distance( new Vector3( transform.position.x, 0.0f, transform.position.z ), Destination ) > 1.0f )
        {
            Vector3 LookPos = Destination - transform.position;
            LookPos.y = 0;
            Quaternion NewRotation = Quaternion.LookRotation(LookPos);
            transform.rotation = NewRotation;
            transform.Translate( Vector3.forward * Params.MoveSpeed * Time.deltaTime );
            UpdatePosition();
            yield return new WaitForEndOfFrame();
        }
        Animator.SetState( EnemyVATAnimator.EnemyAnimState.Idle );
    }
}
