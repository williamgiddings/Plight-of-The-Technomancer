using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[System.Serializable]
public class StatOverviewContainer
{
    public Transform Container;
    public Image StatIconTemplate;

    private AISpawnService CachedSpawnService;
    private List<Image> Icons = new List<Image>();

    public void AddStat( StatTypes.Stat NewStat )
    {
        if ( !CachedSpawnService )
        {
            CachedSpawnService = GameState.GetGameService<AISpawnService>();
        }
        
        Sprite NewIcon = CachedSpawnService.GlobalParams.StatIcons.GetStatIcon( NewStat );

        if ( NewIcon )
        {
            Image NewStatIcon = Image.Instantiate( StatIconTemplate, Container );
            NewStatIcon.gameObject.SetActive( true );
            Icons.Add( NewStatIcon );
            NewStatIcon.sprite = NewIcon;
        }
    }

    public void Reset()
    {
        foreach( Image Icon in Icons )
        {
            GameObject.Destroy( Icon.gameObject );
        }
        Icons.Clear();
    }

}
