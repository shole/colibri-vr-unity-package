﻿/// Copyright 2019-2020 MINES ParisTech (PSL University)
/// This work is licensed under the terms of the MIT license, see the LICENSE file.
/// 
/// Author: Grégoire Dupont de Dinechin, gregoire@dinechin.org

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEditor;
using COLIBRIVR.Processing;

namespace COLIBRIVR.Rendering
{

    /// <summary>
    /// Class that implements the Disk-Blended Per-View Meshes rendering method.
    /// </summary>
    public class DiskBlendedPerViewMeshes : RenderingMethod
    {

#region FIELDS
        
        [SerializeField] private Helper_CommandBuffer _helperCommandBuffer;
        [SerializeField] private Helper_DiskBlending _helperDiskBlending;

        private bool _initialized = false;
        private RenderTexture _targetColorTexture;
		private RenderTexture _targetDepthTexture;
		private RenderTexture _storedColorTexture;
		private RenderTexture _storedDepthTexture;

#endregion //FIELDS
        
#region INHERITANCE_METHODS

#if UNITY_EDITOR

        /// <inheritdoc/>
        public override GUIContent GetGUIInfo()
        {
            string label = "Disk-blended per-view meshes";
            string tooltip = "Blends the per-view meshes using a disk-based blending field.";
            return new GUIContent(label, tooltip);
        }

        /// <inheritdoc/>
        public override bool HasAdditionalParameters()
        {
            return true;
        }

        /// <inheritdoc/>
        public override void SectionAdditionalParameters()
        {
            // Add an inspector section to enable the user to choose a max blending angle.
            SerializedObject serializedObject = new SerializedObject(_helperDiskBlending);
            _helperDiskBlending.SectionDiskBlending(serializedObject);
            serializedObject.ApplyModifiedProperties();
        }
        
#endif //UNITY_EDITOR

        /// <inheritdoc/>
        public override void Reset()
        {
            base.Reset();
            // Initialize the helper methods.
            _helperCommandBuffer = GeneralToolkit.GetOrAddComponent<Helper_CommandBuffer>(gameObject);
            _helperCommandBuffer.Reset();
            _helperDiskBlending = GeneralToolkit.GetOrAddComponent<Helper_DiskBlending>(gameObject);
            _helperDiskBlending.Reset();
        }

        /// <inheritdoc/>
        public override void InitializeLinks()
        {
            base.InitializeLinks();
            sceneRepresentationMethods = new ProcessingMethod[] { PMColorTextureArray, PMPerViewMeshesQSTR };
        }

        /// <inheritdoc/>
        public override IEnumerator InitializeRenderingMethodCoroutine()
        {
            // Initialize the command buffer.
            _helperCommandBuffer.InitializeCommandBuffer(CameraEvent.BeforeForwardOpaque);
            // Load the scene representation.
            yield return StartCoroutine(LoadSceneRepresentationCoroutine());
            // Initialize the blending material.
            InitializeMaterial();
            // Indicate that this method has finished initialization.
            _initialized = true;
        }

        /// <inheritdoc/>
        public override void UpdateRenderingMethod()
        {
            if(_initialized)
            {
                // Update the command buffer.
                UpdateCommandBuffer();
            }
        }

        /// <inheritdoc/>
        public override void ClearRenderingMethod()
        {
            base.ClearRenderingMethod();
        }

#endregion //INHERITANCE_METHODS

#region METHODS

        /// <summary>
        /// Loads a fitting scene representation from the bundled assets.
        /// </summary>
        /// <returns></returns>
        private IEnumerator LoadSceneRepresentationCoroutine()
        {
            // Load the scene representation.
            yield return StartCoroutine(PMColorTextureArray.LoadProcessedTextureArrayCoroutine());
            yield return StartCoroutine(PMPerViewMeshesQSTR.LoadProcessedPerViewMeshesCoroutine());
            // Deactivate the created geometry.
            _helperCommandBuffer.DeactivateCreatedGeometry(PMPerViewMeshesQSTR.perViewMeshTransforms[0].parent);
        }

