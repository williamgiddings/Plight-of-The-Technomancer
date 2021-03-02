using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


[System.Serializable]
public class AIFriendlyUnitSelectedPreview
{
    public SpawnableUnitDisplay Template;
    public RectTransform HiddenTemplate;

    public void SetActive( bool InState )
    {
        Template.gameObject.SetActive( InState );
        HiddenTemplate.gameObject.SetActive( !InState );
    }
}

public class AIUnitSpawnSelectionUI : MonoBehaviour
{
    public SpawnRadar SpawnRadarSystem;

    [Header("Unit Content")]
    public RectTransform UnitOptionContent;
    public SpawnableUnitDisplay UnitOptionTemplate;
    public RectTransform NoUnitsPlaceholder;

    [Header("Unit Fabrication")]
    public UnitFabricatingUIPlaceholderPreview FabricationPlaceholder;

    [Header("UnitPreview")]
    public AIFriendlyUnitSelectedPreview SelectedUnitPreview;

    [Header("Selection")]
    public Button SpawnButton;

    private Dictionary<AIFriendlyUnitData, SpawnableUnitDisplay> SpawnableUnitDisplays;
    private Dictionary<FabricatingUnitTimerObject, UnitFabricatingUIPlaceholderPreview> UnitsInFabrication;
    private AIFriendlyUnitSpawnRequest UnitSpawnRequest = new AIFriendlyUnitSpawnRequest();
    private AISpawnService SpawnService;

    private void Start()
    {
        SpawnableUnitDisplays = new Dictionary<AIFriendlyUnitData, SpawnableUnitDisplay>();
        UnitsInFabrication = new Dictionary<FabricatingUnitTimerObject, UnitFabricatingUIPlaceholderPreview>();
        RegisterEvents();
        UpdateEmptyPlaceholder();
    }

    private void UpdateEmptyPlaceholder()
    {
        NoUnitsPlaceholder.gameObject.SetActive( (SpawnableUnitDisplays.Count + UnitsInFabrication.Count) == 0 );
    }

    private void RegisterEvents()
    {
        SpawnService = GameState.GetGameService<AISpawnService>();
        if ( SpawnService )
        {
            SpawnService.onNewFriendlyUnitAvailible += AddSpawnableUnit;
            SpawnService.onFriendlyUnitNotAvailible += RemoveSpawnableUnit;
        }
        SpawnableUnitDisplay.onSpawnableUnitSelected += NewUnitSelected;
        SpawnRadar.onSpawnCoordSelected += NewSpawnCoordSelected;

        FabricatingUnitTimerObject.onTimerCompleted += onUnitFinishedFabricating;
        FabricatingUnitTimerObject.onTimerStarted += onUnitStartedFabricating;
    }

    public void onUnitStartedFabricating( FabricatingUnitTimerObject FabricatingTimer )
    {
        UnitFabricatingUIPlaceholderPreview NewFabricationPlaceholder = Instantiate( FabricationPlaceholder, UnitOptionContent );
        NewFabricationPlaceholder.Initialise( FabricatingTimer.TimerLength, FabricatingTimer );
        NewFabricationPlaceholder.gameObject.SetActive( true );
        UnitsInFabrication.Add( FabricatingTimer, NewFabricationPlaceholder );
        UpdateEmptyPlaceholder();
    }

    void onUnitFinishedFabricating( FabricatingUnitTimerObject TimedObject )
    {
        UnitFabricatingUIPlaceholderPreview UIPlaceholder;

        if ( UnitsInFabrication.TryGetValue( TimedObject, out UIPlaceholder ) )
        {
            UnitsInFabrication.Remove( TimedObject );
            GameObject.Destroy( UIPlaceholder.gameObject );
        }
    }

    public void NewUnitSelected( AIFriendlyUnitData NewUnit )
    {
        UnitSpawnRequest.SelectedUnitOptional = NewUnit;
        RefreshSelectionUI();
    }

    public void NewSpawnCoordSelected( Optional<Vector2> NewCoord )
    {
        UnitSpawnRequest.SelectedUnitPositionOptional = NewCoord;
        RefreshSelectionUI();
    }

    public void SpawnSelectedUnit()
    {
        if ( UnitSpawnRequest )
        {
            if ( SpawnService.TrySpawnFriendlyUnit( UnitSpawnRequest.SelectedUnitOptional.Get(), UnitSpawnRequest.SelectedUnitPositionOptional.Get() ) )
            {
                NewUnitSelected( null );
                NewSpawnCoordSelected( null );
            }
        }
    }

    public void AddSpawnableUnit( AIFriendlyUnitData InUnit )
    {
        SpawnableUnitDisplay ExistingUnitDisplay;

        if ( SpawnableUnitDisplays.TryGetValue( InUnit, out ExistingUnitDisplay ) )
        {
            ExistingUnitDisplay.UpdateQuantity(1);
        }
        else
        {
            SpawnableUnitDisplay NewUnitDisplay = CreateUnitDisplay();
            NewUnitDisplay.gameObject.SetActive( true );
            NewUnitDisplay.SetData( InUnit );
            NewUnitDisplay.UpdateStatDisplays();
            SpawnableUnitDisplays.Add( InUnit, NewUnitDisplay );
            UpdateEmptyPlaceholder();
        }
    }

    public void RemoveSpawnableUnit( AIFriendlyUnitData InUnit )
    {
        SpawnableUnitDisplay ExistingUnitDisplay;
        
        if ( SpawnableUnitDisplays.TryGetValue( InUnit, out ExistingUnitDisplay ) )
        {
            int NewQuantity = ExistingUnitDisplay.UpdateQuantity( -1 );

            if ( NewQuantity <= 0 )
            {
                Destroy( ExistingUnitDisplay.gameObject );
                SpawnableUnitDisplays.Remove( InUnit );
                UpdateEmptyPlaceholder();
            }

        }
    }

    private SpawnableUnitDisplay CreateUnitDisplay()
    {
        return Instantiate<SpawnableUnitDisplay>( UnitOptionTemplate, UnitOptionContent );
    }

    private void RefreshSelectionUI()
    {
        bool UnitSelected = UnitSpawnRequest.SelectedUnitOptional;
        if ( UnitSelected )
        {
            SelectedUnitPreview.Template.SetData( UnitSpawnRequest.SelectedUnitOptional.Get() );
            SelectedUnitPreview.Template.UpdateStatDisplays();
        }
        SpawnButton.interactable = UnitSpawnRequest;
        SelectedUnitPreview.SetActive( UnitSelected );

    }

}
