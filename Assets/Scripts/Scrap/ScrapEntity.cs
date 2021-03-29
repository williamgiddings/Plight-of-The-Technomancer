using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScrapEntity : MonoBehaviour
{
    [SerializeField]
    private int ScrapValue;
    private ScrapService CachedScrapService;

    private void Start()
    {
        CachedScrapService = GameState.GetGameService<ScrapService>();
    }

    private void OnTriggerEnter( Collider other )
    {
        if ( other.gameObject.GetComponent<Player>() )
        {
            if ( CachedScrapService )
            {
                CachedScrapService.AddScrap( ScrapValue );
                Destroy( gameObject );
            }
        }
    }

    public void SetValue(int InValue)
    {
        ScrapValue = InValue;
    }
}
