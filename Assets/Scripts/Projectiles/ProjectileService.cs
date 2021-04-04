using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum ProjectileTypes
{
    Fire,
    Arc,
    Kinetic,
    Blast,
    Friendly
}

[System.Serializable]
public struct UnitProjectileBinding
{
    public ProjectileTypes UnitType;
    public Projectile ProjectileType;
}

[System.Serializable]
public class Projectile
{
    [System.Serializable]
    public struct ProjectileAppearanceData
    {
        public Mesh ProjectileMesh;
        public Material ProjectileMaterial;
    }
    
    [Header("Projectile Stats")]
    public float ProjectileSpeed;
    public float ProjectileDamage;
    public ProjectileTypes DamageType;

    [Header("Projectile Appearance")]
    public ProjectileAppearanceData Appearance;
    public Vector3 Scale;
    public GameObject ImpactParticle;
   
    private float TimeUnitlImpact;

    private Matrix4x4 ProjectileTransform;
    private Vector3 ProjectileDirection;
    private Vector3 ProjectileOrigin;

    public Matrix4x4 GetMatrix()
    {
        return ProjectileTransform;
    }

    public bool Tick( float DeltaTime ) //returns true if done
    {
        TimeUnitlImpact -= DeltaTime;
        Vector3 NewPosition = ProjectileTransform.ExtractPosition() + (ProjectileDirection * ( ProjectileSpeed * DeltaTime ));
        ProjectileTransform.SetTRS( NewPosition, Quaternion.LookRotation( ProjectileDirection, Vector3.up ), Scale );

        return TimeUnitlImpact <= 0.0f;     
    }

    public Projectile Create( ProjectileHitInformation HitInfo, Vector3 Origin, Vector3 Direction )
    {
        Projectile NewProjectile = ( Projectile ) this.MemberwiseClone();

        NewProjectile.TimeUnitlImpact = HitInfo.HitDistance / NewProjectile.ProjectileSpeed;
        NewProjectile.ProjectileDirection = Direction;
        NewProjectile.ProjectileTransform = Matrix4x4.TRS( Origin, Quaternion.LookRotation( NewProjectile.ProjectileDirection, Vector3.up ), NewProjectile.Scale );
        NewProjectile.ProjectileOrigin = Origin;

        return NewProjectile;
    }

    public Vector3 GetOrigin()
    {
        return ProjectileOrigin;
    }
}

public struct ProjectileHitInformation
{
    public Vector3 HitPosition;
    public Vector3 HitNormal;
    public float HitDistance;
    public GameObject HitEntity;
    public Entity TargetEntity;
    public GameObject ProjectileOwner;

    public ProjectileHitInformation( RaycastHit InHit, GameObject Owner, Entity Target )
    {
        HitPosition = InHit.point;
        HitNormal = InHit.normal;
        HitDistance = InHit.distance;
        HitEntity = InHit.transform.gameObject;
        TargetEntity = Target;
        ProjectileOwner = Owner;
    }
}


public class ProjectileService : GameService
{
    public LayerMask ProjectileLayerMask;
    public List<UnitProjectileBinding> ProjectileBindings = new List<UnitProjectileBinding>();
    public Camera FPSCamera;

    private Dictionary<Projectile, ProjectileHitInformation> PredeterminedProjectilePaths = new Dictionary<Projectile, ProjectileHitInformation>();

    private class ProjectileMatrixData
    {
        public List<Projectile> ProjectileCollection;
        public List<Matrix4x4> MatrixCollection;

        public ProjectileMatrixData()
        {
            ProjectileCollection = new List<Projectile>();
            MatrixCollection = new List<Matrix4x4>();
        }
    }

    public Projectile CreateProjectile( GameObject Owner, ProjectileTypes UnitProjectileType, Entity Target, Vector3 StartPosition )
    {    
        Vector3 Direction = Target ? GetCenterMassTargetDir(StartPosition, Target) : Owner.transform.forward;
        if ( Physics.Raycast(StartPosition, Direction, out RaycastHit Hit, ProjectileLayerMask ) )
        {
            Projectile ProjectileType = GetProjectileForUnitType(UnitProjectileType);
            ProjectileHitInformation HitInfo = new ProjectileHitInformation(Hit, Owner, Target);

            if ( ProjectileType != null )
            {
                Projectile NewProjectile = ProjectileType.Create( HitInfo, StartPosition, Direction );
                PredeterminedProjectilePaths.Add( NewProjectile, HitInfo );
                return NewProjectile;
            }
        }
        
        return null;
    }

