using System.Collections;
using System.Collections.Generic;
using UnityEngine.XR;

public static class XRUtils
{
    public static readonly Dictionary<string, InputFeatureUsage<bool>> Buttons = new Dictionary<string, InputFeatureUsage<bool>>
        {
            {"triggerButton", CommonUsages.triggerButton },
            {"primary2DAxisClick", CommonUsages.primary2DAxisClick },
            {"primary2DAxisTouch", CommonUsages.primary2DAxisTouch },
            {"menuButton", CommonUsages.menuButton },
            {"gripButton", CommonUsages.gripButton },
            {"secondaryButton", CommonUsages.secondaryButton },
            {"secondaryTouch", CommonUsages.secondaryTouch },
            {"primaryButton", CommonUsages.primaryButton },
            {"primaryTouch", CommonUsages.primaryTouch }
        };

    public enum ButtonOption
    {
        triggerButton,
        primary2DAxisClick,
        primary2DAxisTouch,
        menuButton,
        gripButton,
        secondaryButton,
        secondaryTouch,
        primaryButton,
        primaryTouch
    };

    public static InputDevice GetCurrentDevice( XRNode Node )
    {
        InputDevice Device = new InputDevice();
        var Devices = new List<UnityEngine.XR.InputDevice>();
        InputDevices.GetDevicesAtXRNode( Node, Devices );
        if ( Devices.Count == 1 )
        {
            Device = Devices[0];
        }
        else if ( Devices.Count > 1 )
        {
            Device = Devices[0];
        }

        return Device;
    }
}
