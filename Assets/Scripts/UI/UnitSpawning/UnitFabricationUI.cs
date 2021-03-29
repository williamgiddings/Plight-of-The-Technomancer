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
    public TextMeshProUGUI ScrapAmountText;

    private List<FabricatingUnitTimerObject> UnitsFabricating = new List<FabricatingUnitTimerObject>();
    private List<CraftableUnitDisplay> CraftableUnitDisplays = new List<CraftableUnitDisplay>();
    private Dictionary<FabricatingUnitTimerObject, TextMeshProUGUI> FabricationTextPlaceholders = new Dictionary<FabricatingUnitTimerObject, TextMeshProUGUI>();

    private AISpawnService SpawnService;
    private ScrapService ScrapServiceInstance;

    private void Start()
    {
        CraftableUnitDisplay.onCraftableUnitSelected += OnTryFabricatingUnit;
        FabricatingUnitTimerObject.onTimerCompleted += OnFabricationTimerComplete;
        ScrapService.OnScrapUpdated += OnScrapServiceScrapUpdated;

        SpawnService = GameState.GetGameService<AISpawnService>();
        ScrapServiceInstance = GameState.GetGameService<ScrapService>();

        OnScrapServiceScrapUpdated(ScrapServiceInstance.GetScrapCount());

        PopulateCraftableUnits();
    }

    private void OnScrapServiceScrapUpdated( int NewScrapAmount )
    {
        ScrapAmountText.SetText( string.Format( "x{0}", NewScrapAmount ) );
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

    void OnFabricationTimerComplete( FabricatingUnitTimerObject Timer )
    {
        UnitsFabricating.Remove( Timer );

        TextMeshProUGUI TextPlaceholder;

        if ( FabricationTextPlaceholders.TryGetValue( Timer, out TextPlaceholder ) )
        {
            Destroy( TextPlaceholder.gameObject );
        }
    }

    public void OnTryFabricatingUnit( CraftableUnit Unit )
    {
        if ( ScrapServiceInstance )
        {
            if ( ScrapServiceInstance.TryRemoveScrap( Unit.FabricationCost ) )
            {
                FabricatingUnitTimerObject Timer = new FabricatingUnitTimerObject( Unit.Data, Unit.FabricationTime );
                UnitsFabricating.Add( Timer );
                CreateNewFabricationTextPlaceholder( Timer );
            }
        }
    }

    private void CreateNewFabricationTextPlaceholder( FabricatingUnitTimerObject InTimer )
    {
        TextMeshProUGUI NewTextObject = Instantiate(FabricationTextTemplate, FabricationTextContainer.transform);
        NewTextObject.gameObject.SetActive( true );
        NewTextObject.SetText( InTimer.Unit.UnitName );
        FabricationTextPlaceholders.Add( InTimer, NewTextObject );
    }

    private void OnDestroy()
    {
        CraftableUnitDisplay.onCraftableUnitSelected -= OnTryFabricatingUnit;
        FabricatingUnitTimerObject.onTimerCompleted -= OnFabricationTimerComplete;
        ScrapService.OnScrapUpdated -= OnScrapServiceScrapUpdated;
    }
}
