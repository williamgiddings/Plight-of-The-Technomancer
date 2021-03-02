using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AISurfaceProjectionService : GameService
{
    public LayerMask DowncastLayerMask;
    public float Distance;
    public float Radius;

    public Vector3 GetProjectedPosition( Vector3 OriginalPosition, float GroundOffset )
    {
        RaycastHit RayHit;
        bool Hit = Physics.SphereCast( OriginalPosition + (Vector3.up * 5.0f), Radius, Vector3.down, out RayHit, Distance, DowncastLayerMask );
        Debug.DrawRay( OriginalPosition + ( Vector3.up * 5.0f ), Vector3.down * Distance, Color.red );
        if ( Hit )
        {
            return new Vector3( OriginalPosition.x, RayHit.point.y + GroundOffset, OriginalPosition.z );
        }
        return OriginalPosition;
    }

    public float GetGlobalDownCastDepth( Vector2 GlobalXZ )
    {
        if ( Physics.Raycast( new Vector3( GlobalXZ.x, 50.0f, GlobalXZ.y ), Vector3.down, out RaycastHit Hit, DowncastLayerMask ) )
        {
            return Hit.point.y;
        }
        return 0.0f;
    }
}
