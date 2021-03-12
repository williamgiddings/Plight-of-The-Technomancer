using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PC_Gun : MonoBehaviour
{
    public ProjectileTypes AmmoType = ProjectileTypes.Blast;
    private ProjectileService ProjectileServiceInstance;
    

    private void Start()
    {
        ProjectileServiceInstance = GameState.GetGameService<ProjectileService>();
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Mouse0))
        {
            ProjectileServiceInstance.CreateProjectile( gameObject, AmmoType, null, transform.position );
        }
    }
}
