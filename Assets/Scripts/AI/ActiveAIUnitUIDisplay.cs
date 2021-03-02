using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class ActiveAIUnitUIDisplay : MonoBehaviour
{
    public TextMeshProUGUI UnitNickName;
    public Image UnitHealthbar;

    public void Bind( ref AIFriendlyUnit Unit )
    {
        Unit.GetDamageableComponent().OnNormalisedHealthChange += FriendlyUnitNormalisedHealthChange;
        UnitNickName.SetText( string.Format( "{0}", Unit.UnitNickName ) );
    }

    private void FriendlyUnitNormalisedHealthChange( float NewNormalisedHealth )
    {
        UnitHealthbar.fillAmount = NewNormalisedHealth;
    }
}
