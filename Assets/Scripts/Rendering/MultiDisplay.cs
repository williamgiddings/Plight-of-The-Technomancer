using UnityEngine;
using System.Collections;

public class MultiDisplay : MonoBehaviour
{
    void Start()
    {
        Display.displays[0].Activate();
        Display.displays[1].Activate();
    }
}