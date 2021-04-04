using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIFriendlyUnit : AIAgent
{
    public string UnitNickName;

    public static event AIDelegates.FriendlyUnitDelegate onFriendlyUnitDestroyed;
    public static event AIDelegates.FriendlyUnitDelegate onFriendlyUnitSpawned;

    [Header("Effects")]
    public GameObject OnSpawnParticleEffect;

    [Header("Aiming Visual")]
    public Transform TurretBase;
    public Transform TurretGun;
    public MeshRenderer AimingLights;
    public float MinAimPitch;
    public float MaxAimPitch;

    private Optional<AIFriendlyUnitData> UnitData;
    private Entity CacheEntityTarget;

    protected override void Start()
    {
        base.Start();
        onFriendlyUnitSpawned( this );
        PerceptionComponent.SetHeadTransform( TurretGun.transform );
        
        if ( OnSpawnParticleEffect )
        {
            GameObject Effect = CFX_SpawnSystem.GetNextObject( OnSpawnParticleEffect );
            Effect.transform.position = transform.position;
        }
    }

    public AIFriendlyUnitData GetUnitData()
    {
        if ( UnitData )
        {
            return UnitData.Get();
        }
        Debug.Log("Unit Data Not Set!");
        return null;
    }

    protected override void OnPerceptionTargetAquired( Entity InEntity )
    {
        CacheEntityTarget = InEntity;
        AimingLights.material.SetColor( "_EmissionColor", Color.red*4.0f);
        LookAtTarget();
    }

    protected override void OnPerceptionTargetLost()
    {
        CacheEntityTarget = null;
        LookingAtTarget = false;
        
        if ( AimingLights )
        {
            AimingLights.material.SetColor( "_EmissionColor", Color.blue * 4.0f );
        }

        TurretBase.DORotate( Vector3.zero, PerceptionComponent.PerceptionParams.TargetingTime );
        TurretGun.DOLocalRotate( Vector3.zero, PerceptionComponent.PerceptionParams.TargetingTime );
    }

    public void SetUnitData( AIFriendlyUnitData Modifier )
    {
        AISpawnService SpawnService = GameState.GetGameService<AISpawnService>();

        AIFriendUnitParams DefaultParams = SpawnService?.GlobalParams?.FriendlyUnitDefaults;

        if ( DefaultParams )
        {
            UnitData = new AIFriendlyUnitData( DefaultParams );
            UnitData.Get().Combine( Modifier );

            ResistingDamageable DamageableComponentAsResisting = GetComponent<ResistingDamageable>();
            if ( DamageableComponentAsResisting )
            {
                DamageableComponentAsResisting.SetResistances( UnitData.Get().Resistances );
            } 
        }
    }

    protected override void OnDie()
    {
        base.OnDie();
        onFriendlyUnitDestroyed( this );
    }

    protected override void LookAtTarget()
    {
        LookingAtTarget = false;

        Quaternion NewBaseRotation = GetTurretRotation();
        Quaternion NewTurretAngle = GetGunRotation();

        Sequence LookAtSequence = DOTween.Sequence();
        LookAtSequence.Append( TurretBase.DORotate( NewBaseRotation.eulerAngles, PerceptionComponent.PerceptionParams.TargetingTime ) );
        LookAtSequence.Append( TurretGun.DOLocalRotate( NewTurretAngle.eulerAngles, PerceptionComponent.PerceptionParams.TargetingTime ) );
        LookAtSequence.onComplete += delegate () { LookingAtTarget = true; };
    }

    Quaternion GetTurretRotation()
    {
        Vector3 TurretLookPos = CacheEntityTarget.transform.position - TurretBase.transform.position;
        Quaternion NewBaseRotation = Quaternion.LookRotation(new Vector3(TurretLookPos.x, 0.0f, TurretLookPos.z ) );

        return NewBaseRotation;
    }

    Quaternion GetGunRotation()
    {
        Vector3 GunLookPos = (CacheEntityTarget.transform.position+CacheEntityTarget.GetCenterMass()) - TurretGun.transform.position;

        float NewAnglePitch = -GunLookPos.y;
        NewAnglePitch = Mathf.Clamp( NewAnglePitch, MinAimPitch, MaxAimPitch );
        Quaternion NewTurretAngle = Quaternion.Euler( NewAnglePitch, 0.0f, 0.0f );
        return NewTurretAngle;
    }

    private void FixedUpdate()
    {
        if ( Engager != null )
        {
            if ( CacheEntityTarget && LookingAtTarget )
            {
                Quaternion NewBaseRotation = GetTurretRotation();
                Quaternion NewTurretAngle = GetGunRotation();

                TurretBase.rotation = NewBaseRotation;
                TurretGun.localRotation = NewTurretAngle;

                if ( ReadyToEngage && Time.time >= ( LastEngageTime + EngagementParams.Cooldown ) )
                {
                    ReadyToEngage = false;
                    Engager.Engage( CacheEntityTarget );
                }
            }
        }       
    }

}
