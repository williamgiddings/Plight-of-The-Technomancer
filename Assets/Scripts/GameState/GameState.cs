using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameState : MonoBehaviour
{
    private static GameState Instance;
    private GameService[] GameServices;

    public static event DelegateUtils.VoidDelegateNoArgs onServicesLoaded;
    public static event DelegateUtils.VoidDelegateNoArgs onGameStateFinishedInitialisation;

    private void Start()
    {
        if ( !Instance )
        {
            Instance = this;
        }
        LoadGameServices();
        StartCoroutine( FinishInitialization() );
    }

    private void OnDestroy()
    {
        Instance = null;
    }

    private void LoadGameServices()
    {
        GameServices = GetComponents<GameService>();

        foreach ( GameService Service in GameServices )
        {
            Service.InitialiseGameService();
        }
        onServicesLoaded();
    }

    private IEnumerator FinishInitialization()
    {
        yield return new WaitForEndOfFrame();
        onGameStateFinishedInitialisation();
    }

    public static Service GetGameService<Service>() where Service : GameService
    {
        if ( Instance )
        {
            foreach ( GameService ServiceInstance in Instance.GameServices )
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
        if ( Instance )
        {
            foreach ( GameService ServiceInstance in Instance.GameServices )
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
