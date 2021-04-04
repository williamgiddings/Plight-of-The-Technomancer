using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UISinglePlayerCameras : MonoBehaviour
{
    [System.Serializable]
    public struct RenderTextureBinding
    {
        public CCTVDirection Direction;
        public RawImage UIImageRef;
    }

    public RenderTextureBinding[] Bindings;
    public int RenderUpdateRate;

    private CCTVRendererService CCTVService;

    private void Start()
    {
        CCTVService = GameState.GetGameService<CCTVRendererService>();
        StartCoroutine( RenderTexturesLoop() );
    }

    private IEnumerator RenderTexturesLoop()
    {
        while( true )
        {
            yield return new WaitForSeconds( 1.0f / RenderUpdateRate );

            foreach( RenderTextureBinding Binding in Bindings )
            {
                RenderTexture NewTex = new RenderTexture( 256, 256, 0, UnityEngine.Experimental.Rendering.DefaultFormat.HDR );
                Graphics.Blit( CCTVService.GetTextureForDirection( Binding.Direction ), NewTex );
                Binding.UIImageRef.texture = NewTex;
            }
        }
    }
}
