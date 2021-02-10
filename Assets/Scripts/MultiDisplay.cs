using UnityEngine;
using System.Collections;

public class MultiDisplay : MonoBehaviour
{
    void Start()
    {
        for ( int i = 0; i < Display.displays.Length; i++ )
        {
            if (i < 2 ) Display.displays[ i ].Activate();
        }
        
    }
}