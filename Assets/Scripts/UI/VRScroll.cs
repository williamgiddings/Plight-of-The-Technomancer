using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR;
using UnityEngine.XR.Interaction.Toolkit;

public class VRScroll : XRBaseInteractable
{
    private ScrollRect Scroller;
    private BoxCollider CanvasCollider;
    private RectTransform Rect;

    private void Start()
    {
        ValidateComponents();
    }

    [ExecuteInEditMode]
    private void OnValidate()
    {
        ValidateComponents();
        colliders.Clear();
        colliders.Add( CanvasCollider );
        CanvasCollider.size = new Vector3( Rect.rect.width, Rect.rect.height, 0.01f );
    }
    void ValidateComponents()
    {
        if ( !CanvasCollider )
        {
            CanvasCollider = GetComponent<BoxCollider>();
        }
        if ( !Rect )
        {
            Rect = GetComponent<RectTransform>();
        }
        if (!Scroller)
        {
            Scroller = GetComponent<ScrollRect>();
        }
    }

    private void Update()
    {
        if ( isHovered )
        {
            var rightHand = InputDevices.GetDeviceAtXRNode(XRNode.RightHand);
            if ( rightHand.isValid && rightHand.TryGetFeatureValue( CommonUsages.primary2DAxis, out var scrollDelta ) )
            {
                //Scroller.velocity = scrollDelta * Scroller.scrollSensitivity;

                if ( Scroller.verticalScrollbar )
                {
                    Scroller.verticalScrollbar.value += scrollDelta.y * ( Time.deltaTime * Scroller.scrollSensitivity);
                }
                if ( Scroller.horizontalScrollbar )
                {
                    Scroller.horizontalScrollbar.value += scrollDelta.x * ( Time.deltaTime * Scroller.scrollSensitivity );
                }
            }
        }
    }

}