        /// <summary>
        /// Initializes the blending material.
        /// </summary>
        private void InitializeMaterial()
        {
            // Create the blending material from the corresponding shader.
            blendingMaterial = new Material(GeneralToolkit.shaderRenderingDiskBlendedPerViewMeshes);
            // Store the color data.
            blendingMaterial.SetTexture("_ColorData", PMColorTextureArray.colorData);
            // Create two sets of textures: the target textures (rendered to every frame) and the stored textures (read from every frame).
            Vector2Int displayResolution = GeneralToolkit.GetCurrentDisplayResolution();
            GeneralToolkit.CreateRenderTexture(ref _targetColorTexture, displayResolution, 0, RenderTextureFormat.DefaultHDR, false, FilterMode.Point, TextureWrapMode.Clamp);
            GeneralToolkit.CreateRenderTexture(ref _targetDepthTexture, displayResolution, 24, RenderTextureFormat.Depth, true, FilterMode.Point, TextureWrapMode.Clamp);
            GeneralToolkit.CreateRenderTexture(ref _storedColorTexture, displayResolution, 0, RenderTextureFormat.DefaultHDR, false, FilterMode.Point, TextureWrapMode.Clamp);
            GeneralToolkit.CreateRenderTexture(ref _storedDepthTexture, displayResolution, 24, RenderTextureFormat.RFloat, true, FilterMode.Point, TextureWrapMode.Clamp);
			blendingMaterial.SetTexture("_StoredColorTexture", _storedColorTexture);
			blendingMaterial.SetTexture("_StoredDepthTexture", _storedDepthTexture);
        }
        
        /// <summary>
        /// Updates the command buffer.
        /// </summary>
        private void UpdateCommandBuffer()
        {
            // Clear the instructions in the command buffer.
            _helperCommandBuffer.commandBuffer.Clear();
            // Clear the camera target's color and depth buffers.
            _helperCommandBuffer.commandBuffer.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
            _helperCommandBuffer.commandBuffer.ClearRenderTarget(true, true, Color.clear);
            // Clear the target textures and stored textures.
            _helperCommandBuffer.commandBuffer.SetRenderTarget(_targetColorTexture);
            _helperCommandBuffer.commandBuffer.ClearRenderTarget(true, true, Color.clear);
            _helperCommandBuffer.commandBuffer.SetRenderTarget(_targetDepthTexture);
            _helperCommandBuffer.commandBuffer.ClearRenderTarget(true, true, Color.clear);
            _helperCommandBuffer.commandBuffer.Blit(_targetColorTexture, _storedColorTexture);
            _helperCommandBuffer.commandBuffer.Blit(_targetDepthTexture, _storedDepthTexture);
            // Determine additional camera parameters to pass to the material as properties.
            List<float> sourceCamIndices;
            List<Vector4> sourceCamPositions;
            List<Matrix4x4> transformationMatrices;
            _helperDiskBlending.UpdateBlendingParameters(ref blendingMaterial, cameraSetup.cameraModels, out sourceCamIndices, out sourceCamPositions, out transformationMatrices);
            // Perform a soft z-test for each source camera and blend them together, storing the result in the stored depth and color textures.
            MaterialPropertyBlock properties = new MaterialPropertyBlock();
            for(int i = 0; i < PMPerViewMeshesQSTR.perViewMeshTransforms.Length; i++)
            {
                // Indicate the camera's index and position.
                properties.SetFloat("_SourceCamIndex", sourceCamIndices[i]);
                properties.SetVector("_SourceCamPosXYZ", sourceCamPositions[i]);
                // Draw the mesh into the target textures' color and depth buffers.
                _helperCommandBuffer.commandBuffer.SetRenderTarget(color: _targetColorTexture, depth: _targetDepthTexture);
                _helperCommandBuffer.commandBuffer.DrawMesh(PMPerViewMeshesQSTR.perViewMeshes[i], transformationMatrices[i], blendingMaterial, 0, 0, properties);
                // Copy the target textures into the stored textures.
                _helperCommandBuffer.commandBuffer.Blit(_targetColorTexture, _storedColorTexture);
                _helperCommandBuffer.commandBuffer.Blit(_targetDepthTexture, _storedDepthTexture);
            }
            // Normalize the stored color texture's RGB channels by its alpha channel, and copy the stored depth and color textures to the camera target.
            _helperCommandBuffer.commandBuffer.Blit(null, BuiltinRenderTextureType.CameraTarget, blendingMaterial, 1);
        }

#endregion //METHODS

    }

}
