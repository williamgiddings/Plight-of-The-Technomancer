using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.Interaction.Toolkit;
using UnityEngine.UI;
using UnityEngine.EventSystems;

public class SpawnerDisplayReticle : MonoBehaviour
{
    bool Interacting = false;
    PointerEventData EventData;
    Image ImageSprite;

    private void Start()
    {
        ImageSprite = GetComponent<Image>();
    }

    public void ResumeMovement()
    {
        Interacting = true;
    }

    public void PauseMovement()
    {
        Interacting = false;
    }


    public void StartMoving( PointerEventData Event )
    {
        Interacting = true;
        EventData = Event;
        ImageSprite.enabled = true;
    }

    public void StopMoving()
    {
        Interacting = false;
        ImageSprite.enabled = false;
    }

    public Vector2 Select()
    {
        return new Vector2( transform.localPosition.x, transform.localPosition.y );
    }

    private void Update()
    {
        if ( Interacting )
        {
            if ( EventData != null )
            {
                transform.position = EventData.pointerCurrentRaycast.worldPosition;
            }
        }
    }


}
