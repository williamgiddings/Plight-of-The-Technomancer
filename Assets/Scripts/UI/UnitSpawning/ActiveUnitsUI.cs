using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ActiveUnitsUI : MonoBehaviour
{
    public ActiveAIUnitUIDisplay ActiveUnitTemplate;
    public GridLayoutGroup Grid;
    private Dictionary< AIFriendlyUnit, ActiveAIUnitUIDisplay > ActiveUIs = new Dictionary<AIFriendlyUnit, ActiveAIUnitUIDisplay >();

    private void Awake()
    {
        AIFriendlyUnit.onFriendlyUnitSpawned += AddSpawnedUnit;
        AIFriendlyUnit.onFriendlyUnitDestroyed += RemoveSpawnedUnit;
    }

    private void AddSpawnedUnit( AIFriendlyUnit Unit )
    {
        if ( Grid )
        {
            ActiveAIUnitUIDisplay NewInstance = Instantiate( ActiveUnitTemplate, Grid.transform );
            NewInstance.Bind( ref Unit );
            ActiveUIs.Add( Unit, NewInstance );
            NewInstance.gameObject.SetActive( true );
        }
    }

    private void RemoveSpawnedUnit( AIFriendlyUnit Unit )
    {
        if ( ActiveUIs.TryGetValue( Unit, out ActiveAIUnitUIDisplay UIInstance ) )
        {
            ActiveUIs.Remove( Unit );
            Destroy( UIInstance.gameObject );
        }
    }

    private void OnDestroy()
    {
        AIFriendlyUnit.onFriendlyUnitSpawned -= AddSpawnedUnit;
        AIFriendlyUnit.onFriendlyUnitDestroyed -= RemoveSpawnedUnit;
    }
}
