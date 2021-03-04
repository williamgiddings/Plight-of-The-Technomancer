using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIEnemyUnit : AIAgent
{
    public AIUnitParams Params;

    private EnemyVATAnimator Animator;
    private AIWave AssociatedWave;

    public void Init()
    {
        Animator = GetComponent<EnemyVATAnimator>();
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
        Animator.SetState( EnemyVATAnimator.EnemyAnimState.Walking );
        while ( Vector3.Distance( new Vector3( transform.position.x, 0.0f, transform.position.z ), Destination ) > 1.0f )
        {
            Vector3 LookPos = Destination - transform.position;
            LookPos.y = 0;
            Quaternion NewRotation = Quaternion.LookRotation(LookPos);
            transform.rotation = NewRotation;
            transform.Translate( Vector3.forward * Params.MoveSpeed * Time.deltaTime );
            UpdatePosition();
            yield return new WaitForEndOfFrame();
        }
        Animator.SetState( EnemyVATAnimator.EnemyAnimState.Idle );
    }
}
