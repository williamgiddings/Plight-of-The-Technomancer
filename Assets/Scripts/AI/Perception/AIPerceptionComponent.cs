using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif


#if UNITY_EDITOR
public struct DebugPercievedEntityCache
{
    public Entity Ent;
    public DebugScoreCache Scores;
    public float TotalScore;

    public struct DebugScoreCache
    {
        public float DistanceScore;
        public float AngleScore;


        public DebugScoreCache( float InDistanceScore, float InAngleScore )
        {
            DistanceScore = InDistanceScore;
            AngleScore = InAngleScore;
        }
    }

    public DebugPercievedEntityCache( Entity InEnt, float InScore, DebugScoreCache ScoreBreakDown )
    {
        Ent = InEnt;
        Scores = ScoreBreakDown;
        TotalScore = InScore;
    }
}
#endif

public class AIPerceptionComponent : MonoBehaviour
{
    [Header("Agent Params")]
    public AIPerceptionParams PerceptionParams;

    //Events
    public DelegateUtils.VoidDelegateEntityArg onTargetAquired;
    public DelegateUtils.VoidDelegateNoArgs onTargetLost;


    private Entity ThisEntity;
    private Entity CurrentTarget;
    private float CurrentTargetScore;
    private AIPerceptionService CachedAIPerceptionService;
    private Optional<Transform> OverrideHeadRelativeTransform;

#if UNITY_EDITOR
    private List<DebugPercievedEntityCache> DebugPercievedEntities =  new List<DebugPercievedEntityCache>();
#endif

    private void Start()
    {
        ThisEntity = GetComponent<Entity>();
        Entity.onEntityDestroyed += OnEntityDestroyed;
        CachedAIPerceptionService = GameState.GetGameService<AIPerceptionService>();

        if ( CachedAIPerceptionService )
        {
            CachedAIPerceptionService.RegisterPerciever( this );
        }
    }

    public void SetHeadTransform( Transform NewHead )
    {
        OverrideHeadRelativeTransform = NewHead;
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
        if ( Target != null )
        {
            Target.Target();
            if ( CurrentTarget )
            {
                CurrentTarget.UnTarget();
            }
            onTargetAquired( Target );
        }
        else if ( Target != CurrentTarget  )
        {
            onTargetLost();
        }
        CurrentTarget = Target;
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

        foreach( DebugPercievedEntityCache CachedEnt in DebugPercievedEntities )
        {
            if ( CachedEnt.Ent )
            {
                Vector3 EntityPos = CachedEnt.Ent.gameObject.transform.position + CachedEnt.Ent.GetCenterMass();
                GizmoColor = Color.magenta;
                Handles.color = GizmoColor;
                Handles.Label( EntityPos,
                    string.Format( "Total Score: {0}\nDistanceScore: {1}(x{2})\nAngleScore: {3}(x{4})",
                    CachedEnt.TotalScore,
                    CachedEnt.Scores.DistanceScore,
                    PerceptionParams.DistanceScoreWeighting,
                    CachedEnt.Scores.AngleScore,
                    PerceptionParams.AngleScoreWeighting
                    ) );
                Gizmos.color = GizmoColor;
                Gizmos.DrawLine( EyePosition, EntityPos );
            }
        }
    }
#endif

    public Entity GetCurrentTarget()
    {
        return CurrentTarget;
    }

    public void TickPerception()
    {
        AquireNewTarget();
    }

    public virtual void AquireNewTarget()
    {
        #if UNITY_EDITOR
        DebugPercievedEntities.Clear();
        #endif

        List<Entity> HostileUnits = CachedAIPerceptionService.GetHostileUnitsForFaction(ThisEntity.AllignedFaction);

        Entity BestTarget = null;
        float BestScore = 0.0f;

        foreach ( Entity Ent in HostileUnits )
        {
            if ( !Ent ) continue;
            float UnitTargetScore = 0.0f;

            Vector3 EyePosition = transform.position + ( Vector3.up * PerceptionParams.EyeHeight );
            Vector3 UnitLocation = Ent.transform.position + Ent.GetCenterMass();
            Vector3 DirectionTo = (UnitLocation - EyePosition).normalized;

            Vector3 LookDirection = OverrideHeadRelativeTransform ? OverrideHeadRelativeTransform.Get().forward : transform.forward;

            float DistanceTo = Vector3.Distance( UnitLocation, transform.position );
            float AngleInFront = Mathf.Abs( Vector3.Angle( LookDirection, DirectionTo ) );

            RaycastHit HitInfo;
            Physics.Raycast( EyePosition, DirectionTo, out HitInfo, PerceptionParams.MaxTargetingRange, PerceptionParams.TargetingPerceptionLayers );

            bool CanSee = HitInfo.transform && ReferenceEquals( HitInfo.transform.gameObject, Ent.gameObject);
            bool InRange = DistanceTo < PerceptionParams.MaxTargetingRange;
            bool InSight = AngleInFront < PerceptionParams.MaxTargetingAngle && CanSee;

            float DistanceScore = ( 1.0f - ( DistanceTo / PerceptionParams.MaxTargetingRange ) ) * PerceptionParams.DistanceScoreWeighting;
            float AngleScore = ( 1.0f - ( AngleInFront / PerceptionParams.MaxTargetingAngle ) )  * PerceptionParams.AngleScoreWeighting;

            UnitTargetScore += DistanceScore;
            UnitTargetScore += AngleScore;

            if ( PerceptionParams.UsePopularityUnBiasing )
            {
                if ( Ent.TargetedBy() > 0 )
                {
                    UnitTargetScore = ( UnitTargetScore / Ent.TargetedBy() ) * 1.5f; // Popularity un-bias
                }
            }

            UnitTargetScore *= PerceptionParams.Targetable.Contains( Ent.Type ) ? 1.0f : 1.0f - PerceptionParams.TargetableTypePickiness;
            UnitTargetScore *= CanSee ? 1.0f : 0.0f;

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
            #if UNITY_EDITOR
            DebugPercievedEntities.Add( new DebugPercievedEntityCache( 
                Ent, 
                UnitTargetScore,
                new DebugPercievedEntityCache.DebugScoreCache(
                    DistanceScore,
                    AngleScore )
                ) 
            );
            #endif
        }

        if ( BestTarget != CurrentTarget )
        {
            if ( !CurrentTarget )
            {
                SetNewTarget( BestTarget );
            }
            else if ( (BestScore >= CurrentTargetScore * PerceptionParams.RetargetThreshold) || BestTarget == null )
            {
                SetNewTarget( BestTarget );
            }
        }
    }

    private void OnEntityDestroyed( Entity DestroyedEntity )
    {
        if ( DestroyedEntity == CurrentTarget )
        {
            if ( onTargetLost != null ) onTargetLost();
        }
    }
}
