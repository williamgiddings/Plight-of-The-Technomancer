using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameService : MonoBehaviour
{
    private GameService GameServiceInstance;

    private void Start()
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
