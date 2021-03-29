using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIEngager
{
    public event DelegateUtils.VoidDelegateGenericArg<float> onBarrageFinished;
    
    private Entity Owner;
    private ProjectileService ProjectileServiceInstance;
    private List<AIEngagementParams.BarrageParams> BarrageParams;
    private Transform[] Muzzles;

    private int ShotsRemainingInBarrage = 0;
    private float CumulativeShotDelay = 0.0f;
    private float DamageOverride = 1.0f;

    public AIEngager( Entity InOwner, List<AIEngagementParams.BarrageParams> InBarrageParams, ref Transform[] InMuzzles, float InDamageOverride = 1.0f )
    {
        Owner = InOwner;
        ProjectileServiceInstance = GameState.GetGameService<ProjectileService>();
        BarrageParams = InBarrageParams;
        Muzzles = InMuzzles;
        DamageOverride = InDamageOverride;
    }


    public void Engage( Entity Target )
    {
        ShotsRemainingInBarrage = BarrageParams.Count;
        CumulativeShotDelay = 0.0f;
        foreach ( AIEngagementParams.BarrageParams Barrage in BarrageParams )
        {
            Owner.StartCoroutine( StartEngagement( Target, Barrage.ProjectileType, Barrage.Delay, Muzzles[Barrage.MuzzleIndex].position ) );
        }
    }

    private IEnumerator StartEngagement( Entity Target, ProjectileTypes Type, float Delay, Vector3 MuzzlePosition )
    {
        if ( Delay > 0.0f )
        {
            CumulativeShotDelay += Delay;
            yield return new WaitForSeconds( CumulativeShotDelay );
        }
        Projectile NewProjectile = ProjectileServiceInstance.CreateProjectile( Owner.gameObject, Type, Target, MuzzlePosition );
        if ( NewProjectile != null )
        {
            NewProjectile.ProjectileDamage *= DamageOverride;
        }
        OnShotFired();
    }

    private void OnShotFired()
    {
        if ( --ShotsRemainingInBarrage == 0 )
        {
            onBarrageFinished(Time.time);
        }
    }
}
