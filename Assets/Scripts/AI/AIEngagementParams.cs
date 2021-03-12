using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu( fileName = "New AIEngagementParams", menuName = "DataAssets/AI/AIEngagementParams", order = 1 )]
public class AIEngagementParams : ScriptableObject
{
    [System.Serializable]
    public struct BarrageParams
    {
        public float Delay;
        public uint MuzzleIndex;
        public ProjectileTypes ProjectileType;
    }

    public float Cooldown;
    public List<BarrageParams> BarragesPerEngagement = new List<BarrageParams>();

    [SerializeField]
    private float DamagePerSecond;

    [ExecuteInEditMode]
    private void OnValidate()
    {
        float TotalDamage = 0.0f;
        float TotalTime = 0.0f;
        if ( GameState.TryGetGameService<ProjectileService>( out ProjectileService ProjectileServiceRef ) )
        {
            foreach ( BarrageParams Shot in BarragesPerEngagement )
            {
                Projectile ProjectileRef = ProjectileServiceRef.GetProjectileForUnitType(Shot.ProjectileType);
                TotalDamage += ProjectileRef.ProjectileDamage;
                TotalTime += Shot.Delay;
            }
            TotalTime += Cooldown;
        }
        DamagePerSecond = TotalDamage / TotalTime;
    }

}
