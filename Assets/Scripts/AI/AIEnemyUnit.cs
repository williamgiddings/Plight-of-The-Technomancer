using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIEnemyUnit : AIAgent
{
    private AIWave AssociatedWave;
    private Damageable DamageableComponent;

    protected override void Start()
    {
        base.Start();
        DamageableComponent = GetComponent<Damageable>();
        Damageable.OnHealthZero += Damageable_OnHealthZero;
    }

    public void Init()
    {
        StartCoroutine( HeadToShootingPosition() );
    }

    private void Damageable_OnHealthZero( DamageSource Source )
    {
        AssociatedWave.OnUnitDestroyed( this );
        Destroy( gameObject );
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
        while ( Vector3.Distance( transform.position, Destination ) >= 1.0f )
        {
            transform.LookAt( Destination, Vector3.up );
            transform.Translate( Vector3.forward * Params.MoveSpeed * Time.deltaTime );
            UpdatePosition();
            yield return new WaitForEndOfFrame();
        }
    }
}
