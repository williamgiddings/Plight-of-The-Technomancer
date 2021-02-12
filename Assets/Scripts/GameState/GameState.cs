using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameState : MonoBehaviour
{
    private static GameState GameStateInstance;
    private GameService[] GameServices;

    private void Start()
    {
        GameStateInstance = this;
        GameServices = GetComponents<GameService>();
    }

    public static Service GetGameService<Service>() where Service : GameService
    {
        if ( GameStateInstance )
        {
            foreach ( GameService ServiceInstance in GameStateInstance.GameServices )
            {
                Service CastedService = ServiceInstance.GetService() as Service;
                if ( CastedService )
                {
                    return CastedService;
                }
            }
        }
        return null;
    }

}
