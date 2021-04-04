using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tutorial : MonoBehaviour
{
    public static event DelegateUtils.VoidDelegateNoArgs onTutorialFinished;

    public void FinishedTutorial()
    {
        if ( onTutorialFinished != null ) onTutorialFinished();
        gameObject.SetActive( false );
    }

#if UNITY_EDITOR
    private void Update()
    {
        if ( Input.GetKeyDown( KeyCode.F5 ) )
        {
            FinishedTutorial();
        }
    }
#endif
}
