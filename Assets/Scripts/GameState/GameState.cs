using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameState : MonoBehaviour
{
    private static GameState Instance;
    private GameService[] GameServices;
    [SerializeField]
    private GameModeDifficultyScalarBinding[] GameModeDifficulties;

    public static event DelegateUtils.VoidDelegateNoArgs onServicesLoaded;
    public static event DelegateUtils.VoidDelegateNoArgs onGameStateFinishedInitialisation;

    [System.Serializable]
    private struct GameModeDifficultyScalarBinding
    {
        public GameModeType Mode;
        public float DifficultyScalar;
    }

    private void OnValidate()
    {
        if ( !Instance )
        {
            Instance = this;
        }
    }

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

    public static float GetDifficulty()
    {
        foreach ( GameModeDifficultyScalarBinding Binding in Instance.GameModeDifficulties )
        {
            if ( Binding.Mode == GameManager.GetCurrentGameMode() )
            {
                return Binding.DifficultyScalar;
            }
        }
        return 1.0f;
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

    [ExecuteInEditMode]
    public static bool TryGetGameServiceEditor<Service>( out Service OutService ) where Service : GameService
    {
        OutService = null;
        #if UNITY_EDITOR
        if ( Instance )
        {
            foreach( GameService LocalService in Instance.GetComponentsInChildren<GameService>() )
            {
                Service LocalServiceAsService = LocalService as Service;
                if ( LocalServiceAsService )
                {
                    OutService = LocalServiceAsService;
                    return true;
                }
            }
        }
        #endif
        return false;
    }

}
