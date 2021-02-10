using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.Interaction.Toolkit;
using static UnityEngine.XR.Interaction.Toolkit.XRBaseInteractable;

[CreateAssetMenu( fileName = "New Grabable Data", menuName = "DataAsset/Grabable", order = 1 )]
public class GrabableParams : ScriptableObject
{
    public string AttachTransformName = "AttachPoint_01";
    public MovementType MovementType = MovementType.Kinematic;
    public bool RetainTransformParent = true;
    public bool TrackPosition = true;
    public bool SmoothPosition = false;
    public float SmoothPositionAmount = 1.0f;
    public float TightenPosition = 0.5f;
    public bool TrackRotation = true;
    public bool SmoothRotation = false;
    public float SmoothRotationAmount = 1.0f;
    public float TightenRotation = 0.5f;
    public bool ThrowOnDetach = true;
    public float ThrowSmoothingDuration = 0.25f;
    public AnimationCurve ThrowSmoothingCurve;
    public float ThrowVelocityScale = 1.5f;
    public float ThrowAngularVelocityScale = 1.0f;
    public bool GravityOnDetach = true;
    public float AttachEaseInTime = 0.15f;
    
}
