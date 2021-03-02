using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class SpawnableUnitDisplay : SelectableUIUnit
{
    public TextMeshProUGUI QuantityText;
    public static event AIDelegates.FriendlyUnitDataDelegate onSpawnableUnitSelected;
    
    private int Quantity = 1;

    public int UpdateQuantity( int Amount )
    {
        Quantity += Amount;
        QuantityText.SetText( string.Format("x{0}", Quantity) );
        return Quantity;
    }

    public override void Select()
    {
        onSpawnableUnitSelected( UnitData );
    }
}
