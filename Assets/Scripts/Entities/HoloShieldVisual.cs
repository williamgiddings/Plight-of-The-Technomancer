using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class HoloShieldVisual : MonoBehaviour
{
    public GameObject ShieldObject;
    public Transform TestCamera;
    public float ColourHitReactSpeed;

    private Renderer ShieldRendererComponent;

    private void Start()
    {
        ShieldRendererComponent = ShieldObject.GetComponent<Renderer>();
    }

    void HitShield( /*Projectile HitProjectile*/ )
    {
        MoveShield( ( TestCamera.position - transform.position ).normalized );
        Sequence HitSequence = DOTween.Sequence();
        HitSequence.Append(ShieldRendererComponent.material.DOFloat( 1.0f, "_Fade", ColourHitReactSpeed ) );
        HitSequence.Append(ShieldRendererComponent.material.DOFloat( 0.0f, "_Fade", ColourHitReactSpeed ) );
    }

    void MoveShield( Vector3 HitDirection )
    {
        ShieldObject.transform.rotation = Quaternion.LookRotation( HitDirection, Vector3.up );
    }
}
