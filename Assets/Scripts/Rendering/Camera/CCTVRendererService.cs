using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum CCTVDirection
{
    North,
    South,
    East,
    West
}

[System.Serializable]
public struct CCTVDirectionCameraBinding
{
    public CCTVDirection Direction;
    public Camera CameraInstance;
}

public class CCTVRendererService : GameService
{
    public CCTVDirectionCameraBinding[] Bindings;

    public RenderTexture GetTextureForDirection( CCTVDirection Direction )
    {
        foreach ( CCTVDirectionCameraBinding Binding in Bindings )
        {
            Binding.CameraInstance.enabled = true;
            if ( Binding.Direction == Direction )
            {
                RenderTexture OutputTexture = new RenderTexture( 256, 256, 0, UnityEngine.Experimental.Rendering.DefaultFormat.HDR );
                OutputTexture.Create();
                Binding.CameraInstance.targetTexture = OutputTexture;
                Binding.CameraInstance.Render();
                return OutputTexture;
            }
            Binding.CameraInstance.enabled = false;
        }
        return null;
    }

}
