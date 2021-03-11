using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AirLock : MonoBehaviour
{
    public float DoorSpeed;
    public float DoorOpenThreshold;
    public SkinnedMeshRenderer DoorMesh;

    private BoxCollider DoorCollider;
    private bool Opening = false;

    private void OnEnable()
    {
        if ( DoorMesh )
        {
            DoorCollider = DoorMesh.transform.GetComponent<BoxCollider>();
        }
    }

    void OnTriggerEnter(Collider Other)
    {
        if (Other.tag == "Player")
        {
            Opening = true;
        }
    }

    void OnTriggerExit( Collider Other )
    {
        if ( Other.tag == "Player" )
        {
            Opening = false;
        }
    }

    private void FixedUpdate()
    {
        float DoorBlendState = DoorMesh.GetBlendShapeWeight( 1 );

        if ( !Opening )
        {
            if ( DoorBlendState > 0.0f )
            {
                DoorMesh.SetBlendShapeWeight( 1, DoorBlendState - ( 1.0f * DoorSpeed ) );
            }
            else
            {
                DoorMesh.SetBlendShapeWeight( 1, 0.0f );
            }
            if ( DoorBlendState < 1-DoorOpenThreshold )
            {
                DoorCollider.enabled = true;
            }
        }
        else
        {
            if ( DoorBlendState < 100.0f )
            {
                DoorMesh.SetBlendShapeWeight( 1, DoorBlendState + ( 1.0f * DoorSpeed ) );
            }
            else
            {
                DoorMesh.SetBlendShapeWeight( 1, 100.0f );
            }

            if (DoorBlendState >= DoorOpenThreshold )
            {
                DoorCollider.enabled = false;
            }
        }
    }

}
