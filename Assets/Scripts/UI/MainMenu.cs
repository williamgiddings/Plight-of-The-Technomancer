using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MainMenu : MonoBehaviour
{
    public Button SinglePlayerButton;
    public Button CoopButton;

    private void Start()
    {
        Cursor.lockState = CursorLockMode.Confined;
        CoopButton.onClick.AddListener( () => GameManager.StartGame( GameModeType.Coop ) );
        SinglePlayerButton.onClick.AddListener( () => GameManager.StartGame( GameModeType.SinglePlayer ) );
    }
}
