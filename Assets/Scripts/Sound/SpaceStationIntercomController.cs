using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpaceStationIntercomController : MonoBehaviour
{
    [SerializeField]
    private SpaceStationIntercomAudioClips AudioClips;
    private AudioSource AudioComponent;
    private AIWaveSpawnService WaveSpawnService;

    [System.Serializable]
    private struct SpaceStationIntercomAudioClips
    {
        public AudioClip WaveIncomingClip;
        public AudioClip WaveCompleteClip;
        public AudioClip FriendlyUnitDestroyedClip;
        public AudioClip SuccessClip;
        public AudioClip FailClip;
        public AudioClip IntroClip;
        public AudioClip BioDomeCritical;
        public AudioClip ScrapReceived;
        public AudioClip TimerBeep;
    }
    
    private void Start()
    {
        AudioComponent = GetComponent<AudioSource>();
        WaveSpawnService = GameState.GetGameService<AIWaveSpawnService>();

        if ( AudioComponent )
        {
            RegisterAudioEvents();
        }
    }

    private void RegisterAudioEvents()
    {
        GameState.onGameStateFinishedInitialisation += PlayIntroClip;
        AIFriendlyUnit.onFriendlyUnitDestroyed += PlayFriendlyUnitDestroyedClip;
        GameManager.OnMissionSuccess += PlayMissionSuccessClip;
        GameManager.OnMissionFail += PlayMissionFailClip;
        Biodome.OnHealthLow += PlayBioDomeCriticalClip;
        ScrapService.OnScrapAdded += PlayScrapAddedClip;
        if ( WaveSpawnService )
        {
            WaveSpawnService.OnWaveBegin += PlayWaveBeginClip;
            WaveSpawnService.OnWaveEnd += PlayWaveEndClip;
            WaveSpawnService.OnIntermissionUpdate += PlayTimerBeepClip;
        }
    }

    private void UnRegisterAudioEvents()
    {
        GameState.onGameStateFinishedInitialisation -= PlayIntroClip;
        AIFriendlyUnit.onFriendlyUnitDestroyed -= PlayFriendlyUnitDestroyedClip;
        GameManager.OnMissionSuccess -= PlayMissionSuccessClip;
        GameManager.OnMissionFail -= PlayMissionFailClip;
        ScrapService.OnScrapAdded -= PlayScrapAddedClip;
        if ( WaveSpawnService )
        {
            WaveSpawnService.OnWaveBegin -= PlayWaveBeginClip;
            WaveSpawnService.OnWaveEnd -= PlayWaveEndClip;
            WaveSpawnService.OnIntermissionUpdate -= PlayTimerBeepClip;
        }
    }


    private void PlayTimerBeepClip( float Payload )
    {
        AudioComponent.PlayOneShot( AudioClips.TimerBeep );
    }

    private void PlayBioDomeCriticalClip()
    {
        AudioComponent.PlayOneShot( AudioClips.BioDomeCritical );
        Biodome.OnHealthLow -= PlayBioDomeCriticalClip;
    }

    private void PlayScrapAddedClip( int Payload )
    {
        if ( !AudioComponent.isPlaying )
        {
            AudioComponent.PlayOneShot( AudioClips.ScrapReceived );
        }
    }

    private void PlayMissionFailClip()
    {
        AudioComponent.PlayOneShot( AudioClips.FailClip );
    }

    private void PlayMissionSuccessClip()
    {
        AudioComponent.PlayOneShot( AudioClips.SuccessClip );
    }

    private void PlayFriendlyUnitDestroyedClip( AIFriendlyUnit SpawnedUnit )
    {
        AudioComponent.PlayOneShot( AudioClips.FriendlyUnitDestroyedClip );
    }

    private void PlayWaveEndClip( AIWave UnneededWavePayload )
    {
        AudioComponent.PlayOneShot( AudioClips.WaveCompleteClip );
    }

    private void PlayWaveBeginClip( AIWave UnneededWavePayload )
    {
        AudioComponent.PlayOneShot( AudioClips.WaveIncomingClip );
    }

    private void PlayIntroClip()
    {
        AudioComponent.PlayOneShot( AudioClips.IntroClip );
    }

    private void OnDestroy()
    {
        if ( AudioComponent )
        {
            UnRegisterAudioEvents();
        }
    }
}
