using System.Collections;
using System.Collections.Generic;
using Breach.WildWaters.Apps;
using UnityEngine;
using UnityEngine.UI;

namespace Breach.WildWaters.UI
{

    public class SimulationControlsUI : MonoBehaviour
    {
        [SerializeField] private Toggle playToggle;
        [SerializeField] private Toggle pauseToggle;
        [SerializeField] private Toggle stopToggle;

        private void OnEnable()
        {
            playToggle.onValueChanged.AddListener(PlayButtonPressed);
            pauseToggle.onValueChanged.AddListener(PauseButtonPressed);
            stopToggle.onValueChanged.AddListener(StopButtonPressed);
        }
        private void OnDisable()
        {
            playToggle.onValueChanged.RemoveListener(PlayButtonPressed);
            pauseToggle.onValueChanged.RemoveListener(PauseButtonPressed);
            stopToggle.onValueChanged.RemoveListener(StopButtonPressed);
        }

        public void SetVisible(bool visible) => this.gameObject.SetActive(visible);

        public void SetLocalHeight(float height)
        {
            transform.localPosition = new Vector3(transform.localPosition.x, height, transform.localPosition.z);
        }
        private IPlaybackControls controller;
        public void SetSimulationController(IPlaybackControls controller) => this.controller = controller;

        private void PlayButtonPressed(bool enabled)
        {
            if (!enabled) return;
            controller.Play();
        }

        private void PauseButtonPressed(bool enabled)
        {
            if (!enabled) return;
            controller.Pause();
        }

        private void StopButtonPressed(bool enabled)
        {
            if (!enabled) return;
            controller.Stop();
        }
    }
}
