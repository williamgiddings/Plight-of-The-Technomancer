using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class UnitFabricatingUIPlaceholderPreview : MonoBehaviour
{
    public TextMeshProUGUI UnitTypeText;
    public TextMeshProUGUI TimeRemainingText;
    public Image TimeRemainingProgressBar;

    private float MaxTime;
    private float TimeRemaining;
    private FabricatingUnitTimerObject FabricationTimer;

    public void Initialise( float InMaxTime, FabricatingUnitTimerObject InFabricationTimer )
    {
        MaxTime = InMaxTime;
        InFabricationTimer.onTimerIntervalUpdated += onFabricatingUnitTimeUpdated;
        UnitTypeText.SetText( InFabricationTimer.Unit.UnitName );
    }

    void onFabricatingUnitTimeUpdated( float NewTime )
    {
        TimeRemaining = NewTime;
        UpdateVisuals();
    }

    private void UpdateVisuals()
    {
        TimeRemainingText.SetText( string.Format("{0} seconds remaining", Mathf.CeilToInt(TimeRemaining) ) );
        TimeRemainingProgressBar.fillAmount = TimeRemaining / MaxTime;
    }

}
