using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIAgent : MonoBehaviour
{
    public AIUnitParams Params;

    protected Vector3 Destination;

    private AISurfaceProjectionService SurfaceProjectionService;

    protected virtual void Start()
    {
        SurfaceProjectionService = GameState.GetGameService<AISurfaceProjectionService>();
    }

    protected void UpdatePosition()
    {
        if ( SurfaceProjectionService )
        {
            transform.position = SurfaceProjectionService.GetProjectedPosition( transform.position, Params.GroundOffset );
        }
    }

    public void SetDestination( Vector3 InDestination )
    {
        Destination = InDestination;
    }
}
