using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIEntityHealthBarObserver : MonoBehaviour
{
    public Entity EntityReference;
    public Image HealthBar;

    private void Start()
    {
        Entity.onEntityCreated += EntityCreated;
    }

    private void EntityCreated( Entity Ent )
    {
        if ( Ent == EntityReference )
        {
            Ent.GetDamageableComponent().OnNormalisedHealthChange += UpdateHealthBar;
        }
    }

    private void UpdateHealthBar( float Value )
    {
        HealthBar.fillAmount = Value;
    }

    private void OnDestroy()
    {
        Entity.onEntityCreated -= EntityCreated;

        if ( EntityReference )
        {
            EntityReference.GetDamageableComponent().OnNormalisedHealthChange -= UpdateHealthBar;
        }
    }
}