    private Vector3 GetCenterMassTargetDir( Vector3 StartPosition, Entity Target )
    {
        return -( StartPosition - (Target.transform.position+Target.GetCenterMass()) ).normalized;
    }

    void RemoveProjectile( Projectile OldProjectile )
    {
        PredeterminedProjectilePaths.Remove( OldProjectile );
    }

    public Projectile GetProjectileForUnitType( ProjectileTypes UnitType )
    {
        return ProjectileBindings.Find( Binding => Binding.UnitType == UnitType ).ProjectileType;
    }

    private void Update()
    {
        Dictionary<ProjectileTypes, ProjectileMatrixData> ProjectileDataSet = new Dictionary<ProjectileTypes, ProjectileMatrixData>();
        List<Projectile> RemoveQueue = new List<Projectile>();
        
        foreach ( KeyValuePair<Projectile, ProjectileHitInformation> ActiveProjectile in PredeterminedProjectilePaths )
        {
            if ( ActiveProjectile.Key.Tick( Time.deltaTime ) )
            {
                //Hit!
                ProcessHit( ActiveProjectile );
                RemoveQueue.Add(ActiveProjectile.Key);
            }
            if ( ProjectileDataSet.TryGetValue( ActiveProjectile.Key.DamageType, out ProjectileMatrixData Data ) )
            {
                Data.ProjectileCollection.Add( ActiveProjectile.Key );
                Data.MatrixCollection.Add( ActiveProjectile.Key.GetMatrix() );
            }
            else
            {
                ProjectileMatrixData NewData = new ProjectileMatrixData();
                NewData.ProjectileCollection.Add( ActiveProjectile.Key );
                NewData.MatrixCollection.Add( ActiveProjectile.Key.GetMatrix() );
                ProjectileDataSet.Add( ActiveProjectile.Key.DamageType, NewData );
            }
        }
        CleanUpProjectiles(RemoveQueue);    
        RenderProjectiles( ProjectileDataSet );
    }

    private void CleanUpProjectiles( List<Projectile> InRemoveQueue )
    {
        InRemoveQueue.ForEach( ProjectileToRemove => RemoveProjectile( ProjectileToRemove ) );
        InRemoveQueue.Clear();
    }

    void RenderProjectiles( Dictionary<ProjectileTypes, ProjectileMatrixData> RenderableProjectiles )
    {
        foreach ( KeyValuePair<ProjectileTypes, ProjectileMatrixData> ProjectileTypes in RenderableProjectiles )
        {
            if ( ProjectileTypes.Value.ProjectileCollection.Count > 0)
            {
                Projectile.ProjectileAppearanceData Appearance = ProjectileTypes.Value.ProjectileCollection[0].Appearance;
                Graphics.DrawMeshInstanced( Appearance.ProjectileMesh, 0, Appearance.ProjectileMaterial, ProjectileTypes.Value.MatrixCollection, null, UnityEngine.Rendering.ShadowCastingMode.Off, false, 10 );
            }
            ProjectileTypes.Value.MatrixCollection.Clear();
            ProjectileTypes.Value.ProjectileCollection.Clear();
        }
        RenderableProjectiles.Clear();
    }

    void ProcessHit( KeyValuePair<Projectile, ProjectileHitInformation> ProjectileInfo )
    {
        Projectile ProjectileReference = ProjectileInfo.Key;
        ProjectileHitInformation HitInfo = ProjectileInfo.Value;
        
        if ( HitInfo.TargetEntity )
        {
            bool OnTarget = HitInfo.TargetEntity.gameObject == HitInfo.HitEntity;

            if ( OnTarget )
            {
                HitInfo.TargetEntity.TryDealDamage( new DamageSource( ProjectileReference.DamageType, HitInfo.ProjectileOwner, ProjectileInfo.Key.ProjectileDamage, ProjectileReference.GetOrigin() ) );
            }
        }

        if ( ProjectileReference.ImpactParticle )
        {
            if ( IsProjectileImpactVisible( HitInfo.HitPosition ) )
            {
                GameObject Effect = CFX_SpawnSystem.GetNextObject( ProjectileReference.ImpactParticle );
                Effect.transform.position = HitInfo.HitPosition;
                Effect.transform.up = HitInfo.HitNormal;
            }
        }
    }

    private bool IsProjectileImpactVisible( Vector3 ImpactPosition )
    {
        Vector3 BoundsSize = new Vector3(1,1,1);
        Bounds HitBounds = new Bounds(ImpactPosition, BoundsSize);
        Plane[] Planes = GeometryUtility.CalculateFrustumPlanes(FPSCamera);
        return GeometryUtility.TestPlanesAABB( Planes, HitBounds );
    }
}