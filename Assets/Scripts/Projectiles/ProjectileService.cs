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
   
    private float TimeUnitlImpact;

    private Matrix4x4 ProjectileTransform;
    private Vector3 ProjectileDirection;

    public Projectile( Projectile Template, ProjectileHitInformation HitInfo, Vector3 Origin, Vector3 Direction )
    {
        ProjectileSpeed = Template.ProjectileSpeed;
        Scale = Template.Scale;
        DamageType = Template.DamageType;

        Appearance = new ProjectileAppearanceData() 
        { 
            ProjectileMesh = Template.Appearance.ProjectileMesh,
            ProjectileMaterial = Template.Appearance.ProjectileMaterial
        };

        TimeUnitlImpact = HitInfo.HitDistance / ProjectileSpeed;
        ProjectileDirection = Direction;
        ProjectileTransform = Matrix4x4.TRS( Origin, Quaternion.LookRotation( ProjectileDirection, Vector3.up ), Scale );
    }

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

    public override void InitialiseGameService()
    {
        base.InitialiseGameService();

        // ...    
    }

    public Projectile CreateProjectile( GameObject Owner, ProjectileTypes UnitProjectileType, Entity Target, Vector3 StartPosition  )
    {    
        Vector3 Direction = Target ? GetCenterMassTargetDir(StartPosition, Target) : Owner.transform.forward;
        if ( Physics.Raycast(StartPosition, Direction, out RaycastHit Hit, ProjectileLayerMask ) )
        {
            Projectile ProjectileType = GetProjectileForUnitType(UnitProjectileType);
            ProjectileHitInformation HitInfo = new ProjectileHitInformation(Hit, Owner, Target);

            if ( ProjectileType != null )
            {
                PredeterminedProjectilePaths.Add( new Projectile( ProjectileType, HitInfo, StartPosition, Direction ), HitInfo );
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
        RenderProjectiles( ProjectileDataSet );
        CleanUpProjectiles(RemoveQueue);
    }

    private void CleanUpProjectiles( List<Projectile> InRemoveQueue )
    {
        InRemoveQueue.ForEach( ProjectileToRemove => RemoveProjectile( ProjectileToRemove ) );
    }

    void RenderProjectiles( Dictionary<ProjectileTypes, ProjectileMatrixData> RenderableProjectiles )
    {
        foreach ( KeyValuePair<ProjectileTypes, ProjectileMatrixData> ProjectileTypes in RenderableProjectiles )
        {
            if ( ProjectileTypes.Value.ProjectileCollection.Count > 0)
            {
                Projectile.ProjectileAppearanceData Appearance = ProjectileTypes.Value.ProjectileCollection[0].Appearance;
                Graphics.DrawMeshInstanced( Appearance.ProjectileMesh, 0, Appearance.ProjectileMaterial, ProjectileTypes.Value.MatrixCollection );
            }
        }
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
                HitInfo.TargetEntity.TryDealDamage( new DamageSource( ProjectileReference.DamageType, HitInfo.ProjectileOwner, ProjectileInfo.Key.ProjectileDamage ) );
            }
        }
    }
}