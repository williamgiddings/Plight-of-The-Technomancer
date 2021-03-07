using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class ActiveAIUnitUIDisplay : MonoBehaviour
{
    public TextMeshProUGUI UnitNickName;
    public Image UnitHealthbar;

    public StatOverviewContainer StatOverview;

    public void Bind( ref AIFriendlyUnit Unit )
    {
        Unit.GetDamageableComponent().OnNormalisedHealthChange += FriendlyUnitNormalisedHealthChange;
        UnitNickName.SetText( string.Format( "{0}", Unit.UnitNickName ) );

        if ( StatOverview != null )
        {
            StatOverview.Reset();
            foreach ( StatTypes.Stat PositiveStat in Unit.GetUnitData().GetPositiveStats() )
            {
                StatOverview.AddStat( PositiveStat );
            }
        }
    }

    private void FriendlyUnitNormalisedHealthChange( float NewNormalisedHealth )
    {
        UnitHealthbar.fillAmount = NewNormalisedHealth;
    }
}
