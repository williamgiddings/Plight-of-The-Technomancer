using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIAgent : MonoBehaviour
{
    protected Vector3 Destination;
    protected Damageable DamageableComponent;

    private AISurfaceProjectionService SurfaceProjectionService;

    protected virtual void Start()
    {
        SurfaceProjectionService = GameState.GetGameService<AISurfaceProjectionService>();
        DamageableComponent = GetComponent<Damageable>();
        DamageableComponent.OnHealthZero += OnDie;
    }

    public Damageable GetDamageableComponent()
    {
        return DamageableComponent;
    }

    protected virtual void UpdatePosition()
    {
        if ( SurfaceProjectionService )
        {
            transform.position = SurfaceProjectionService.GetProjectedPosition( transform.position, 1.0f );
        }
    }

    public void SetDestination( Vector3 InDestination )
    {
        Destination = InDestination;
    }

    protected virtual void OnDie()
    {

    }
}
