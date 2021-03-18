using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class UnitFabricationUI : MonoBehaviour
{
    [Header("UI Elements")]
    public GridLayoutGroup CraftableUnitGridLayout;
    public CraftableUnitDisplay CraftableUnitUITemplate;
    public VerticalLayoutGroup FabricationTextContainer;
    public TextMeshProUGUI FabricationTextTemplate;

    private List<FabricatingUnitTimerObject> UnitsFabricating = new List<FabricatingUnitTimerObject>();
    private List<CraftableUnitDisplay> CraftableUnitDisplays = new List<CraftableUnitDisplay>();
    private Dictionary<FabricatingUnitTimerObject, TextMeshProUGUI> FabricationTextPlaceholders = new Dictionary<FabricatingUnitTimerObject, TextMeshProUGUI>();

    private AISpawnService SpawnService;

    private void Start()
    {
        CraftableUnitDisplay.onCraftableUnitSelected += onTryFabricatingUnit;
        FabricatingUnitTimerObject.onTimerCompleted += onFabricationTimerComplete;

        SpawnService = GameState.GetGameService<AISpawnService>();
        PopulateCraftableUnits();
    }

    private void Update()
    {
        for (int TimerIndex = 0; TimerIndex < UnitsFabricating.Count; TimerIndex++ )
        {
            UnitsFabricating[TimerIndex].TickTimer( Time.deltaTime );
        }
    }

    private void PopulateCraftableUnits()
    {
        ref CraftableUnit[] CraftableUnitsRef = ref SpawnService.GetCraftableUnits();
        ResetCraftableUnitDisplays( CraftableUnitsRef.Length );

        foreach( CraftableUnit Unit in CraftableUnitsRef )
        {
            CraftableUnitDisplay NewUnitDisplay = Instantiate( CraftableUnitUITemplate, CraftableUnitGridLayout.transform );
            NewUnitDisplay.SetFabricationData( Unit );
            NewUnitDisplay.gameObject.SetActive( true );
        }

    }

    private void ResetCraftableUnitDisplays( int NewSize )
    {
        CraftableUnitDisplays.ForEach( x => GameObject.Destroy( x.gameObject ) );
        CraftableUnitDisplays = new List<CraftableUnitDisplay>( NewSize );
    }

    void onFabricationTimerComplete( FabricatingUnitTimerObject Timer )
    {
        UnitsFabricating.Remove( Timer );

        TextMeshProUGUI TextPlaceholder;

        if ( FabricationTextPlaceholders.TryGetValue( Timer, out TextPlaceholder ) )
        {
            Destroy( TextPlaceholder.gameObject );
        }
    }

    public void onTryFabricatingUnit( CraftableUnit Unit )
    {
        // if ( Unit.FabricationCost <= SCRAP )
        FabricatingUnitTimerObject Timer = new FabricatingUnitTimerObject( Unit.Data, Unit.FabricationTime );
        UnitsFabricating.Add( Timer );
        CreateNewFabricationTextPlaceholder( Timer );
    }

    private void CreateNewFabricationTextPlaceholder( FabricatingUnitTimerObject InTimer )
    {
        TextMeshProUGUI NewTextObject = Instantiate(FabricationTextTemplate, FabricationTextContainer.transform);
        NewTextObject.gameObject.SetActive( true );
        NewTextObject.SetText( InTimer.Unit.UnitName );
        FabricationTextPlaceholders.Add( InTimer, NewTextObject );
    }
}
