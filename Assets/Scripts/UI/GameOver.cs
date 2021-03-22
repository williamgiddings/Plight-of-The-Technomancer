using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameOver : MonoBehaviour
{
    public Button RetryButton;
    public Button MenuButton;

    [SerializeField]
    private GameOverResultOutcome[] OutComes;

    [System.Serializable]
    private struct GameOverResultOutcome
    {
        public GameResult Result;
        public GameObject UIGroup;
    }

    private void Start()
    {
        Cursor.lockState = CursorLockMode.Confined;
        RetryButton.onClick.AddListener( () => GameManager.StartGame( GameManager.GetCurrentGameMode() ) );
        MenuButton.onClick.AddListener( () =>  GameManager.ReturnToMenu() );
        UpdateOutcome( OutcomeType: GameManager.GetGameResult() );
    }

    private void UpdateOutcome( GameResult OutcomeType )
    {
        foreach( GameOverResultOutcome Outcome in OutComes )
        {
            Outcome.UIGroup.SetActive( OutcomeType == Outcome.Result );
        }
    }
}

