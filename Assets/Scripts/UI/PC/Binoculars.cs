using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class Binoculars : MonoBehaviour
{
    public float MinimumFOV = 15f;
    public float MaxPostProcessValue;
    public float ZoomSpeed;
    public GameObject BinocularUI;
    
    private Camera Cam;
    private float MaximumFOV;
    private float CurrentBlendValue;

    //PostFX
    private Volume PostFX;
    private LensDistortion LD;
    private Vignette V;

    private void Start()
    {
        Cam = GetComponent<Camera>();
        PostFX = GetComponent<Volume>();
        MaximumFOV = Cam.fieldOfView;
        InitPostFX();
    }

    void InitPostFX()
    {
        PostFX.profile.TryGet<LensDistortion>( out LD );
        PostFX.profile.TryGet<Vignette>( out V );
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.LeftControl))
        {
            EnterBinoculars();
        }
        else if ( Input.GetKeyUp( KeyCode.LeftControl ) )
        {
            ExitBinoculars();
        }
    }

    void EnterBinoculars()
    {
        DOTween.To( this.BlendZoomValues, CurrentBlendValue, 1.0f, ZoomSpeed );
        BinocularUI.SetActive( true );
    }

    void ExitBinoculars()
    {
        DOTween.To( this.BlendZoomValues, CurrentBlendValue, 0.0f, ZoomSpeed );
        BinocularUI.SetActive( false );
    }

    void BlendZoomValues( float Value )
    {
        CurrentBlendValue = Value;
        float NewValue = MaxPostProcessValue * Value;

        LD.intensity.Override( NewValue );
        V.intensity.Override( NewValue );
        Cam.fieldOfView = MaximumFOV - ( ( MaximumFOV - MinimumFOV ) * Value);
    }
}
