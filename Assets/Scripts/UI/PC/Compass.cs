using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Compass : MonoBehaviour
{
    public RawImage CompassUI;
    private float DefaultUVx = 0.5525f;

    void Update()
    {
        CompassUI.uvRect = new Rect( DefaultUVx + (transform.root.localEulerAngles.y / 360f), 0, 1, 1 );
    }
}
