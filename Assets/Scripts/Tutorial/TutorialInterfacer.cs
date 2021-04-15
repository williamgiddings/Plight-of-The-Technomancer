using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TutorialInterfacer : MonoBehaviour
{
    public void Complete()
    {
        if ( GameState.TryGetGameService<TutorialService>( out TutorialService Tutorial ) )
        {
            Tutorial.Complete();
        }
        gameObject.SetActive( false );
    }
}
