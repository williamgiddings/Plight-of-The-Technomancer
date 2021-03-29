using UnityEngine;
using UnityEditor;
using System.Collections;

// Script created by Custom Inspector Generator
[CustomEditor(typeof(AIEngagementParams))]
public class AIEngagementParamsEditor : Editor 
{
	AIEngagementParams targetScript;
	
	void OnEnable() 
	{
		targetScript = (AIEngagementParams)target;
	}
	
	// Drawing the Custom Inspector
    public override void OnInspectorGUI() 
	{
		DrawDefaultInspector();
		EditorGUILayout.HelpBox( string.Format( "Damage Per Second: {0}", targetScript.GetDamagePerSecond() ), MessageType.Info );
	}
}



