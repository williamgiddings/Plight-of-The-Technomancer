using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class CraftableUnitDisplay : SelectableUIUnit
{
    [Header("Extra UI Options")]
    public TextMeshProUGUI FabricationCostGUI;
    public TextMeshProUGUI FabricationTimeGUI;
    public GameObject AvailabilityBlocker;

    public static event AIDelegates.FriendlyCraftableUnitDataDelegate onCraftableUnitSelected;

    private CraftableUnit FabricationData;

    private void Start()
    {
        if ( GameState.TryGetGameService<ScrapService>( out ScrapService ScrapServiceInstance ) )
        {
            OnScrapServiceScrapUpdated( ScrapServiceInstance.GetScrapCount() );
        }
        ScrapService.OnScrapUpdated += OnScrapServiceScrapUpdated;
    }

    private void OnScrapServiceScrapUpdated( int ScrapAmount )
    {
        AvailabilityBlocker.SetActive( ScrapAmount < FabricationData.FabricationCost );
    }

    public void SetFabricationData( CraftableUnit InFabricationData )
    {
        FabricationData = InFabricationData;
        base.SetData( FabricationData.Data );
    }

    public override void SetData( AIFriendlyUnitData InUnitData )
    {
        Debug.LogError( "Do not call SetData on CraftableUnitDisplay, use SetFabricationData otherwise you might as well just use a SelectableUIUnit." );
    }

    public override void Select()
    {
        onCraftableUnitSelected( FabricationData );
    }

    public override void UpdateStatDisplays()
    {
        base.UpdateStatDisplays();

        FabricationCostGUI.SetText( string.Format( "x{0}", FabricationData.FabricationCost.ToString() ) );
        FabricationTimeGUI.SetText( string.Format( "{0} secs.", FabricationData.FabricationTime.ToString() ) );

    }

    private void OnDestroy()
    {
        ScrapService.OnScrapUpdated -= OnScrapServiceScrapUpdated;
    }
}
