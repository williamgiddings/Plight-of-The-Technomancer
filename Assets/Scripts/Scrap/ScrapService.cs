using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScrapService : GameService
{
    public static event DelegateUtils.VoidDelegateGenericArg<int> OnScrapAdded;
    public static event DelegateUtils.VoidDelegateGenericArg<int> OnScrapRemoved;
    public static event DelegateUtils.VoidDelegateGenericArg<int> OnScrapUpdated;

    [SerializeField]
    private GameObject ScrapPickupObject;

    [SerializeField]
    private int CurrentScrapAmount;

    private AISurfaceProjectionService SurfaceProjectionService;

    protected override void Begin()
    {
        base.Begin();
        SurfaceProjectionService = GameState.GetGameService<AISurfaceProjectionService>();
    }

    public int GetScrapCount()
    {
        return CurrentScrapAmount;
    }

    public bool CanAfford( int ScrapCost )
    {
        return ( CurrentScrapAmount - ScrapCost ) >= 0;
    }

    public void AddScrap( int ScrapValue )
    {
        CurrentScrapAmount += ScrapValue; 
        if( OnScrapAdded != null ) OnScrapAdded( ScrapValue );
        if ( OnScrapUpdated != null ) OnScrapUpdated( CurrentScrapAmount );
    }

    public bool TryRemoveScrap( int ScrapAmount )
    {
        if ( CanAfford( ScrapAmount ) )
        {
            CurrentScrapAmount -= ScrapAmount;
            if ( OnScrapRemoved != null ) OnScrapRemoved( ScrapAmount );
            if ( OnScrapUpdated != null ) OnScrapUpdated( CurrentScrapAmount );
            return true;
        }
        return false;
    }

    public void CreateScrapPickup( Vector3 Position, int Value )
    {
        Vector3 SpawnPos = SurfaceProjectionService.GetProjectedPosition( Position, 2.0f, out Vector3 HitNormal );
        ScrapEntity SpawnedScrap = Instantiate( ScrapPickupObject, SpawnPos, Quaternion.identity ).GetComponent<ScrapEntity>();
        SpawnedScrap.SetValue( Value );
    }
}
