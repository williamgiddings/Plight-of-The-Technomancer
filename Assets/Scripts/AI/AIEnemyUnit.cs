using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIEnemyUnit : AIAgent
{
    private AIEnemyUnitTypes UnitType;
    private AIEnemyUnitParams Params;
    private EnemyVATAnimator Animator;
    private AIEnemyAppearanceComponent AppearanceComponent;
    private AIWave AssociatedWave;

    [Header("Aiming Visual")]
    public Transform Head;
    public float MinAimPitch;
    public float MaxAimPitch;

    [SerializeField]
    private AIEnemyScrapDropSettings ScrapSettings;
    private Entity CacheEntityTarget;
    private ScrapService ScrapServiceRef;

    [System.Serializable]
    private struct AIEnemyScrapDropSettings
    {
        public float ScrapDropRate;
        public WeightedCollection<int> ScrapAmount;
    }

    protected override void Start()
    {
        base.Start();
        Animator = GetComponent<EnemyVATAnimator>();
        AppearanceComponent = GetComponent<AIEnemyAppearanceComponent>();
        PerceptionComponent.SetHeadTransform( Head.transform );
        AppearanceComponent.SetupPartColours( UnitType );
        ScrapServiceRef = GameState.GetGameService<ScrapService>();

        StartCoroutine( HeadToShootingPosition() );
    }

    public void SetUnitParams( AIEnemyUnitParams NewParams )
    {
        Params = NewParams;
    }

    public void SetUnitType( AIEnemyUnitTypes InUnitType )
    {
        UnitType = InUnitType;
    }

    public AIEnemyUnitTypes GetUnitType()
    {
        return UnitType;
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
        if ( Engager != null )
        {
            if ( CacheEntityTarget && LookingAtTarget )
            {
                Head.rotation = GetTurretRotation();

                if ( ReadyToEngage && Time.time >= ( LastEngageTime + EngagementParams.Cooldown ) )
                {
                    ReadyToEngage = false;
                    Engager.Engage( CacheEntityTarget );
                }
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

            float AdjustedMoveSpeed = Params.MoveSpeed * GameState.GetDifficulty();

            transform.Translate( Vector3.forward * AdjustedMoveSpeed * Time.deltaTime );
            UpdatePosition();
            yield return new WaitForEndOfFrame();
        }
        Animator.SetState( EnemyVATAnimator.EnemyAnimState.Idle );
    }

    protected override void OnDie()
    {
        base.OnDie();
        AssociatedWave.OnUnitDestroyed( this );
        DropScrap();
        Destroy( gameObject );
    }

    private void DropScrap()
    {
        if ( Random.Range(0.0f, 1.0f) <= ScrapSettings.ScrapDropRate )
        {
            ScrapServiceRef.CreateScrapPickup( transform.position, ScrapSettings.ScrapAmount.Get( Random.Range( 0.0f, 1.0f ) ) );
        }
    }
}
