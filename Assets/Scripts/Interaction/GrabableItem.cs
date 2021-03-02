using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.Interaction.Toolkit;
using UnityEngine.EventSystems;
using UnityEngine.Events;

public class GrabableItem : MonoBehaviour
{
    public GrabableParams GrabableItemParams;
    private XRGrabInteractable GrabInteractableComponent;

    private void Start()
    {
        if ( !GrabableItemParams )
        {
            Debug.LogError( "GrabableItemParams not set!" );
            return;
        }
        GrabInteractableComponent = GetComponent<XRGrabInteractable>();
        if ( !GrabInteractableComponent )
        {
            GrabInteractableComponent = gameObject.AddComponent<XRGrabInteractable>();
        }

        ApplyGrabParams();
        BindInteracts();
    }

    private void OnValidate()
    {
        ApplyGrabParams();
    }

    void ApplyGrabParams()
    {
        if ( GrabableItemParams && GrabInteractableComponent )
        {
            GrabInteractableComponent.movementType = GrabableItemParams.MovementType;
            GrabInteractableComponent.retainTransformParent = GrabableItemParams.RetainTransformParent;
            GrabInteractableComponent.trackPosition = GrabableItemParams.TrackPosition;
            GrabInteractableComponent.smoothPosition = GrabableItemParams.SmoothPosition;
            GrabInteractableComponent.smoothPositionAmount = GrabableItemParams.SmoothPositionAmount;
            GrabInteractableComponent.tightenPosition = GrabableItemParams.TightenPosition;
            GrabInteractableComponent.trackRotation = GrabableItemParams.TrackRotation;
            GrabInteractableComponent.smoothRotation = GrabableItemParams.SmoothRotation;
            GrabInteractableComponent.smoothRotationAmount = GrabableItemParams.SmoothRotationAmount;
            GrabInteractableComponent.tightenRotation = GrabableItemParams.TightenRotation;
            GrabInteractableComponent.throwOnDetach = GrabableItemParams.ThrowOnDetach;
            GrabInteractableComponent.throwSmoothingDuration = GrabableItemParams.ThrowSmoothingDuration;
            GrabInteractableComponent.throwSmoothingCurve = GrabableItemParams.ThrowSmoothingCurve;
            GrabInteractableComponent.throwVelocityScale = GrabableItemParams.ThrowVelocityScale;
            GrabInteractableComponent.throwAngularVelocityScale = GrabableItemParams.ThrowAngularVelocityScale;
            GrabInteractableComponent.forceGravityOnDetach = GrabableItemParams.GravityOnDetach;
            GrabInteractableComponent.attachEaseInTime = GrabableItemParams.AttachEaseInTime;
            GrabInteractableComponent.attachTransform = transform.Find( GrabableItemParams.AttachTransformName );
            
        } 
    }

    void BindInteracts()
    {
        GrabInteractableComponent.selectEntered.AddListener( OnSelectEntered );
        GrabInteractableComponent.selectExited.AddListener( OnSelectExited );
        GrabInteractableComponent.activated.AddListener( OnActivate );
        GrabInteractableComponent.deactivated.AddListener( OnDeactivate );
    }

    public virtual void OnSelectEntered( SelectEnterEventArgs interactor )
    {
        Debug.Log( string.Format( "OnSelectEntering {0}", gameObject.name ) );
    }

    public virtual void OnSelectExited( SelectExitEventArgs interactor )
    {
        Debug.Log( string.Format( "OnSelectExiting {0}", gameObject.name ) );
    }

    public virtual void OnActivate( ActivateEventArgs Interactor )
    {
        Debug.Log( string.Format( "OnActivate {0}", gameObject.name ) );
    }

    public virtual void OnDeactivate( DeactivateEventArgs Interactor )
    {
        Debug.Log( string.Format( "OnDeactivate {0}", gameObject.name) );
    }
}
