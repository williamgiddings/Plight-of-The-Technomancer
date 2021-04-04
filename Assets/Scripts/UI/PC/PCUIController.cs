using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using DG.Tweening;

public class PCUIPopup : IDisposable
{
    private TextMeshProUGUI Popup;
    private Tweener FadeTweener;

    public PCUIPopup( TextMeshProUGUI Template, Transform Parent, float Lifetime )
    {
        Popup = GameObject.Instantiate( Template, Parent );
        Popup.gameObject.SetActive( true );
        FadeTweener = Popup.DOFade( 0, 3.0f ).SetDelay(Lifetime).OnComplete( Dispose );
    }

    public void SetText( string InText )
    {
        Popup.SetText( InText );
    }

    public void Dispose()
    {
        FadeTweener.Kill();
        FadeTweener.onComplete = null;
        if ( Popup )
        {
            GameObject.Destroy( Popup.gameObject );
        }
    }
}

public class PCUIController : MonoBehaviour
{
    public Camera UICamera;
    
    [Header("Waves")]
    public DynamicUIElement<TextMeshProUGUI> WaveText;
    public DynamicUIElement<TextMeshProUGUI> IntermissionText;
    public DynamicUIElement<TextMeshProUGUI> WavePopupText;

    [Header( "Scrap" )]
    public TextMeshProUGUI ScrapText;

    [Header( "Popups" )]
    public TextMeshProUGUI PopupTemplate;
    public LayoutGroup PopupContainer;
    public float Lifetime;

    private List<PCUIPopup> ActivePopups = new List<PCUIPopup>();

    void Start()
    {
        RegisterEvents();

        if ( GameState.TryGetGameService<ScrapService>( out ScrapService ScrapServiceInstance ) )
        {
            OnScrapUpdated( ScrapServiceInstance.GetScrapCount() );
        }
    }

    private void RegisterEvents()
    {
        ScrapService.OnScrapUpdated += OnScrapUpdated;
        ScrapService.OnScrapAdded += OnScrapAdded;
        AIFriendlyUnit.onFriendlyUnitSpawned += OnFriendlyUnitSpawned;
        AIFriendlyUnit.onFriendlyUnitDestroyed += OnFriendlyUnitDestroyed;
        GameManager.OnGameStartedEnding += OnGameOver;
        if ( GameState.TryGetGameService<AIWaveSpawnService>( out AIWaveSpawnService WaveService ) )
        {
            WaveService.OnWaveBegin += WaveServiceOnWaveBegin;
            WaveService.OnWaveEnd += WaveServiceOnWaveEnd;
            WaveService.OnIntermissionStart += WaveServiceOnIntermissionStart;
            WaveService.OnIntermissionUpdate += WaveServiceOnIntermissionUpdate;
        }
    }

    private void OnGameOver()
    {
        UICamera.enabled = false;
    }

    private void OnFriendlyUnitDestroyed( AIFriendlyUnit SpawnedUnit )
    {
        if ( SpawnedUnit.GetUnitData() != null )
        {
            CreatePopup( string.Format( "{0} unit has been destroyed", SpawnedUnit.GetUnitData().UnitName ) );
        }
    }

    private void OnFriendlyUnitSpawned( AIFriendlyUnit SpawnedUnit )
    {
        if ( SpawnedUnit.GetUnitData() != null )
        {
            CreatePopup( string.Format( "{0} unit has arrived", SpawnedUnit.GetUnitData().UnitName ) );
        }
    }

    private void UnRegisterEvents()
    {
        ScrapService.OnScrapUpdated -= OnScrapUpdated;
        ScrapService.OnScrapAdded -= OnScrapAdded;
        AIFriendlyUnit.onFriendlyUnitSpawned -= OnFriendlyUnitSpawned;
        AIFriendlyUnit.onFriendlyUnitDestroyed -= OnFriendlyUnitDestroyed;
        GameManager.OnGameStartedEnding -= OnGameOver;
        if ( GameState.TryGetGameService<AIWaveSpawnService>( out AIWaveSpawnService WaveService ) )
        {
            WaveService.OnWaveBegin -= WaveServiceOnWaveBegin;
            WaveService.OnWaveEnd -= WaveServiceOnWaveEnd;
            WaveService.OnIntermissionStart -= WaveServiceOnIntermissionStart;
            WaveService.OnIntermissionUpdate -= WaveServiceOnIntermissionUpdate;
        }
    }

    private void OnScrapAdded( int Amount )
    {
        CreatePopup( string.Format( "Picked up {0} scrap", Amount ) );
    }

    private void OnScrapUpdated( int ScrapAmount )
    {
        ScrapText.SetText( string.Format( "x{0}", ScrapAmount ) );
    }

    private void WaveServiceOnIntermissionStart( float Value )
    {
        IntermissionText.Show();
        WaveText.Hide();
    }

    private void WaveServiceOnIntermissionUpdate( float CurrentTime )
    {
        IntermissionText.Element.SetText(string.Format("Intermission: {0}", CurrentTime ) );
    }

    private void WaveServiceOnWaveEnd( AIWave OldWave )
    {
        WaveText.Hide();
        WavePopupText.Element.SetText( "Wave Survived!" );
        WavePopupText.TextFadeInOut();
    }

    private void WaveServiceOnWaveBegin( AIWave NewWave )
    {
        IntermissionText.Hide();
        
        WavePopupText.Element.SetText( "Enemy Units Incoming..." );
        WavePopupText.TextFadeInOut();

        WaveText.Element.SetText(string.Format("Wave #{0}", NewWave.ID+1 ));
        WaveText.Show();
        CreatePopup( string.Format( "Wave #{0} started", NewWave.ID + 1 ) );
    }

    private void OnDestroy()
    {
        UnRegisterEvents();
        WaveText.SafeDestroy();
        IntermissionText.SafeDestroy();
        WavePopupText.SafeDestroy();
    }

    private void CreatePopup( string Text )
    {
        PCUIPopup NewPopup = new PCUIPopup(PopupTemplate, PopupContainer.transform, 4.0f);
        NewPopup.SetText( Text );
        ActivePopups.Add( NewPopup );
    }
}
