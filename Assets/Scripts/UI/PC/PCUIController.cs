using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class PCUIController : MonoBehaviour
{
    [Header("Waves")]
    public DynamicUIElement<TextMeshProUGUI> WaveText;
    public DynamicUIElement<TextMeshProUGUI> IntermissionText;
    public DynamicUIElement<TextMeshProUGUI> WavePopupText;

    void Start()
    {
        if (GameState.TryGetGameService<AIWaveSpawnService>( out AIWaveSpawnService WaveService ) )
        {
            WaveService.OnWaveBegin += WaveServiceOnWaveBegin;
            WaveService.OnWaveEnd += WaveServiceOnWaveEnd;
            WaveService.OnIntermissionStart += WaveServiceOnIntermissionStart;
            WaveService.OnIntermissionUpdate += WaveServiceOnIntermissionUpdate;
        }
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
    }

    private void OnDestroy()
    {
        if ( GameState.TryGetGameService<AIWaveSpawnService>( out AIWaveSpawnService WaveService ) )
        {
            WaveService.OnWaveBegin -= WaveServiceOnWaveBegin;
            WaveService.OnWaveEnd -= WaveServiceOnWaveEnd;
            WaveService.OnIntermissionStart -= WaveServiceOnIntermissionStart;
            WaveService.OnIntermissionUpdate -= WaveServiceOnIntermissionUpdate;
        }

        WaveText.SafeDestroy();
        IntermissionText.SafeDestroy();
        WavePopupText.SafeDestroy();
    }
}
