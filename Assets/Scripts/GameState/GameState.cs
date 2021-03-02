using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameState : MonoBehaviour
{
    private static GameState GameStateInstance;
    private GameService[] GameServices;

    public static event DelegateUtils.VoidDelegateNoArgs onGameStateFinishedInitialisation;

    private void Start()
    {
        GameStateInstance = this;
        GameServices = GetComponents<GameService>();
        
        foreach ( GameService Service in GameServices )
        {
            Service.InitialiseGameService();
        }
        StartCoroutine( FinishInitialization ());
    }
    private IEnumerator FinishInitialization()
    {
        yield return new WaitForEndOfFrame();
        onGameStateFinishedInitialisation();
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
