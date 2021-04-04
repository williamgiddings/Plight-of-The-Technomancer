using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


public class Binoculars : MonoBehaviour
{
    [Header("Binoculars")]
    public float MinimumFOV = 15f;
    public float MaxPostProcessValue;
    public float ZoomSpeed;
    public GameObject BinocularUI;
    
    private Camera CameraRef;
    private float MaximumFOV;
    private float CurrentBlendValue;
    private bool InBinoculars = false;

    [Header("Compass")]
    public RawImage CompassUI;
    private float DefaultCompassUVx = 0.5525f;

    private Volume PostFX;
    private LensDistortion LensDistortionEffect;
    private Vignette VignetteEffect;

    private void Start()
    {
        CameraRef = GetComponent<Camera>();
        PostFX = GetComponent<Volume>();
        MaximumFOV = CameraRef.fieldOfView;
        InitPostFX();
    }

    private void InitPostFX()
    {
        PostFX.profile.TryGet<LensDistortion>( out LensDistortionEffect );
        PostFX.profile.TryGet<Vignette>( out VignetteEffect );
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Mouse0))
        {
            EnterBinoculars();
        }
        else if ( Input.GetKeyUp( KeyCode.Mouse0 ) )
        {
            ExitBinoculars();
        }
        if ( InBinoculars )
        {
            CompassUI.uvRect = new Rect( DefaultCompassUVx + ( transform.root.localEulerAngles.y / 360f ), 0, 1, 1 );
        }
    }

    void EnterBinoculars()
    {
        DOTween.To( this.BlendZoomValues, CurrentBlendValue, 1.0f, ZoomSpeed );
        BinocularUI.SetActive( true );
        InBinoculars = true;
    }

    void ExitBinoculars()
    {
        DOTween.To( this.BlendZoomValues, CurrentBlendValue, 0.0f, ZoomSpeed );
        BinocularUI.SetActive( false );
        InBinoculars = false;
    }

    void BlendZoomValues( float Value )
    {
        CurrentBlendValue = Value;
        float NewValue = MaxPostProcessValue * Value;

        LensDistortionEffect.intensity.Override( NewValue );
        VignetteEffect.intensity.Override( NewValue );

        CameraRef.fieldOfView = MaximumFOV - ( ( MaximumFOV - MinimumFOV ) * Value );
    }
}
