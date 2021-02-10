using UnityEngine;
using UnityEditor;
using System.Collections;

[CustomEditor(typeof(GrabableParams))]
public class GrabableParamsEditor : Editor 
{
	GrabableParams targetScript;
	SerializedObject serializedTargetScript;
	
	SerializedProperty SmoothPosition;
	SerializedProperty GravityOnDetach;
	SerializedProperty ThrowAngularVelocityScale;
	SerializedProperty ThrowVelocityScale;
	SerializedProperty ThrowSmoothingCurve;
	SerializedProperty ThrowSmoothingDuration;
	SerializedProperty ThrowOnDetach;
	SerializedProperty TightenRotation;
	SerializedProperty SmoothRotationAmount;
	SerializedProperty SmoothRotation;
	SerializedProperty TrackRotation;
	SerializedProperty TightenPosition;
	SerializedProperty SmoothPositionAmount;
	SerializedProperty TrackPosition;
	SerializedProperty MovementType;
	SerializedProperty AttachEaseInTime;
	SerializedProperty AttachTransformName;
	SerializedProperty RetainTransformParent;

	void OnEnable()
    {
		targetScript = (GrabableParams)target;
		serializedTargetScript = new SerializedObject(targetScript);
		
		SmoothPosition = serializedTargetScript.FindProperty("SmoothPosition");
		GravityOnDetach = serializedTargetScript.FindProperty("GravityOnDetach");
		ThrowAngularVelocityScale = serializedTargetScript.FindProperty("ThrowAngularVelocityScale");
		ThrowVelocityScale = serializedTargetScript.FindProperty("ThrowVelocityScale");
		ThrowSmoothingCurve = serializedTargetScript.FindProperty("ThrowSmoothingCurve");
		ThrowSmoothingDuration = serializedTargetScript.FindProperty("ThrowSmoothingDuration");
		ThrowOnDetach = serializedTargetScript.FindProperty("ThrowOnDetach");
		TightenRotation = serializedTargetScript.FindProperty("TightenRotation");
		SmoothRotationAmount = serializedTargetScript.FindProperty("SmoothRotationAmount");
		SmoothRotation = serializedTargetScript.FindProperty("SmoothRotation");
		TrackRotation = serializedTargetScript.FindProperty("TrackRotation");
		TightenPosition = serializedTargetScript.FindProperty("TightenPosition");
		SmoothPositionAmount = serializedTargetScript.FindProperty("SmoothPositionAmount");
		TrackPosition = serializedTargetScript.FindProperty("TrackPosition");
		MovementType = serializedTargetScript.FindProperty("MovementType");
		AttachEaseInTime = serializedTargetScript.FindProperty("AttachEaseInTime");
        AttachTransformName = serializedTargetScript.FindProperty( "AttachTransformName" );
		RetainTransformParent = serializedTargetScript.FindProperty("RetainTransformParent");
	}
	
    public override void OnInspectorGUI()
    {
		serializedTargetScript.Update();

        EditorGUILayout.PropertyField( MovementType, new GUIContent( "MovementType" ) );
        EditorGUILayout.PropertyField( RetainTransformParent, new GUIContent( "RetainTransformParent" ) );
        EditorGUILayout.PropertyField( TrackPosition, new GUIContent( "TrackPosition" ) );

        if ( TrackPosition.boolValue )
        {
            using ( new EditorGUI.IndentLevelScope() )
            {
                EditorGUILayout.PropertyField( SmoothPosition, new GUIContent( "SmoothPosition" ) );
                using ( new EditorGUI.IndentLevelScope() )
                {
                    if ( SmoothPosition.boolValue )
                    {
                        EditorGUILayout.Slider( SmoothPositionAmount, 0.0f, 20.0f, new GUIContent( "SmoothPositionAmount" ) );
                        EditorGUILayout.Slider( TightenPosition, 0.0f, 1.0f, new GUIContent( "TightenPosition" ) );
                    }
                }      
            }
        }

        EditorGUILayout.PropertyField( TrackRotation, new GUIContent( "TrackRotation" ) );

        if ( TrackRotation.boolValue )
        {
            using ( new EditorGUI.IndentLevelScope() )
            {
                EditorGUILayout.PropertyField( SmoothRotation, new GUIContent( "SmoothRotation" ) );

                using ( new EditorGUI.IndentLevelScope() )
                {
                    if ( SmoothRotation.boolValue )
                    {
                        EditorGUILayout.Slider( SmoothRotationAmount, 0.0f, 20.0f, new GUIContent( "SmoothRotationAmount" ) );
                        EditorGUILayout.Slider( TightenRotation, 0.0f, 1.0f, new GUIContent( "TightenRotation" ) );
                    }
                }

            }
            
            
        }

        EditorGUILayout.PropertyField( ThrowOnDetach, new GUIContent( "ThrowOnDetach" ) );

        if ( ThrowOnDetach.boolValue )
        {
            EditorGUILayout.PropertyField( ThrowSmoothingDuration, new GUIContent( "ThrowSmoothingDuration" ) );
            EditorGUILayout.PropertyField( ThrowSmoothingCurve, new GUIContent( "ThrowSmoothingCurve" ) );
            EditorGUILayout.PropertyField( ThrowVelocityScale, new GUIContent( "ThrowVelocityScale" ) );
            EditorGUILayout.PropertyField( ThrowAngularVelocityScale, new GUIContent( "ThrowAngularVelocityScale" ) );
            EditorGUILayout.PropertyField( GravityOnDetach, new GUIContent( "GravityOnDetach" ) );
        }

		EditorGUILayout.PropertyField(AttachEaseInTime, new GUIContent("AttachEaseInTime"));
        EditorGUILayout.PropertyField( AttachTransformName, new GUIContent( "AttachTransformName" ) );

        serializedTargetScript.ApplyModifiedProperties();
	}
}