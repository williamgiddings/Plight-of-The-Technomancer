using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AISurfaceProjectionService : MonoBehaviour
{
    public LayerMask DowncastLayerMask;
    public float Distance;
    public float Radius;

    public static AISurfaceProjectionService Instance;

    private void Start()
    {
        Instance = this;
    }

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
}
