using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.Interaction.Toolkit;

public class UIInteractable : XRSimpleInteractable
{
    private void Start()
    {
        base.onHoverEntered.AddListener( OnHoverEnter_Impl );
        base.onHoverExited.AddListener( OnHoverExit_Impl );        
    }

    private void OnHoverEnter_Impl( XRBaseInteractor BaseInteractor )
    {
        XRInteractorLineVisual Visual = BaseInteractor.GetComponent<XRInteractorLineVisual>();
        
        if ( Visual )
        {
            Visual.enabled = true;
        }
    }

    private void OnHoverExit_Impl( XRBaseInteractor BaseInteractor )
    {
        XRInteractorLineVisual Visual = BaseInteractor.GetComponent<XRInteractorLineVisual>();

        if ( Visual )
        {
            Visual.enabled = false;
        }
    }
}
