using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using System.Text;

[System.Serializable]
public struct EnemyClassificationTextDescription
{
    public AIEnemyUnitTypes UnitType;
    public TextMeshProUGUI DescriptionTextObject;

    [TextArea()]
    public string FlavourText;
}

public class EnemyClassificationUI : MonoBehaviour
{
    public EnemyClassificationTextDescription[] UnitDescriptions;

    private AIEnemyPartColourService PartColourService;
    
    private void Start()
    {
        PartColourService = GameState.GetGameService<AIEnemyPartColourService>();
        
        if ( PartColourService )
        {
            PartColourService.onUnitPartConfigurationsInitialised += UpdateTextDescriptions;
        }
    }

    private void UpdateTextDescriptions()
    {
        foreach( EnemyClassificationTextDescription Desc in UnitDescriptions )
        {
            UpdateTextDescription( Desc );
        }
    }

    private void UpdateTextDescription( EnemyClassificationTextDescription ClassificationDescription )
    {
        AIEnemyPartConfiguration Config = PartColourService.GetPartConfigurationForUnitType( ClassificationDescription.UnitType );

        var PartColours = Config.GetPartColours();

        List<string> PartColourTexts = new List<string>();

        foreach( var PartPair in PartColours )
        {
            string FormattedColour = PartColourService.GetColourRTFSnippet(PartPair.Value);
            PartColourTexts.Add( string.Format( "{0} {1}", FormattedColour, MakePlural(PartPair.Key.ToString() ).ToLower() ) );
        }

        string Joined = GetColouredPartsString( ref PartColourTexts );
        string IntroText = string.Format( "<b><i>{0}</i><b> type units have" , ClassificationDescription.UnitType.ToString() );

        ClassificationDescription.DescriptionTextObject.SetText( string.Format( "{0} {1}\n\n{2}", IntroText, Joined, ClassificationDescription.FlavourText ) );
    }

    private string MakePlural( string InPart )
    {
        if ( InPart[InPart.Length - 1] != 's' )
        {
            return InPart + 's';
        }
        return InPart;
    }

    private string GetColouredPartsString( ref List<string> InPartColourTexts )
    {
        StringBuilder Combined = new StringBuilder();
        for ( int i = 0; i < InPartColourTexts.Count; i++ )
        {
            Combined.Append( InPartColourTexts[i] );

            if ( i <= InPartColourTexts.Count - 2 )
            {
                Combined.Append( (i == InPartColourTexts.Count - 2) ? " and " : ", " );
            }
            else
            {
                Combined.Append( '.' );
            }
        }
        return Combined.ToString();
    }
}
