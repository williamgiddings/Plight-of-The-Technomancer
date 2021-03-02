using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public enum AIEnemyPartCategory
{
    Head,
    Back,
    Torso,
    Legs,
    Arms
}

public class AIEnemyPartConfiguration
{
    private Dictionary< AIEnemyPartCategory, AIEnemyColourDesc > PartColours;

    public override string ToString()
    {
        List<string> Values = new List<string>();

        foreach (var Pair in PartColours )
        {
            Values.Add( string.Format( "[{0} -> {1}]", Pair.Key.ToString(), Pair.Value.ColourName ) );
        }
        
        return System.String.Join( "", Values );
    }

    public AIEnemyPartConfiguration()
    {
        PartColours = new Dictionary<AIEnemyPartCategory, AIEnemyColourDesc>();
    }

    public void SetPart( AIEnemyPartCategory Part, AIEnemyColourDesc InColour )
    {
        PartColours.Add( Part, InColour );
    }

    public Optional<AIEnemyColourDesc> GetPartColour( AIEnemyPartCategory Part )
    {
        if ( PartColours.TryGetValue( Part, out AIEnemyColourDesc FoundColour ) )
        {
            return new Optional<AIEnemyColourDesc>( FoundColour );
        }
        return new Optional<AIEnemyColourDesc>();
    }

    public ref Dictionary<AIEnemyPartCategory, AIEnemyColourDesc> GetPartColours() => ref PartColours;

    public override bool Equals( object obj )
    {
        return this as AIEnemyPartConfiguration == obj as AIEnemyPartConfiguration;
    }

    public static bool operator==( AIEnemyPartConfiguration ThisConfig, AIEnemyPartConfiguration OtherConfig )
    {
        Dictionary < AIEnemyPartCategory, AIEnemyColourDesc > First = ThisConfig.GetPartColours();
        Dictionary < AIEnemyPartCategory, AIEnemyColourDesc > Second= OtherConfig.GetPartColours();

        if ( First.Count == Second.Count ) // Require equal count.
        {
            foreach ( var Pair in First )
            {
                if ( Second.TryGetValue( Pair.Key, out AIEnemyColourDesc Value ) )
                {
                    if ( Value != Pair.Value )
                    {
                        return false;
                    }
                }
                else
                {
                    return false;
                }
            }
            return true;
        }
        return false;
    }

    public static bool operator!=( AIEnemyPartConfiguration ThisConfig, AIEnemyPartConfiguration OtherConfig ) => !( ThisConfig == OtherConfig );

}

public class AIEnemyPartColourService : GameService
{
    public AIEnemyPartColourParams PartColourParams;
    
    private List<AIEnemyPartConfiguration> ReservedConfigurations = new List<AIEnemyPartConfiguration>();
    private Dictionary< AIEnemyUnitTypes, AIEnemyPartConfiguration > UnitTypePartConfigurations;

    public event DelegateUtils.VoidDelegateNoArgs onUnitPartConfigurationsInitialised;

    private void Start()
    {
        InitPartConfigurations();
    }

    private void InitPartConfigurations()
    {
        List<AIEnemyUnitTypes> UnitTypes = EnumUtils.EnumToList<AIEnemyUnitTypes>();
        UnitTypePartConfigurations = new Dictionary<AIEnemyUnitTypes, AIEnemyPartConfiguration>( UnitTypes.Count );
       
        foreach( AIEnemyUnitTypes Class in UnitTypes )
        {
            UnitTypePartConfigurations.Add( Class, GetNewColourConfiguration() );
        }
        onUnitPartConfigurationsInitialised();
    }

    public AIEnemyPartConfiguration GetNewColourConfiguration()
    {
        AIEnemyPartConfiguration NewColourConfiguration = CreateNewColourConfiguration();
        do
        {
            NewColourConfiguration = CreateNewColourConfiguration();
        }
        while ( ReservedConfigurations.Contains( NewColourConfiguration ) );

        ReservedConfigurations.Add( NewColourConfiguration );

        return NewColourConfiguration;
    }

    public AIEnemyPartConfiguration GetPartConfigurationForUnitType( AIEnemyUnitTypes UnitType )
    {
        return UnitTypePartConfigurations[UnitType];
    }

    private AIEnemyPartConfiguration CreateNewColourConfiguration()
    {
        AIEnemyPartConfiguration NewConfiguration = new AIEnemyPartConfiguration();

        int NumPartsToRecolour = PartColourParams.NumPartRecolours.Get( Random.Range( 0.0f, 1.0f ) );
        
        List< AIEnemyPartCategory > AvailableParts = new List< AIEnemyPartCategory >( EnumUtils.EnumToList<AIEnemyPartCategory>() );
        List< AIEnemyPartCategory > ChosenParts = new List<AIEnemyPartCategory>();

        for ( int i = 0; i < NumPartsToRecolour; i++ )
        {
            int RandomPartIndex = Mathf.FloorToInt( Random.Range(0.0f, 1.0f) * AvailableParts.Count );
            int RandomColourIndex = Mathf.FloorToInt( Random.Range(0.0f, 1.0f) * PartColourParams.AvailableColours.Length );
            
            AIEnemyPartCategory SelectedPart = AvailableParts[RandomPartIndex];
            ChosenParts.Add( SelectedPart );
            AvailableParts.RemoveAt( RandomPartIndex );

            AIEnemyColourDesc ChosenColour = PartColourParams.AvailableColours[RandomColourIndex];
            NewConfiguration.SetPart( SelectedPart, ChosenColour );
        }

        return NewConfiguration;
    }

    public string GetColourRTFSnippet( AIEnemyColourDesc Colour )
    {
        return string.Format( "<b><color=#{0}>{1}</color></b>", ColorUtility.ToHtmlStringRGB(Colour.Colour), Colour.ColourName );
    }
}
