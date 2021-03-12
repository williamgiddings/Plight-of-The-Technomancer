using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIEngager
{
    public event DelegateUtils.VoidDelegateFloatArg onBarrageFinished;
    
    private Entity Owner;
    private ProjectileService ProjectileServiceInstance;
    private List<AIEngagementParams.BarrageParams> BarrageParams;
    private Transform[] Muzzles;

    private int ShotsRemainingInBarrage = 0;
    private float CumulativeShotDelay = 0.0f;

    public AIEngager( Entity InOwner, List<AIEngagementParams.BarrageParams> InBarrageParams, ref Transform[] InMuzzles )
    {
        Owner = InOwner;
        ProjectileServiceInstance = GameState.GetGameService<ProjectileService>();
        BarrageParams = InBarrageParams;
        Muzzles = InMuzzles;
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
        ProjectileServiceInstance.CreateProjectile( Owner.gameObject, Type, Target, MuzzlePosition );
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
