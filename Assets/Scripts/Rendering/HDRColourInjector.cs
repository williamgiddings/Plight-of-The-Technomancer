using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HDRColourInjector : MonoBehaviour
{
    [GradientUsage(true)]
    public Gradient LineColour;

    private void OnValidate()
    {
        LineRenderer Line = GetComponent<LineRenderer>();
        if( Line )
        {
            Line.colorGradient = LineColour;
        }
    }
}
