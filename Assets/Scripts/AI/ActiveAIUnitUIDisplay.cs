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

    private Damageable CachedDamageableRef;

    public void Bind( ref AIFriendlyUnit Unit )
    {
        CachedDamageableRef = Unit.GetDamageableComponent();
        CachedDamageableRef.OnNormalisedHealthChange += FriendlyUnitNormalisedHealthChange;
        UnitNickName.SetText( string.Format( "{0}", Unit.UnitNickName ) );

        if ( StatOverview != null )
        {
            StatOverview.Reset();
            AIFriendlyUnitData Data = Unit.GetUnitData();
            if ( Data != null )
            {
                foreach ( StatTypes.Stat PositiveStat in Data.GetPositiveStats() )
                {
                    StatOverview.AddStat( PositiveStat );
                }
            }         
        }
    }

    private void FriendlyUnitNormalisedHealthChange( float NewNormalisedHealth )
    {
        UnitHealthbar.fillAmount = NewNormalisedHealth;
    }

    private void OnDestroy()
    {
        CachedDamageableRef.OnNormalisedHealthChange -= FriendlyUnitNormalisedHealthChange;
    }
}
