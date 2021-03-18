using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public struct AIEnemyPartVarientBinding
{
    public AIEnemyPartCategory Part;
    public MeshRenderer Object;
    public Material MaterialReference;
}

public class AIEnemyAppearanceComponent : MonoBehaviour
{
    public List<AIEnemyPartVarientBinding> Parts = new List<AIEnemyPartVarientBinding>();

    public void SetupPartColours( AIEnemyUnitTypes Type )
    {
        if ( GameState.TryGetGameService<AIEnemyPartColourService>( out AIEnemyPartColourService PartColourService ) )
        {
            AIEnemyPartConfiguration PartConfig = PartColourService.GetPartConfigurationForUnitType( Type );

            foreach ( AIEnemyPartVarientBinding Binding in Parts )
            {
                Optional<AIEnemyColourDesc> Colour = PartConfig.GetPartColour( Binding.Part );
                Material MaterialInstance = GetMaterialInstance(Binding.Object, Binding.MaterialReference);

                if ( Colour && MaterialInstance )
                {
                    MaterialInstance.SetColor( "_color", Colour.Get().Colour );
                }
            }
        }    
    }

    private Material GetMaterialInstance( MeshRenderer Renderer, Material SharedMaterial )
    {
        foreach ( Material Mat in Renderer.materials )
        {
            if ( Mat.name == SharedMaterial.name + " (Instance)" )
            {
                return Mat;
            }
        }
        return null;
    }
}
