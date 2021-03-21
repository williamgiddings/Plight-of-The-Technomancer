using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class BeaconLight : MonoBehaviour
{
    public Transform SpinningLightContainer;
    public Light[] Lights;
    public float BeaconSpinSpeed;
    [ColorUsage(true, true)]
    public Color StaticLightEmissionColor;

    private MeshRenderer LightMeshRenderer;
    private bool BeaconActive = false;
    
    private void Start()
    {
        if ( GameState.TryGetGameService<AIWaveSpawnService>( out AIWaveSpawnService WaveService ) )
        {
            WaveService.OnWaveBegin += EnableBeaconLight;
            WaveService.OnWaveEnd += DisableBeaconLight;
        }
        LightMeshRenderer = GetComponent<MeshRenderer>();
        LightMeshRenderer.material.SetColor( "_EmissionColor", Color.black );
    }

    private void DisableBeaconLight( AIWave NewWave )
    {
        foreach ( Light BeaconLight in Lights )
        {
            BeaconLight.enabled = false;
        }
        LightMeshRenderer.material.SetColor( "_EmissionColor", Color.black );
        BeaconActive = false;
    }

    private void EnableBeaconLight( AIWave NewWave )
    {
        foreach( Light BeaconLight in Lights )
        {
            BeaconLight.enabled = true;
        }
        LightMeshRenderer.material.SetColor( "_EmissionColor", StaticLightEmissionColor );
        BeaconActive = true;
    }

    private void Update()
    {
        if ( BeaconActive )
        {
            SpinningLightContainer.Rotate( new Vector3(0,0,1), Time.deltaTime * BeaconSpinSpeed ); ;
        }
    }
}
