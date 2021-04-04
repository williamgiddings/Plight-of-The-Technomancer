using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.Interaction.Toolkit;
#if UNITY_EDITOR
using UnityEditor;
#endif

[RequireComponent( typeof(Canvas) )]
[RequireComponent( typeof(BoxCollider) )]
public class VRCanvas : XRSimpleInteractable
{
    BoxCollider CanvasCollider;
    RectTransform CanvasRect;

    [ExecuteInEditMode]
    private void OnValidate()
    {
        ValidateComponents();
        colliders.Clear();
        colliders.Add( CanvasCollider );
        CanvasCollider.size = new Vector3( CanvasRect.rect.width, CanvasRect.rect.height, 0.01f);
    }

    void ValidateComponents()
    {
        if ( !CanvasCollider )
        {
            CanvasCollider = GetComponent<BoxCollider>();
        }      
        if ( !CanvasRect )
        {
            CanvasRect = GetComponent<Canvas>().transform as RectTransform;
        }
    }

#if UNITY_EDITOR
    [MenuItem( "GameObject/UI/VR Canvas" )]
    static void CreateNew( MenuCommand InMenuCommand )
    {
        GameObject Canvas = new GameObject("VR Canvas", new System.Type[]{ typeof( VRCanvas ) } );
        GameObjectUtility.SetParentAndAlign( Canvas, InMenuCommand.context as GameObject );
        Undo.RegisterCreatedObjectUndo( Canvas, "Create " + Canvas.name );
        Selection.activeObject = Canvas;
    }
#endif

    private void Start()
    {
        ValidateComponents();

        base.hoverEntered.AddListener( OnHoverEnter_Impl );
        base.hoverExited.AddListener( OnHoverExit_Impl );        
    }

    private void OnHoverEnter_Impl( HoverEnterEventArgs BaseInteractor )
    {
        XRInteractorLineVisual Visual = BaseInteractor.interactor.GetComponent<XRInteractorLineVisual>();
        
        if ( Visual )
        {
            Visual.enabled = true;
        }
    }

    private void OnHoverExit_Impl( HoverExitEventArgs BaseInteractor )
    {
        XRInteractorLineVisual Visual = BaseInteractor.interactor.GetComponent<XRInteractorLineVisual>();

        if ( Visual )
        {
            Visual.enabled = false;
        }
    }
}
