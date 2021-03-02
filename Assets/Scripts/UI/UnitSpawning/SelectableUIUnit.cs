using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

[System.Serializable]
public class StatGroup
{
    public StatTypes.Stat Binding;
    public Image ProgressBar;

    private float Value;

    public void SetValue( float NewValue )
    {
        Value = NewValue;
        UpdateProgressBar();
    }

    private void UpdateProgressBar()
    {
        if ( ProgressBar )
        {
            ProgressBar.fillAmount = Value;
        }
    }
}

public class SelectableUIUnit : MonoBehaviour
{
    [Header("Stat Containers")]
    public StatGroup[] StatContainers;
    public TextMeshProUGUI UnitName;

    protected AIFriendlyUnitData UnitData;
    
    public virtual void SetData( AIFriendlyUnitData InUnitData )
    {
        UnitData = InUnitData;
        UpdateStatDisplays();
    }

    public virtual void UpdateStatDisplays()
    {
        foreach ( StatGroup Stat in StatContainers )
        {
            float RawStatValue = UnitData.GetStatBinding( Stat.Binding );
            Stat.SetValue( GetNormalizedStatValue( RawStatValue ) );
        }
        UnitName.SetText(UnitData.UnitName);
    }

    protected float GetNormalizedStatValue( float RawValue )
    {
        AIGlobalParams GlobalAIParams = GameState.GetGameService<AISpawnService>()?.GlobalParams;

        if ( GlobalAIParams )
        {
            float Min = GlobalAIParams.MinStatScaler;
            float Max = GlobalAIParams.MaxStatScaler;

            return ( RawValue - Min ) / ( Max - Min );
        }

        return 0.0f;
    }

    public virtual void Select()
    {
    }
}
