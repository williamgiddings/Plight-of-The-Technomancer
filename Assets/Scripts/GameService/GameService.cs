using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameService : MonoBehaviour
{
    protected GameService GameServiceInstance;

    protected virtual void Begin()
    {
    }

    protected virtual void OnDestroy()
    {
        GameState.onServicesLoaded -= Begin;
        GameServiceInstance = null;
    }

    public void InitialiseGameService()
    {
        if ( GameServiceInstance )
        {
            if ( GameServiceInstance != this )
            {
                Debug.LogError( string.Format( "{0} already created!", GameServiceInstance ) );
            }
        }
        GameServiceInstance = this;
        GameState.onServicesLoaded += Begin;
    }

    public GameService GetService()
    {
        return GameServiceInstance;
    }
}
