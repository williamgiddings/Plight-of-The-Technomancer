using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;
using UnityEngine.XR.Interaction.Toolkit;

public class TeleportControl : MonoBehaviour
{
    public List<XRBaseController> Controllers = new List<XRBaseController>();
    public XRUtils.ButtonOption TeleportButton;

    private XRRayInteractor Iteractor;
    private string TeleportButtonString;

    private void Start()
    {
        Iteractor = GetComponent<XRRayInteractor>();
        TeleportButtonString = TeleportButton.ToString();
    }

    void Update()
    {
        if ( Iteractor )
        {
            InputFeatureUsage<bool> ButtonDown;
            bool ButtonState = false;

            foreach( XRController Device in Controllers ) 
            {
                if ( XRUtils.Buttons.TryGetValue( TeleportButtonString, out ButtonDown ) && Device.enableInputActions )
                {
                    if ( Device.inputDevice.TryGetFeatureValue( ButtonDown, out ButtonState ) )
                    {
                        if ( ButtonState )
                        {
                            Iteractor.enabled = true;
                            return;
                        }
                    }
                }
            }
            
            Iteractor.enabled = false;
        }
    }
}
