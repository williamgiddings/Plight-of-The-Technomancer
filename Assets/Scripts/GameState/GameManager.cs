using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using System;

public enum GameModeType
{
    SinglePlayer,
    Coop
}

public enum GameResult
{
    Fail,
    Success,
    Quit
}

public class GameManager : Singleton<GameManager>
{
    [SerializeField]
    private GameModeType CurrentGameMode;
    [SerializeField]
    private GameResult CurrentGameResult;

    public static event DelegateUtils.VoidDelegateNoArgs OnMissionSuccess;
    public static event DelegateUtils.VoidDelegateNoArgs OnMissionFail;
    public static event DelegateUtils.VoidDelegateNoArgs OnGameStartedEnding;

    private void Awake()
    {
        SceneManager.sceneLoaded += OnSceneLoad;
    }

    private void UpdateGameModeToggles()
    {
        foreach ( GameModeToggleable Toggleable in FindObjectsOfType<GameModeToggleable>() )
        {
            Toggleable.gameObject.SetActive( Toggleable.GetGameModeToggle() == CurrentGameMode );
        }
    }

    private void OnSceneLoad( Scene NewScene, LoadSceneMode Args )
    {
        UpdateGameModeToggles();
    }

    public static GameModeType GetCurrentGameMode()
    {
        return Instance.CurrentGameMode;
    }

    public static GameResult GetGameResult()
    {
        return Instance.CurrentGameResult;
    }

    public static void ReturnToMenu()
    {
        SceneManager.LoadScene( 0 );
    }

    public static void EndGame( GameResult Result )
    {
        if( OnGameStartedEnding != null ) OnGameStartedEnding();
        Instance.StartCoroutine( Instance.EndGameSequence( Result ) );
    }

    private IEnumerator EndGameSequence( GameResult Result )
    {     
        switch( Result )
        {
            case GameResult.Success:
                OnMissionSuccess();
                break;
            case GameResult.Fail:
                OnMissionFail();
                break;
            case GameResult.Quit:
                OnMissionFail();
                break;
        }
        yield return new WaitForSeconds( 9.0f ); // Wait for VO
        Instance.CurrentGameResult = Result;
        SceneManager.LoadScene( 2 );
    }

    public static void StartGame( GameModeType Mode )
    {
        Instance.CurrentGameMode = Mode;
        SceneManager.LoadScene( 1 );
    }

    private void OnDestroy()
    {
        SceneManager.sceneLoaded -= OnSceneLoad;
    }

}
