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
                if ( Binding.UIImageRef.texture )
                {
                    Destroy( Binding.UIImageRef.texture );
                }
                RenderTexture Tex = CCTVService.GetTextureForDirection( Binding.Direction );
                Texture2D NewTex = new Texture2D(256, 256, TextureFormat.RGB24, false, true);
                RenderTexture.active = Tex;
                NewTex.ReadPixels( new Rect( 0, 0, Tex.width, Tex.height ), 0, 0 );
                NewTex.Apply();
                RenderTexture.active = null;
                Tex.Release();
                Binding.UIImageRef.texture = NewTex;
            }
        }
    }
}
