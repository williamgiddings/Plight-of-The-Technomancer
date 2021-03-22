using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

//TODO: Add ability to have multiple units with same name followed by roman numerals

public class AINamingService : GameService
{
    public TextAsset AINamesAsset;
    
    List<string> AINames = new List<string>();
    List<string> RegisteredNames = new List<string>();

    protected override void Begin()
    {
        AINames.AddRange( AINamesAsset.text.Split( '\n' ) );
        AIFriendlyUnit.onFriendlyUnitDestroyed += NamedUnitDestroyed;
    }

    public string GetName()
    {
        string Name = AINames[Random.Range( 0, AINames.Count - 1 )];
        ReserveName( Name );
        return Name;
    }

    private void ReserveName( string Name )
    {
        RegisteredNames.Add( Name );
        AINames.Remove( Name );
    }

    private void UnreserveName( string Name )
    {
        RegisteredNames.Remove( Name );
        AINames.Add( Name );
    }

    private void NamedUnitDestroyed( AIFriendlyUnit Unit )
    {
        UnreserveName( Unit.UnitNickName );
    }

    protected override void OnDestroy()
    {
        base.OnDestroy();
        AIFriendlyUnit.onFriendlyUnitDestroyed -= NamedUnitDestroyed;
    }
}
