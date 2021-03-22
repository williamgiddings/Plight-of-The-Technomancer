using DG.Tweening;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

[System.Serializable]
public class DynamicUIElement<Type> where Type : ICanvasElement
{
    public Type     Element;
    public Vector3  HidePosition;
    public Vector3  ShowPosition;
    public float    MoveSpeed;
    public float    BlendSpeed;

    public void Show()
    {
        if ( !Element.IsDestroyed() )
        {
            Element.transform.DOLocalMove( ShowPosition, MoveSpeed );
        }
    }

    public void Hide()
    {
        if ( !Element.IsDestroyed() )
        {
            Element.transform.DOLocalMove( HidePosition, MoveSpeed );
        }
    }

    public void TextFadeInOut()
    {
        TextMeshProUGUI ElementAsText = Element as TextMeshProUGUI;
        if ( ElementAsText )
        {
            Sequence Seq = DOTween.Sequence();
            Seq.Append( ElementAsText.DOFade( 1.0f, BlendSpeed ) );
            Seq.Append( ElementAsText.DOFade( 0.0f, BlendSpeed ) );
        }
    }

    public void SafeDestroy()
    {
        Element.transform.DOKill();
    }
}