using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using TMPro;

public class SpawnRadar : MonoBehaviour
{
    public SpawnerDisplayReticle Reticle;
    public TextMeshProUGUI PositionGUI;
    
    private RectTransform CachedTransform;
    private Canvas CachedCanvas;

    private Optional<Vector2> TargetNormalisedPosition;

    public static event AIDelegates.FriendlyUnitCoordDelegate onSpawnCoordSelected;

    private void Start()
    {
        CachedTransform = GetComponent<RectTransform>();
        CachedCanvas = GetComponent<Canvas>();
        UpdateCoordText();
    }

    public void StartMovingReticle( BaseEventData Event )
    {
        if ( !TargetNormalisedPosition )
        {
            Reticle.StartMoving( Event as PointerEventData );
        }
    }

    public void StopMovingReticle( BaseEventData Event )
    {
        if ( !TargetNormalisedPosition )
        { 
            Reticle.StopMoving();
        }    
    }

    public void OnSelect( BaseEventData Event )
    {
        if (!TargetNormalisedPosition )
        {
            Vector2 Position = Reticle.Select();
            TargetNormalisedPosition = new Vector2( Mathf.Abs(Position.x / CachedTransform.rect.width), 1.0f-Mathf.Abs(Position.y / CachedTransform.rect.height) );
            Debug.Log( string.Format( "Norm: ", TargetNormalisedPosition.ToString() ) );
            Debug.Log( string.Format( "Raw: ", Position.ToString() ) );
            Reticle.PauseMovement();
            onSpawnCoordSelected( TargetNormalisedPosition );
        }
        else
        {
            ResetSelection();
        }
        UpdateCoordText();
    }

    public void ResetSelection()
    {
        TargetNormalisedPosition.Reset();
        onSpawnCoordSelected( TargetNormalisedPosition );
        Reticle.ResumeMovement();
    }

    private void UpdateCoordText()
    {
        PositionGUI.SetText(
            TargetNormalisedPosition ?
            string.Format( "Pos X: {0}\nPos Y: {1}", TargetNormalisedPosition.Get().x, TargetNormalisedPosition.Get().y ) :
            "No Coords Selected"
        );
    }

}

