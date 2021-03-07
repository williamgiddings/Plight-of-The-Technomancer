using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

public class AIPerceptionComponent : MonoBehaviour
{
    [Header("Agent Params")]
    public AIPerceptionParams PerceptionParams;

    private Entity ThisEntity;
    private Entity CurrentTarget;
    private float CurrentTargetScore;
    private AIPerceptionService CachedAIPerceptionService;

    private void Start()
    {
        ThisEntity = GetComponent<Entity>();
        CachedAIPerceptionService = GameState.GetGameService<AIPerceptionService>();

        if (CachedAIPerceptionService)
        {
            CachedAIPerceptionService.RegisterPerciever( this );
        }    
    }

    private void OnDestroy()
    {
        if ( CachedAIPerceptionService )
        {
            CachedAIPerceptionService.UnRegisterPerciever( this );
        }
    }

    protected void SetNewTarget( Entity Target )
    {
        CurrentTarget = Target;
        if ( Target != null )
        {
            Target.Target();
        }
    }

#if UNITY_EDITOR
    private void OnDrawGizmosSelected()
    {
        Vector3 EyePosition = transform.position + ( Vector3.up * PerceptionParams.EyeHeight );
        Color GizmoColor = CurrentTarget != null ? Color.green : Color.red;
        Handles.color = GizmoColor;
        Handles.Label( EyePosition, string.Format( "Target: {0}", CurrentTarget ) );
        Gizmos.color = GizmoColor;
        Gizmos.DrawLine( EyePosition, CurrentTarget ? CurrentTarget.transform.position : transform.forward * PerceptionParams.MaxTargetingRange );
    }
#endif

    protected Entity GetCurrentTarget()
    {
        return CurrentTarget;
    }

    public void TickPerception()
    {
        AquireNewTarget();
    }

    public virtual void AquireNewTarget()
    {
        List<Entity> HostileUnits = CachedAIPerceptionService.GetHostileUnitsForFaction(ThisEntity.AllignedFaction);

        Entity BestTarget = null;
        float BestScore = 0.0f;

        foreach ( Entity Ent in HostileUnits )
        {
            float UnitTargetScore = 0.0f;

            Vector3 EyePosition = transform.position + ( Vector3.up * PerceptionParams.EyeHeight );
            Vector3 UnitLocation = Ent.transform.position;
            Vector3 DirectionTo = (UnitLocation- EyePosition).normalized;
            float DistanceTo = Vector3.Distance( UnitLocation, transform.position );
            float AngleInFront = Mathf.Abs( Vector3.Angle( transform.forward, DirectionTo ) );

            RaycastHit HitInfo;
            Physics.Raycast( EyePosition, DirectionTo, out HitInfo, PerceptionParams.MaxTargetingRange, PerceptionParams.TargetingPerceptionLayers );

            bool CanSee = ReferenceEquals( HitInfo.transform, Ent.transform);
            bool InRange = DistanceTo < PerceptionParams.MaxTargetingRange;
            bool InSight = AngleInFront < PerceptionParams.MaxTargetingAngle && CanSee;

            UnitTargetScore += 1.0f - ( DistanceTo / PerceptionParams.MaxTargetingRange ); // Distance score
            UnitTargetScore += 1.0f - ( AngleInFront / PerceptionParams.MaxTargetingAngle ); // Angle score

            if ( PerceptionParams.UsePopularityUnBiasing )
            {
                if ( Ent.TargetedBy() > 0 )
                {
                    UnitTargetScore = ( UnitTargetScore / Ent.TargetedBy() ) * 1.5f; // Popularity un-bias
                }
            }

            UnitTargetScore *= PerceptionParams.Targetable.Contains( Ent.Type ) ? 1.0f : 0.25f;

            if ( Ent == CurrentTarget )
            {
                CurrentTargetScore = UnitTargetScore;
            }

            if ( InRange && InSight )
            {
                if ( UnitTargetScore >= BestScore )
                {
                    BestScore = UnitTargetScore;
                    BestTarget = Ent;
                }
            }
        }

        if ( BestTarget != CurrentTarget )
        {
            if ( BestScore >= CurrentTargetScore * PerceptionParams.RetargetThreshold )
            {
                SetNewTarget( BestTarget );
            }
        }
        else
        {
            SetNewTarget( BestTarget );
        }
    }
}
