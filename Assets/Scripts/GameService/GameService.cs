using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameService : MonoBehaviour
{
    private GameService GameServiceInstance;

    public virtual void InitialiseGameService()
    {
        if ( GameServiceInstance )
        {
            if ( GameServiceInstance != this )
            {
                Debug.LogError( string.Format( "{0} already created!", GameServiceInstance ) );
            }
        }
        GameServiceInstance = this;
    }

    public GameService GetService()
    {
        return GameServiceInstance;
    }
}
