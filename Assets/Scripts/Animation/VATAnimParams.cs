using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu( fileName = "New VATAnimParams", menuName = "DataAssets/Animation/VAT/Animation", order = 2 )]
public class VATAnimParams : ScriptableObject
{
    [Header("Animation Textures")]
    public Texture2D PositionMap;
    public Texture2D NormalMap;

    [Header("Animation Settings")]
    public float DefaultSpeed;
    public int StartFrame;
    public int NumberOfFrames;
    public float PositionMin;
    public float PositionMax;
}
