using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIAgent : MonoBehaviour
{
    public float GroundOffset;

    private void FixedUpdate()
    {
        AISurfaceProjectionService Surface = AISurfaceProjectionService.Instance;

        if ( Surface )
        {
            transform.position = Surface.GetProjectedPosition( transform.position, GroundOffset );
        }

    }
}
