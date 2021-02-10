using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.Interaction.Toolkit;

public class Gun : GrabableItem
{
    public string TestVar = "";
    public float RPM = 100.0f;
    public GameObject Muzzle;

    private float LastShot = 0.0f;

    private void OnDrawGizmos()
    {
        if ( Muzzle )
        {
            Gizmos.color = Color.red;
            Gizmos.DrawRay( Muzzle.transform.position, Muzzle.transform.forward * 5.0f );
        }
    }

    public override void OnActivate( XRBaseInteractor Interactor )
    {
        Shoot();
    }

    void Shoot()
    {
        float FireRateDelta = ( 60.0f / RPM );
        if ( Time.time > ( LastShot + FireRateDelta ) )
        {
            LastShot = Time.time;

            GameObject Bullet = GameObject.CreatePrimitive( PrimitiveType.Cube );
            Bullet.transform.localScale = new Vector3( 0.1f, 0.1f, 0.1f );
            Bullet.transform.position = Muzzle.transform.position;
            Bullet.AddComponent<Rigidbody>().AddForce( Muzzle.transform.forward * 1000.0f );
            Destroy( Bullet, 10.0f );
        }
    }
}
