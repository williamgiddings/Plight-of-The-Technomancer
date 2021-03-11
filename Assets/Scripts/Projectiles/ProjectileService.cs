using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public struct UnitProjectileBinding
{
    public AIEnemyUnitTypes UnitType;
    public Projectile ProjectileType;
}

public class Projectile : Transform
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
    public AIEnemyUnitTypes DamageType;

    [Header("Projectile Appearance")]
    public ProjectileAppearanceData Appearance;
    public Vector3 Scale;
   
    private float InstancingTime;
    private float TimeUnitlImpact;

    public Projectile( Projectile Template, ProjectileHitInformation HitInfo, Vector3 Origin, Vector3 Direction )
    {
        ProjectileSpeed = Template.ProjectileSpeed;

        Appearance = new ProjectileAppearanceData() 
        { 
            ProjectileMesh = Template.Appearance.ProjectileMesh,
            ProjectileMaterial = Template.Appearance.ProjectileMaterial
        };


        InstancingTime = Time.time;
        TimeUnitlImpact = InstancingTime + ( HitInfo.HitDistance / ProjectileSpeed );

        SetPositionAndRotation( Origin, Quaternion.LookRotation( Direction ) );
        localScale = Scale;
    }

    public Matrix4x4 GetMatrix()
    {
        return localToWorldMatrix;
    }

    public bool Tick( float DeltaTime ) //returns true if done
    {
        TimeUnitlImpact -= DeltaTime;
        position += forward * ( ProjectileSpeed * DeltaTime );

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

    public Projectile CreateProjectile( GameObject Owner, AIEnemyUnitTypes UnitProjectileType, Entity Target, Vector3 StartPosition  )
    {
        Vector3 Direction = (StartPosition - Target.transform.position).normalized;
        if ( Physics.Raycast(StartPosition, Direction, out RaycastHit Hit, ProjectileLayerMask ) )
        {
            Projectile ProjectileType = GetProjectileForUnitType(UnitProjectileType);
            ProjectileHitInformation HitInfo = new ProjectileHitInformation(Hit, Owner, Target);

            if ( ProjectileType )
            {
                Projectile NewProjectile = new Projectile( ProjectileType, HitInfo, StartPosition, Direction );
                PredeterminedProjectilePaths.Add( NewProjectile, HitInfo );

            }
        }
        
        return null;
    }

    void RemoveProjectile( Projectile OldProjectile )
    {
        PredeterminedProjectilePaths.Remove( OldProjectile );
    }

    private Projectile GetProjectileForUnitType( AIEnemyUnitTypes UnitType )
    {
        return ProjectileBindings.Find( Binding => Binding.UnitType == UnitType ).ProjectileType;
    }

    private void Update()
    {
        Dictionary<AIEnemyUnitTypes, ProjectileMatrixData> ProjectileDataSet = new Dictionary<AIEnemyUnitTypes, ProjectileMatrixData>();

        foreach ( KeyValuePair<Projectile, ProjectileHitInformation> ActiveProjectile in PredeterminedProjectilePaths )
        {
            if ( ActiveProjectile.Key.Tick( Time.deltaTime ) )
            {
                //Hit!
                ProcessHit( ActiveProjectile );
            }
            if ( ProjectileDataSet.TryGetValue( ActiveProjectile.Key.DamageType, out ProjectileMatrixData Data ) )
            {
                Data.ProjectileCollection.Add( ActiveProjectile.Key );
                Data.MatrixCollection.Add( ActiveProjectile.Key.GetMatrix() );
            }
        }
        RenderProjectiles( ProjectileDataSet );
    }

    void RenderProjectiles( Dictionary<AIEnemyUnitTypes, ProjectileMatrixData> RenderableProjectiles )
    {
        foreach ( KeyValuePair<AIEnemyUnitTypes, ProjectileMatrixData> ProjectileTypes in RenderableProjectiles )
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
        
        bool OnTarget = HitInfo.TargetEntity.gameObject == HitInfo.HitEntity;

        if ( OnTarget )
        {
            HitInfo.TargetEntity.TryDealDamage( new DamageSource( ProjectileReference.DamageType, HitInfo.ProjectileOwner, ProjectileInfo.Key.ProjectileDamage ) );
        }
    }
}
