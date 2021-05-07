using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class Player : Entity
{
    [Header("Effects")]
    [SerializeField]
    private Volume PostProcessVolume;
    [SerializeField]
    private Animator AnimationController;
    private bool HasControl;

    public static event DelegateUtils.VoidDelegateNoArgs OnPlayerDied;
    public static event DelegateUtils.VoidDelegateGenericArg<bool> OnPlayerControlStateChanged;

    private void EnableMovement( bool State )
    {
        HasControl = State;
        Cursor.lockState = State ? CursorLockMode.Locked : CursorLockMode.None;
        OnPlayerControlStateChanged( State );
    }

    protected override void Start()
    {
        base.Start();
        DamageableComponent.OnHealthZero += OnDie;
        Biodome.OnBiodomeDestroyed += OnBioDomeDestroyedEffects;
        TutorialService.onTutorialFinished += TutorialFinished;
        AnimationController.enabled = false;
        EnableMovement( false );
    }

    private void TutorialFinished()
    {
        EnableMovement( true );
    }

#if UNITY_EDITOR
    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.F3))
        {
            OnDie();
        }
    }
#endif

    private void OnDie()
    {
        OnDieEffects();
        if ( OnPlayerDied != null ) OnPlayerDied();
        EnableMovement( false );
        GameManager.EndGame( GameResult.Fail );
    }

    protected override void OnDestroy()
    {
        base.OnDestroy();
        for ( int ChildIndex = 0; ChildIndex < transform.childCount; ChildIndex++ )
        {
            transform.GetChild( ChildIndex ).DOKill();
        }
        
        if ( DamageableComponent )
        {
            DamageableComponent.OnHealthZero -= OnDie;
        }
        Biodome.OnBiodomeDestroyed -= OnBioDomeDestroyedEffects;
        TutorialService.onTutorialFinished -= TutorialFinished;
    }

    private void OnDieEffects()
    {
        AnimationController.enabled = true;
        AnimationController.SetTrigger( "OnDie" );
        if ( PostProcessVolume.profile.TryGet<Vignette>( out Vignette VignetteEffect ) )
        {
            VignetteEffect.color.Override( Color.red );
            DOTween.To( delegate(float NewValue) { VignetteEffect.intensity.Override( NewValue ); }, 0.0f, 1.0f, 5.0f );
        }
        if ( PostProcessVolume.profile.TryGet<ChromaticAberration>( out ChromaticAberration CAEffect ) )
        {
            CAEffect.active = true;
        }
    }

    private void OnBioDomeDestroyedEffects()
    {
        if ( AnimationController.TryGetComponent<Camera>( out Camera CameraRef ) )
        {
            CameraRef.DOShakePosition( 8.0f, 0.1f, 10, 90, false );
        }
        if ( PostProcessVolume.profile.TryGet<ChromaticAberration>( out ChromaticAberration CAEffect ) )
        {
            CAEffect.active = true;
        }
    }
}
