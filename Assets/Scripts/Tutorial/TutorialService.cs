using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TutorialService : GameService
{
    public static event DelegateUtils.VoidDelegateNoArgs onTutorialFinished;
    public int ActiveTutorials = 0;

    public void Complete()
    {
        if ( --ActiveTutorials == 0 )
        {
            FinishedTutorial();
        }
    }

    private void FinishedTutorial()
    {
        if ( onTutorialFinished != null ) onTutorialFinished();
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

    protected override void Begin()
    {
        base.Begin();
        ActiveTutorials = FindObjectsOfType<TutorialInterfacer>( false ).Length;
    }
}
