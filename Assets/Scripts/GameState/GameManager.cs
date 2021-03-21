using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public enum GameModeType
{
    SinglePlayer,
    Coop
}

public class GameManager : MonoBehaviour
{
    [SerializeField]
    private GameModeType CurrentGameMode;

    public Button SinglePlayerButton;
    public Button CoopButton;

    private void Awake()
    {
        DontDestroyOnLoad( this.gameObject );
        SceneManager.sceneLoaded += OnSceneLoad;
        CoopButton.onClick.AddListener( () => StartGame( GameModeType.Coop ) );
        SinglePlayerButton.onClick.AddListener( () => StartGame(GameModeType.SinglePlayer) );
    }

    private void UpdateGameModeToggles()
    {
        foreach ( GameModeToggleable Toggleable in FindObjectsOfType<GameModeToggleable>() )
        {
            Toggleable.gameObject.SetActive( Toggleable.GetGameModeToggle() == CurrentGameMode );
        }
    }

    public void StartGame( GameModeType Mode )
    {
        CurrentGameMode = Mode;
        SceneManager.LoadScene( 1 );
    }

    private void OnSceneLoad( Scene NewScene, LoadSceneMode Args )
    {
        UpdateGameModeToggles();
    }
}
