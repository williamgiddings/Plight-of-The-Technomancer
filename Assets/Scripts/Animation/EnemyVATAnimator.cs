using RedBlueGames.LiteFSM;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public struct EnemyVATAnimation
{
    public EnemyVATAnimator.EnemyAnimState AnimationState;
    public PartAnims AnimParams;

    [System.Serializable]
    public struct PartAnims
    {
        public VATAnimParams Head;
        public VATAnimParams Legs;
    }
}

public class EnemyVATAnimator : MonoBehaviour
{
    [Header("Animation Settings")]
    public List<EnemyVATAnimation> Animations = new List<EnemyVATAnimation>();

    [Header( "Material Settings" )]
    public MeshRenderer     HeadRenderer;
    public MeshRenderer     LegsRenderer;
    public List<Material>   VATMaterials = new List<Material>();

    private StateMachine<EnemyAnimState> AnimStateMachine;

    public enum EnemyAnimState
    {
        Idle = 0,
        Walking = 1,
        Attacking = 2
    }

    private void Start()
    {
        List< State< EnemyAnimState > > StateList = new List< State< EnemyAnimState > >();
        StateList.Add( new State<EnemyAnimState>( EnemyAnimState.Idle, EnterIdle, null, null ) );
        StateList.Add( new State<EnemyAnimState>( EnemyAnimState.Walking, EnterWalking, null, UpdateWalking ) );
        StateList.Add( new State<EnemyAnimState>( EnemyAnimState.Attacking, EnterAttacking, null, null ) );
        AnimStateMachine = new StateMachine<EnemyAnimState>( StateList.ToArray(), EnemyAnimState.Idle );
    }

    private EnemyVATAnimation.PartAnims GetAnimParams( EnemyAnimState State )
    {
        return Animations.Find( x => x.AnimationState == State ).AnimParams;
    }

    public void SetState( EnemyAnimState NewState )
    {
        AnimStateMachine.ChangeState( NewState );
    }

    private void EnterIdle()
    {
        ApplyNewAnimation( GetAnimParams( EnemyAnimState.Idle ) );
    }

    private void EnterWalking()
    {
        ApplyNewAnimation( GetAnimParams( EnemyAnimState.Walking ) );
    }

    private void EnterAttacking()
    {
        ApplyNewAnimation( GetAnimParams( EnemyAnimState.Attacking ) );
    }

    private void UpdateWalking( float DeltaTime )
    {
        //Alter anim speed with velocity
    }


    private void ApplyNewAnimation( EnemyVATAnimation.PartAnims NewAnimation )
    {
        for( int i = 0; i < HeadRenderer.materials.Length; i++ )
        {
            if ( ShouldModifyVATMaterial( HeadRenderer.materials[i] ) )
            {
                SetAnimationOnMaterial( ref HeadRenderer.materials[i], NewAnimation.Head );
            }
        }

        for ( int i = 0; i < LegsRenderer.materials.Length; i++ )
        {
            if ( ShouldModifyVATMaterial( LegsRenderer.materials[i] ) )
            {
                SetAnimationOnMaterial( ref LegsRenderer.materials[i], NewAnimation.Legs );
            }
        }
    }

    bool ShouldModifyVATMaterial( Material Mat )
    {
        return VATMaterials.Find( x => Mat.name == x.name + " (Instance)" );
    }

    private void SetAnimationOnMaterial( ref Material Instance, VATAnimParams Anim )
    {
        Instance.SetTexture( "_PositionMap", Anim.PositionMap );
        Instance.SetTexture( "_NormalMap", Anim.NormalMap );
        Instance.SetFloat( "_posMin", Anim.PositionMin );
        Instance.SetFloat( "_posMax", Anim.PositionMax );
        Instance.SetFloat( "_speed", Anim.DefaultSpeed );
        Instance.SetFloat( "_numOfFrames", Anim.NumberOfFrames );
        Instance.SetFloat( "_frameStart", Anim.StartFrame );
    }
}
