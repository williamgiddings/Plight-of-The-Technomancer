using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

[System.Serializable]
public struct ProjectileHitColourBinding
{
    public ProjectileTypes HitType;
    public Color HitColor;
}

public class HoloShieldVisual : MonoBehaviour
{
    public List<ProjectileHitColourBinding> ProjectileHitColourBindings = new List<ProjectileHitColourBinding>();

    [Header("Shield Settings")]
    public GameObject ShieldObject;
    public float ColourHitReactSpeed;
    public float Brightness;

    private Renderer ShieldRendererComponent;
    private ResistingDamageable DamageableComponent;

    private void Start()
    {
        ShieldRendererComponent = ShieldObject.GetComponent<Renderer>();
        DamageableComponent = GetComponent<ResistingDamageable>();
        
        if (DamageableComponent)
        {
            DamageableComponent.OnDamageResisted += HitShield;
        }
    }

    private void HitShield( DamageSource Source )
    {
        MoveShield( ( Source.GetDamageOrigin() - transform.position ).normalized );
        Sequence HitSequence = DOTween.Sequence();
        ShieldRendererComponent.material.SetColor( "_MainColor", GetHitColor( Source.GetDamageType() ) * Brightness );
        HitSequence.Append(ShieldRendererComponent.material.DOFloat( 1.0f, "_Fade", ColourHitReactSpeed ) );
        HitSequence.Append(ShieldRendererComponent.material.DOFloat( 0.0f, "_Fade", ColourHitReactSpeed ) );
    }

    private Color GetHitColor( ProjectileTypes InType )
    {
        foreach( ProjectileHitColourBinding Binding in ProjectileHitColourBindings )
        {
            if ( Binding.HitType == InType )
            {
                return Binding.HitColor;
            }
        }
        return Color.black;
    }

    private void MoveShield( Vector3 HitDirection )
    {
        ShieldObject.transform.rotation = Quaternion.LookRotation( HitDirection, Vector3.up );
    }
}
