using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameModeToggleable : MonoBehaviour
{
    [SerializeField]
    private GameModeType GameModeToggle;

    public GameModeType GetGameModeToggle()
    {
        return GameModeToggle;
    }
}
