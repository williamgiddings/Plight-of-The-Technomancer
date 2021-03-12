using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameState : MonoBehaviour
{
    private static GameState GameStateInstance;
    private GameService[] GameServices;

    public static event DelegateUtils.VoidDelegateNoArgs onGameStateFinishedInitialisation;

#if UNITY_EDITOR
    [ExecuteInEditMode]
    private void OnValidate()
    {
        GameStateInstance = this;
        LoadGameServices();
    }
#endif

    private void Start()
    {
        GameStateInstance = this;
        LoadGameServices();
        StartCoroutine( FinishInitialization ());
    }

    private void LoadGameServices()
    {
        GameServices = GetComponents<GameService>();

        foreach ( GameService Service in GameServices )
        {
            Service.InitialiseGameService();
        }
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

    public static bool TryGetGameService<Service>( out Service OutService ) where Service : GameService
    {
        OutService = null;
        if ( GameStateInstance )
        {
            foreach ( GameService ServiceInstance in GameStateInstance.GameServices )
            {
                Service CastedService = ServiceInstance.GetService() as Service;
                if ( CastedService )
                {
                    OutService = CastedService;
                    return true;
                }
            }
        }
        return false;
    }
}
